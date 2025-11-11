package controller;

import dal.OrderDAO;
import dal.OrderComboDAO;
import dal.TicketDAO;
import dal.VoucherDAO;
import dal.FoodComboDAO;
import dal.ScheduleDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import util.PayOSService;
import util.DBContext;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

/**
 * CheckoutController - Xử lý thanh toán đơn hàng vé và combo
 * 
 * Flow nghiệp vụ:
 * 1. Nhận thông tin từ client (scheduleId, seatIds, comboIds, totalAmount)
 * 2. Validate dữ liệu đầu vào
 * 3. Kiểm tra schedule tồn tại và đang hoạt động
 * 4. Kiểm tra ghế còn trống
 * 5. Tính giá vé từ server (Schedule.price + SeatType.surcharge)
 * 6. Kiểm tra combo hợp lệ và tính giá combo
 * 7. Tính tổng thanh toán (seatTotal + comboTotal - discount)
 * 8. Tạo order với transaction (Order, Ticket, OrderCombo)
 * 9. Xử lý voucher nếu có
 * 10. Tạo payment request
 * 11. Return kết quả
 */
@WebServlet(name = "CheckoutController", urlPatterns = {"/checkout"})
public class CheckoutController extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
    private final TicketDAO ticketDAO = new TicketDAO();
    private final VoucherDAO voucherDAO = new VoucherDAO();
    private final FoodComboDAO foodComboDAO = new FoodComboDAO();
    private final ScheduleDAO scheduleDAO = new ScheduleDAO();
    private final OrderComboDAO orderComboDAO = new OrderComboDAO();
    private final PayOSService payOS = new PayOSService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.sendRedirect(req.getContextPath() + "/");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        System.out.println("=== CHECKOUT CONTROLLER - START ===");
        
        try {
            // ========== BƯỚC 1: NHẬN THÔNG TIN TỪ CLIENT ==========
        String scheduleIdStr = req.getParameter("scheduleId");
            String seatIdsStr = req.getParameter("seatIds");
            String totalStr = req.getParameter("totalAmount"); // Tổng sau giảm giá (vé + combo)
            String originalStr = req.getParameter("originalAmount"); // Tổng gốc (optional)
            String comboIdsStr = req.getParameter("comboIds");
            String comboQuantitiesStr = req.getParameter("comboQuantities");
            String voucherIdStr = req.getParameter("voucherId");
            String voucherCode = req.getParameter("voucherCode");
            String discountStr = req.getParameter("discountAmount");
            
            System.out.println("📥 Received parameters:");
            System.out.println("  scheduleId: " + scheduleIdStr);
            System.out.println("  seatIds: " + seatIdsStr);
            System.out.println("  totalAmount: " + totalStr);
            System.out.println("  originalAmount: " + originalStr);
            System.out.println("  comboIds: " + comboIdsStr);
            System.out.println("  comboQuantities: " + comboQuantitiesStr);
            System.out.println("  voucherId: " + voucherIdStr);
            System.out.println("  voucherCode: " + voucherCode);
            System.out.println("  discountAmount: " + discountStr);
            
            // ========== BƯỚC 2: VALIDATE DỮ LIỆU ĐẦU VÀO ==========
        if (scheduleIdStr == null || seatIdsStr == null || totalStr == null) {
                sendError(req, resp, "Thiếu thông tin bắt buộc: scheduleId, seatIds, totalAmount");
            return;
        }

            int scheduleId;
            long totalAmount;
        try {
            scheduleId = Integer.parseInt(scheduleIdStr.trim());
                totalAmount = Long.parseLong(totalStr.trim());
            } catch (NumberFormatException e) {
                sendError(req, resp, "Dữ liệu không hợp lệ: scheduleId hoặc totalAmount");
            return;
        }

            if (scheduleId <= 0 || totalAmount <= 0) {
                sendError(req, resp, "scheduleId và totalAmount phải là số dương");
                return;
            }
            
            // Parse seatIds
            List<Integer> seatIds = parseSeatIds(seatIdsStr);
        if (seatIds.isEmpty()) {
                sendError(req, resp, "Danh sách ghế không được rỗng");
                return;
            }
            
            // Parse comboIds và comboQuantities
            List<Integer> comboIds = new ArrayList<>();
            List<Integer> comboQuantities = new ArrayList<>();
            if (comboIdsStr != null && !comboIdsStr.trim().isEmpty()
                && comboQuantitiesStr != null && !comboQuantitiesStr.trim().isEmpty()) {
                String[] comboIdsArray = comboIdsStr.split(",");
                String[] comboQuantitiesArray = comboQuantitiesStr.split(",");
                
                if (comboIdsArray.length != comboQuantitiesArray.length) {
                    sendError(req, resp, "comboIds và comboQuantities phải cùng độ dài");
            return;
        }

                for (int i = 0; i < comboIdsArray.length; i++) {
                    try {
                        int comboId = Integer.parseInt(comboIdsArray[i].trim());
                        int quantity = Integer.parseInt(comboQuantitiesArray[i].trim());
                        if (comboId > 0 && quantity > 0) {
                            comboIds.add(comboId);
                            comboQuantities.add(quantity);
                        }
                    } catch (NumberFormatException e) {
                        // Skip invalid entries
                    }
                }
            }
            
            // ========== BƯỚC 3: KIỂM TRA AUTHENTICATION ==========
        HttpSession session = req.getSession(false);
        model.Users user = (session != null) ? (model.Users) session.getAttribute("account") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

            System.out.println("✅ User authenticated: " + user.getId());
            
            // ========== BƯỚC 4: KIỂM TRA SCHEDULE TỒN TẠI ==========
            model.Schedule schedule = scheduleDAO.getScheduleById(scheduleId);
            if (schedule == null) {
                sendError(req, resp, "Suất chiếu không tồn tại hoặc đã ngừng hoạt động");
                return;
            }
            
            System.out.println("✅ Schedule found: " + schedule.getName());
            
            // ========== BƯỚC 4.5: CLEANUP EXPIRED ORDERS ==========
            // Dọn các đơn PENDING đã hết hạn để giải phóng ghế HOLD
            try {
                int cancelledCount = orderDAO.cancelExpiredPending();
                if (cancelledCount > 0) {
                    System.out.println("🧹 Cleaned up " + cancelledCount + " expired pending orders");
                    // Cleanup tickets của các orders đã bị cancel
                    ticketDAO.cleanupHoldOfCancelled();
                }
            } catch (Exception e) {
                System.err.println("⚠️ Warning: Failed to cleanup expired orders: " + e.getMessage());
                // Continue even if cleanup fails
            }
            
            // ========== BƯỚC 5: KIỂM TRA GHẾ CÒN TRỐNG ==========
            List<Integer> occupiedSeats = ticketDAO.validateSeatsAvailable(scheduleId, seatIds);
            if (!occupiedSeats.isEmpty()) {
                // Kiểm tra xem các ghế bị occupied có phải là order của user hiện tại không
                Set<Integer> ordersToCancel = new HashSet<>();
                List<Integer> otherUserSeats = new ArrayList<>();
                
                for (Integer seatId : occupiedSeats) {
                    int[] orderInfo = ticketDAO.getSeatHoldingOrderInfo(scheduleId, seatId);
                    if (orderInfo != null) {
                        int orderId = orderInfo[0];
                        int orderUserId = orderInfo[1];
                        
                        String seatInfo = ticketDAO.getSeatStatusInfo(scheduleId, seatId);
                        if (seatInfo != null) {
                            System.out.println("🔒 Occupied seat " + seatId + ": " + seatInfo);
                        }
                        
                        // Nếu là order của user hiện tại, thêm vào danh sách để hủy
                        if (orderUserId == user.getId()) {
                            System.out.println("🔄 Seat " + seatId + " is held by current user's order " + orderId + ", will cancel old order");
                            ordersToCancel.add(orderId);
                        } else {
                            System.out.println("❌ Seat " + seatId + " is held by another user (userId: " + orderUserId + ")");
                            otherUserSeats.add(seatId);
                        }
                    } else {
                        System.out.println("⚠️ Seat " + seatId + " marked as occupied but no order info found");
                        otherUserSeats.add(seatId);
                    }
                }
                
                // Nếu có ghế của user khác, báo lỗi
                if (!otherUserSeats.isEmpty()) {
                    sendError(req, resp, "Một số ghế đã được đặt bởi người dùng khác. Vui lòng chọn ghế khác: " + otherUserSeats);
                    return;
                }
                
                // Nếu tất cả ghế đều là của user hiện tại, hủy các order cũ
                if (!ordersToCancel.isEmpty()) {
                    System.out.println("🔄 Canceling " + ordersToCancel.size() + " old order(s) held by current user");
                    for (Integer orderId : ordersToCancel) {
                        boolean cancelled = ticketDAO.cancelOrderAndReleaseSeats(orderId);
                        if (cancelled) {
                            System.out.println("✅ Cancelled old order " + orderId + " and released seats");
                        } else {
                            System.out.println("⚠️ Failed to cancel old order " + orderId);
                            sendError(req, resp, "Không thể hủy đơn hàng cũ. Vui lòng thử lại.");
                            return;
                        }
                    }
                    
                    // Validate lại sau khi hủy order cũ
                    occupiedSeats = ticketDAO.validateSeatsAvailable(scheduleId, seatIds);
                    if (!occupiedSeats.isEmpty()) {
                        System.out.println("⚠️ Seats still occupied after canceling old orders: " + occupiedSeats);
                        sendError(req, resp, "Một số ghế vẫn đang được đặt. Vui lòng thử lại sau vài giây: " + occupiedSeats);
                        return;
                    }
                }
            }
            
            System.out.println("✅ All seats available");
            
            // ========== BƯỚC 6: TÍNH GIÁ VÉ TỪ SERVER ==========
            long serverSeatTotal = ticketDAO.calculateTotalSeatPrice(scheduleId, seatIds);
            if (serverSeatTotal < 0) {
                sendError(req, resp, "Lỗi tính toán giá vé từ server");
                return;
            }
            
            // Tính giá từng ghế để lưu vào Ticket
            List<Long> seatPrices = new ArrayList<>();
            for (Integer seatId : seatIds) {
                long price = ticketDAO.calculateSeatPrice(scheduleId, seatId);
                if (price < 0) {
                    sendError(req, resp, "Lỗi tính toán giá ghế " + seatId);
                    return;
                }
                seatPrices.add(price);
            }
            
            System.out.println("✅ Seat total calculated from server: " + serverSeatTotal);
            System.out.println("✅ Seat prices: " + seatPrices);
            
            // Validate: Giá từ client không được chênh lệch quá 10% so với server
            long originalAmount = (originalStr != null) ? Long.parseLong(originalStr.trim()) : totalAmount;
            long priceDifference = Math.abs(originalAmount - serverSeatTotal);
            long allowedDifference = Math.max(serverSeatTotal / 10, 1000); // 10% hoặc 1000 VND
            
            if (priceDifference > allowedDifference) {
                System.out.println("⚠️ Price mismatch: client=" + originalAmount + ", server=" + serverSeatTotal);
                // Sử dụng giá từ server (ưu tiên server)
                originalAmount = serverSeatTotal;
            }
            
            // ========== BƯỚC 7: KIỂM TRA COMBO VÀ TÍNH GIÁ COMBO ==========
            long comboTotal = 0;
            List<Long> comboPrices = new ArrayList<>();
            
            if (!comboIds.isEmpty()) {
                for (int i = 0; i < comboIds.size(); i++) {
                    int comboId = comboIds.get(i);
                    int quantity = comboQuantities.get(i);
                    
                    model.FoodCombo combo = foodComboDAO.getFoodComboById(comboId);
                    if (combo == null) {
                        sendError(req, resp, "Combo không tồn tại: " + comboId);
                        return;
                    }
                    
                    if (!combo.getStatus()) {
                        sendError(req, resp, "Combo không còn hoạt động: " + combo.getName());
            return;
        }

                    long comboPrice = Math.round(combo.getPrice() * quantity);
                    comboTotal += comboPrice;
                    comboPrices.add(Math.round(combo.getPrice())); // Giá đơn vị để lưu vào DB
                }
            }
            
            System.out.println("✅ Combo total: " + comboTotal);
            System.out.println("✅ Combo prices: " + comboPrices);
            
            // ========== BƯỚC 8: TÍNH TỔNG THANH TOÁN ==========
            long seatTotal = serverSeatTotal; // Sử dụng giá từ server
            long originalTotalWithCombo = seatTotal + comboTotal;
            
            // Xử lý voucher
            long discountAmount = 0;
            Integer voucherId = null;
            if (voucherIdStr != null && !voucherIdStr.trim().isEmpty()) {
                try {
                    voucherId = Integer.parseInt(voucherIdStr.trim());
                    discountAmount = (discountStr != null) ? Long.parseLong(discountStr.trim()) : 0;
                    
                    // Validate voucher
                    if (voucherId > 0 && voucherCode != null) {
                model.Voucher voucher = voucherDAO.getVoucherById(voucherId);
                if (voucher == null || !voucher.getCode().equals(voucherCode)) {
                            System.out.println("⚠️ Voucher không hợp lệ, bỏ qua");
                            voucherId = null;
                            discountAmount = 0;
                        }
                    }
                } catch (NumberFormatException e) {
                    voucherId = null;
                    discountAmount = 0;
                }
            }
            
            long finalTotal = originalTotalWithCombo - discountAmount;
            if (finalTotal < 0) {
                finalTotal = 0; // Không thể âm
            }
            
            System.out.println("✅ Final calculation:");
            System.out.println("  Seat total: " + seatTotal);
            System.out.println("  Combo total: " + comboTotal);
            System.out.println("  Original total: " + originalTotalWithCombo);
            System.out.println("  Discount: " + discountAmount);
            System.out.println("  Final total: " + finalTotal);
            
            // ========== BƯỚC 9: TẠO ORDER VỚI TRANSACTION ==========
            // Tạo order code trước khi vào transaction
        long payOrderCode = System.currentTimeMillis();
        String displayOrderCode = "ORD" + payOrderCode;
            Timestamp expiredAt = Timestamp.from(Instant.now().plusSeconds(15 * 60)); // 15 phút

            Connection conn = null;
            int orderId = 0;

            try {
                DBContext dbContext = new DBContext();
                conn = dbContext.getConnection();
                conn.setAutoCommit(false);
        
                // Tạo Order
                orderId = orderDAO.createPendingOrder(conn, user.getId(), finalTotal, displayOrderCode, expiredAt);
        if (orderId <= 0) {
                    throw new SQLException("Không thể tạo order");
                }
                
                System.out.println("✅ Order created: " + orderId + " (" + displayOrderCode + ")");
                
                // Hold seats (Ticket)
                // Note: holdSeatsForOrder sẽ throw SQLException nếu ghế đã bị hold/paid
                try {
                    ticketDAO.holdSeatsForOrder(conn, orderId, scheduleId, seatIds, seatPrices);
                    System.out.println("✅ Seats held: " + seatIds.size());
                } catch (SQLException e) {
                    // Nếu ghế đã bị hold, throw lại với message rõ ràng hơn
                    if (e.getMessage() != null && e.getMessage().contains("already held/paid")) {
                        throw new SQLException("Một số ghế đã được đặt bởi người dùng khác. Vui lòng chọn ghế khác và thử lại.", e);
                    }
                    throw e; // Re-throw nếu là lỗi khác
                }
                
                // Lưu combos (OrderCombo)
                if (!comboIds.isEmpty()) {
                    boolean combosAdded = orderComboDAO.addOrderCombos(conn, orderId, comboIds, comboQuantities, comboPrices);
                    if (!combosAdded) {
                        throw new SQLException("Không thể lưu combo");
                    }
                    
                    System.out.println("✅ Combos added: " + comboIds.size());
                }
                
                // Xử lý voucher
                if (voucherId != null && voucherCode != null) {
                    try {
        boolean voucherUsed = voucherDAO.useVoucherForOrder(voucherId, orderId, discountAmount);
        if (voucherUsed) {
                            voucherDAO.updateVoucherQuantity(voucherId);
                voucherDAO.deactivateIfExhausted(voucherId);
                            System.out.println("✅ Voucher applied: " + voucherCode);
        }
    } catch (Exception e) {
                        System.out.println("⚠️ Voucher error (continuing): " + e.getMessage());
                        // Continue even if voucher fails
                    }
                }
                
                // Commit transaction
                conn.commit();
                System.out.println("✅ Transaction committed");
                
            } catch (SQLException e) {
                System.err.println("❌ Transaction error: " + e.getMessage());
                System.err.println("   SQL State: " + e.getSQLState());
                System.err.println("   Error Code: " + e.getErrorCode());
        e.printStackTrace();
                
                if (conn != null) {
                    try {
                        conn.rollback();
                        System.out.println("🔄 Transaction rolled back");
                    } catch (SQLException ex) {
                        ex.printStackTrace();
                    }
                }
                
                // Kiểm tra nếu lỗi liên quan đến schema (missing columns)
                String errorMessage = e.getMessage();
                if (errorMessage != null && (errorMessage.contains("Invalid column name") 
                        || errorMessage.contains("column") || errorMessage.contains("Column"))) {
                    System.err.println("⚠️ Database schema mismatch detected!");
                    System.err.println("   This might indicate missing columns: OrderId in Ticket table or ExpiredAt in Orders table");
                    errorMessage = "Lỗi cấu trúc database. Vui lòng liên hệ quản trị viên để kiểm tra.";
                } else if (errorMessage != null && errorMessage.contains("already held/paid")) {
                    errorMessage = "Một số ghế đã được đặt bởi người dùng khác. Vui lòng quay lại và chọn ghế khác.";
                } else if (errorMessage != null && errorMessage.contains("Seat")) {
                    errorMessage = "Một số ghế đã được đặt. Vui lòng quay lại và chọn ghế khác.";
                } else {
                    errorMessage = "Lỗi tạo đơn hàng: " + (errorMessage != null ? errorMessage : "Lỗi không xác định");
                }
                
                sendError(req, resp, errorMessage);
            return;
            } finally {
                if (conn != null) {
                    try {
                        conn.setAutoCommit(true);
                        conn.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
            }
            
            // ========== BƯỚC 10: TẠO PAYMENT REQUEST ==========
        try {
            String returnUrl = buildAbsUrl(req, "/payment/return");
            String cancelUrl = buildAbsUrl(req, "/payment/cancel");
                String description = displayOrderCode;
                if (description.length() > 25) {
                    description = description.substring(0, 25);
                }

            PayOSService.PaymentResult pr = payOS.createPayment(
                    String.valueOf(payOrderCode),
                        finalTotal,
                    description,
                    returnUrl,
                    cancelUrl
            );

            if (pr.providerRef != null && !pr.providerRef.isBlank()) {
                orderDAO.updateProviderRef(orderId, pr.providerRef);
            }

                System.out.println("✅ Payment request created");
                
                // ========== BƯỚC 11: FORWARD TO CHECKOUT PAGE ==========
            req.setAttribute("orderCode", displayOrderCode);
                req.setAttribute("amount", finalTotal);
                req.setAttribute("originalAmount", originalTotalWithCombo);
            req.setAttribute("discountAmount", discountAmount);
            req.setAttribute("voucherCode", voucherCode);
                req.setAttribute("seatTotal", seatTotal);
                req.setAttribute("comboTotal", comboTotal);
            req.setAttribute("expireAt", expiredAt.getTime());
            req.setAttribute("qrDataUri", pr.qrDataUri);
            req.setAttribute("qrPlain", pr.qrPlain);
            req.setAttribute("checkoutUrl", pr.checkoutUrl);

            req.getRequestDispatcher("/views/users/checkout.jsp").forward(req, resp);
                
                System.out.println("=== CHECKOUT CONTROLLER - SUCCESS ===");
                
            } catch (Exception e) {
                System.err.println("❌ Payment error: " + e.getMessage());
                e.printStackTrace();
                sendError(req, resp, "Lỗi tạo yêu cầu thanh toán: " + e.getMessage());
            }

        } catch (Exception e) {
            System.err.println("❌ Unexpected error: " + e.getMessage());
            e.printStackTrace();
            sendError(req, resp, "Lỗi không xác định: " + e.getMessage());
        }
    }
    
    /**
     * Parse seat IDs from string
     */
    private List<Integer> parseSeatIds(String seatIdsStr) {
        if (seatIdsStr == null || seatIdsStr.trim().isEmpty()) {
            return new ArrayList<>();
        }
        
        return Arrays.stream(seatIdsStr.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .map(s -> {
                    try {
                        return Integer.parseInt(s);
                    } catch (NumberFormatException e) {
                        return null;
                    }
                })
                .filter(Objects::nonNull)
                .collect(Collectors.toList());
    }
    
    /**
     * Send error response
     */
    private void sendError(HttpServletRequest req, HttpServletResponse resp, String message) 
            throws ServletException, IOException {
        System.err.println("❌ Error: " + message);
        req.setAttribute("error", message);
        req.getRequestDispatcher("/error.jsp").forward(req, resp);
    }
    
    /**
     * Build absolute URL
     */
    private String buildAbsUrl(HttpServletRequest req, String path) {
        int port = req.getServerPort();
        return req.getScheme() + "://" + req.getServerName()
                + ((port == 80 || port == 443) ? "" : (":" + port))
                + req.getContextPath() + path;
    }
}
