package controller;

import dal.OrderDAO;
import dal.TicketDAO;
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
    private final PayOSService payOS  = new PayOSService();

    // Optional: cho phép test nhanh bằng GET -> redirect về home (tránh đọc nhầm params PayOS)
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.sendRedirect(req.getContextPath() + "/");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // --- 0) Input ---
        String scheduleIdStr = req.getParameter("scheduleId");
        String seatIdsStr    = req.getParameter("seatIds");     // "12,15,16"
        String totalStr      = req.getParameter("totalAmount");  // long (VND)

        if (scheduleIdStr == null || seatIdsStr == null || totalStr == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing params");
            return;
        }

        final int scheduleId;
        final long total;
        try {
            scheduleId = Integer.parseInt(scheduleIdStr.trim());
            total      = Long.parseLong(totalStr.trim());
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

        // --- 2) Create PENDING order ---
        long payOrderCode = System.currentTimeMillis();         // numeric for PayOS
        String displayOrderCode = "ORD" + payOrderCode;         // save to DB

        String description = displayOrderCode;
        if (description.length() > 25) description = description.substring(0, 25);

        Timestamp expiredAt = Timestamp.from(Instant.now().plusSeconds(15 * 60));
        int orderId = orderDAO.createPendingOrder(user.getId(), total, displayOrderCode, expiredAt);
        if (orderId <= 0) {
            req.setAttribute("error", "Cannot create order.");
            req.getRequestDispatcher("/error.jsp").forward(req, resp);
            return;
        }

        // --- 3) Hold seats ---
        long unitPrice = Math.round((double) total / Math.max(1, seatIds.size()));
        boolean held = ticketDAO.holdSeatsForOrder(orderId, scheduleId, seatIds, unitPrice); // Status='HOLD'
        if (!held) {
            req.setAttribute("error", "Some seats are already held/paid. Please reselect.");
            req.getRequestDispatcher("/views/users/seatModalContent.jsp").forward(req, resp);
            return;
        }

        // --- 4) Create PayOS payment ---
        try {
            String returnUrl = buildAbsUrl(req, "/payment/return"); // PayOS sẽ tự append ?code&status&orderCode&id
            String cancelUrl = buildAbsUrl(req, "/payment/cancel");

            PayOSService.PaymentResult pr = payOS.createPayment(
                    String.valueOf(payOrderCode), // numeric string
                    total,
                    description,
                    returnUrl,
                    cancelUrl
            );

            if (pr.providerRef != null && !pr.providerRef.isBlank()) {
                orderDAO.updateProviderRef(orderId, pr.providerRef);
            }

            // --- 5) Forward to QR page ---
            req.setAttribute("orderCode",   displayOrderCode);
            req.setAttribute("amount",      total);
            req.setAttribute("expireAt",    expiredAt.getTime());
            req.setAttribute("qrDataUri",   pr.qrDataUri);   // may be null
            req.setAttribute("qrPlain",     pr.qrPlain);     // EMV string, fallback for local QR
            req.setAttribute("checkoutUrl", pr.checkoutUrl);

            req.getRequestDispatcher("/views/users/checkout.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            // (Optional) rollback holds if payment creation failed
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
