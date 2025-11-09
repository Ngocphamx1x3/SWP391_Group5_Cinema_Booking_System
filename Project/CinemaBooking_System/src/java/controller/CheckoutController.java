package controller;

import dal.OrderDAO;
import dal.TicketDAO;
import dal.VoucherDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import util.PayOSService;

import java.io.IOException;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

@WebServlet(name = "CheckoutController", urlPatterns = {"/checkout"})
public class CheckoutController extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
    private final TicketDAO ticketDAO = new TicketDAO();
    private final VoucherDAO voucherDAO = new VoucherDAO();
    private final PayOSService payOS  = new PayOSService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.sendRedirect(req.getContextPath() + "/");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
         // DEBUG: In ra tất cả parameters
        System.out.println("=== CHECKOUT DEBUG ===");
        java.util.Enumeration<String> paramNames = req.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String paramName = paramNames.nextElement();
            String paramValue = req.getParameter(paramName);
            System.out.println(paramName + ": " + paramValue);
        }
        System.out.println("======================");
        
        // --- 0) Input với hỗ trợ voucher ---
        String scheduleIdStr = req.getParameter("scheduleId");
        String seatIdsStr    = req.getParameter("seatIds");
        String totalStr      = req.getParameter("totalAmount");      // Tổng sau giảm giá
        String originalStr   = req.getParameter("originalAmount");   // Tổng gốc (optional)
        
        // Voucher parameters
        String voucherIdStr  = req.getParameter("voucherId");
        String voucherCode   = req.getParameter("voucherCode");
        String discountStr   = req.getParameter("discountAmount");

        if (scheduleIdStr == null || seatIdsStr == null || totalStr == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing params");
            return;
        }

        final int scheduleId;
        final long total; // Số tiền thực tế cần thanh toán (đã trừ discount)
        final long originalAmount;
        final long discountAmount;
        final Integer voucherId;
        
        try {
            scheduleId = Integer.parseInt(scheduleIdStr.trim());
            total      = Long.parseLong(totalStr.trim());
            originalAmount = (originalStr != null) ? Long.parseLong(originalStr.trim()) : total;
            discountAmount = (discountStr != null) ? Long.parseLong(discountStr.trim()) : 0;
            voucherId = (voucherIdStr != null && !voucherIdStr.trim().isEmpty()) 
                      ? Integer.parseInt(voucherIdStr.trim()) : null;
        } catch (NumberFormatException nfe) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid params");
            return;
        }

        List<Integer> seatIds = Arrays.stream(seatIdsStr.split(","))
                .map(String::trim).filter(s -> !s.isEmpty())
                .map(s -> { try { return Integer.parseInt(s); } catch (Exception e) { return null; } })
                .filter(Objects::nonNull).collect(Collectors.toList());

        if (seatIds.isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Empty seat list");
            return;
        }

        // --- 1) Auth ---
        HttpSession session = req.getSession(false);
        model.Users user = (session != null) ? (model.Users) session.getAttribute("account") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // --- 2) Validate voucher nếu có ---
        if (voucherId != null && voucherCode != null) {
            try {
                model.Voucher voucher = voucherDAO.getVoucherById(voucherId);
                if (voucher == null || !voucher.getCode().equals(voucherCode)) {
                    // Voucher không hợp lệ, sử dụng tổng gốc
                    req.setAttribute("error", "Voucher không hợp lệ");
                    // Không cần redirect, tiếp tục với tổng gốc
                } else {
                    // Lưu thông tin voucher vào session để sử dụng sau
                    session.setAttribute("appliedVoucher", voucher);
                    session.setAttribute("discountAmount", discountAmount);
                    session.setAttribute("originalAmount", originalAmount);
                }
            } catch (Exception e) {
                e.printStackTrace();
                // Continue without voucher if there's an error
            }
        }

        // --- 3) Create PENDING order với số tiền thực tế (đã trừ discount) ---
        long payOrderCode = System.currentTimeMillis();
        String displayOrderCode = "ORD" + payOrderCode;

        String description = displayOrderCode;
        if (description.length() > 25) description = description.substring(0, 25);

        Timestamp expiredAt = Timestamp.from(Instant.now().plusSeconds(15 * 60));
        
        // Sử dụng total (số tiền đã giảm giá) để tạo order
        int orderId = orderDAO.createPendingOrder(user.getId(), total, displayOrderCode, expiredAt);
        if (orderId <= 0) {
            req.setAttribute("error", "Cannot create order.");
            req.getRequestDispatcher("/error.jsp").forward(req, resp);
            return;
        }

        // --- 4) Lưu thông tin voucher vào order nếu có ---
if (voucherId != null) {
    try {
        // Cập nhật cả VoucherUsage VÀ giảm quantity trong bảng Voucher
        boolean voucherUsed = voucherDAO.useVoucherForOrder(voucherId, orderId, discountAmount);
        if (voucherUsed) {
            System.out.println("✅ Voucher applied successfully: " + voucherCode);
            
            // Cập nhật usedQuantity trong bảng Voucher
            boolean quantityUpdated = voucherDAO.updateVoucherQuantity(voucherId);
            if (quantityUpdated) {
                System.out.println("✅ Voucher quantity updated: " + voucherCode);
                
                // Kiểm tra và deactivate voucher nếu hết
                voucherDAO.deactivateIfExhausted(voucherId);
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
        // Continue even if voucher saving fails
    }
}

        // --- 5) Hold seats ---
        long unitPrice = Math.round((double) originalAmount / Math.max(1, seatIds.size())); // Sử dụng giá gốc để tính unit price
        boolean held = ticketDAO.holdSeatsForOrder(orderId, scheduleId, seatIds, unitPrice);
        if (!held) {
            req.setAttribute("error", "Some seats are already held/paid. Please reselect.");
            req.getRequestDispatcher("/views/users/seatModalContent.jsp").forward(req, resp);
            return;
        }

        // --- 6) Create PayOS payment với số tiền thực tế ---
        try {
            String returnUrl = buildAbsUrl(req, "/payment/return");
            String cancelUrl = buildAbsUrl(req, "/payment/cancel");

            PayOSService.PaymentResult pr = payOS.createPayment(
                    String.valueOf(payOrderCode),
                    total, // Số tiền thực tế sau giảm giá
                    description,
                    returnUrl,
                    cancelUrl
            );

            if (pr.providerRef != null && !pr.providerRef.isBlank()) {
                orderDAO.updateProviderRef(orderId, pr.providerRef);
            }

            // --- 7) Forward to QR page với thông tin giảm giá ---
            req.setAttribute("orderCode", displayOrderCode);
            req.setAttribute("amount", total);
            req.setAttribute("originalAmount", originalAmount);
            req.setAttribute("discountAmount", discountAmount);
            req.setAttribute("voucherCode", voucherCode);
            req.setAttribute("expireAt", expiredAt.getTime());
            req.setAttribute("qrDataUri", pr.qrDataUri);
            req.setAttribute("qrPlain", pr.qrPlain);
            req.setAttribute("checkoutUrl", pr.checkoutUrl);

            req.getRequestDispatcher("/views/users/checkout.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Cannot create payment request.");
            req.getRequestDispatcher("/error.jsp").forward(req, resp);
        }
    }

    private String buildAbsUrl(HttpServletRequest req, String path) {
        int port = req.getServerPort();
        return req.getScheme() + "://" + req.getServerName()
                + ((port == 80 || port == 443) ? "" : (":" + port))
                + req.getContextPath() + path;
    }
}