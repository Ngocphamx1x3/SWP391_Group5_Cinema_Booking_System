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
String totalStr = req.getParameter("totalAmount");
String originalStr = req.getParameter("originalAmount");
String comboIdsStr = req.getParameter("comboIds");
String comboQuantitiesStr = req.getParameter("comboQuantities");
String voucherIdStr = req.getParameter("voucherId");
String voucherCode = req.getParameter("voucherCode");
String discountStr = req.getParameter("discountAmount");

System.out.println("🎯 [CHECKOUT] === RECEIVED PARAMETERS ===");
System.out.println("  scheduleId: " + scheduleIdStr);
System.out.println("  seatIds: " + seatIdsStr);
System.out.println("  totalAmount: " + totalStr);
System.out.println("  originalAmount: " + originalStr);
System.out.println("  voucherId: " + voucherIdStr);
System.out.println("  voucherCode: " + voucherCode);
System.out.println("  discountAmount: " + discountStr);
System.out.println("  comboIds: " + comboIdsStr);
System.out.println("  comboQuantities: " + comboQuantitiesStr);

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

if (scheduleId <= 0 || totalAmount < 0) {
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

// ========== BƯỚC 3: XỬ LÝ VOUCHER ==========
Integer voucherId = null;
long discountAmount = 0;

if (voucherIdStr != null && !voucherIdStr.trim().isEmpty()) {
    try {
        voucherId = Integer.parseInt(voucherIdStr.trim());
        if (discountStr != null && !discountStr.trim().isEmpty()) {
            discountAmount = Long.parseLong(discountStr.trim());
        }
        
        System.out.println("💳 [VOUCHER] Parsed from request:");
        System.out.println("  - voucherId: " + voucherId);
        System.out.println("  - voucherCode: " + voucherCode);
        System.out.println("  - discountAmount: " + discountAmount);
        
        // Validate voucher
        if (voucherId > 0 && voucherCode != null) {
            model.Voucher voucher = voucherDAO.getVoucherById(voucherId);
            if (voucher == null || !voucher.getCode().equals(voucherCode)) {
                System.out.println("⚠️ [VOUCHER] Invalid voucher, ignoring");
                voucherId = null;
                discountAmount = 0;
            } else {
                System.out.println("✅ [VOUCHER] Valid voucher confirmed");
            }
        }
    } catch (NumberFormatException e) {
        System.out.println("⚠️ [VOUCHER] Parse error, ignoring voucher");
        voucherId = null;
        discountAmount = 0;
    }
}

// ========== BƯỚC 4: KIỂM TRA AUTHENTICATION ==========
HttpSession session = req.getSession(false);
model.Users user = (session != null) ? (model.Users) session.getAttribute("account") : null;
if (user == null) {
    resp.sendRedirect(req.getContextPath() + "/login");
    return;
}

System.out.println("✅ User authenticated: " + user.getId());

// ========== BƯỚC 5: KIỂM TRA SCHEDULE TỒN TẠI ==========
model.Schedule schedule = scheduleDAO.getScheduleById(scheduleId);
if (schedule == null) {
    sendError(req, resp, "Suất chiếu không tồn tại hoặc đã ngừng hoạt động");
    return;
}

System.out.println("✅ Schedule found: " + schedule.getName());

// ========== BƯỚC 6: CLEANUP EXPIRED ORDERS ==========
try {
    int cancelledCount = orderDAO.cancelExpiredPending();
    if (cancelledCount > 0) {
        System.out.println("🧹 Cleaned up " + cancelledCount + " expired pending orders");
        ticketDAO.cleanupHoldOfCancelled();
    }
} catch (Exception e) {
    System.err.println("⚠️ Warning: Failed to cleanup expired orders: " + e.getMessage());
}

// ========== BƯỚC 7: KIỂM TRA GHẾ CÒN TRỐNG ==========
List<Integer> occupiedSeats = ticketDAO.validateSeatsAvailable(scheduleId, seatIds);
if (!occupiedSeats.isEmpty()) {
    Set<Integer> ordersToCancel = new HashSet<>();
    List<Integer> otherUserSeats = new ArrayList<>();
    
    for (Integer seatId : occupiedSeats) {
        int[] orderInfo = ticketDAO.getSeatHoldingOrderInfo(scheduleId, seatId);
        if (orderInfo != null) {
            int orderId = orderInfo[0];
            int orderUserId = orderInfo[1];
            
            if (orderUserId == user.getId()) {
                ordersToCancel.add(orderId);
            } else {
                otherUserSeats.add(seatId);
            }
        } else {
            otherUserSeats.add(seatId);
        }
    }
    
    if (!otherUserSeats.isEmpty()) {
        sendError(req, resp, "Một số ghế đã được đặt bởi người dùng khác: " + otherUserSeats);
        return;
    }
    
    if (!ordersToCancel.isEmpty()) {
        for (Integer orderId : ordersToCancel) {
            boolean cancelled = ticketDAO.cancelOrderAndReleaseSeats(orderId);
            if (!cancelled) {
                sendError(req, resp, "Không thể hủy đơn hàng cũ. Vui lòng thử lại.");
                return;
            }
        }
        
        occupiedSeats = ticketDAO.validateSeatsAvailable(scheduleId, seatIds);
        if (!occupiedSeats.isEmpty()) {
            sendError(req, resp, "Một số ghế vẫn đang được đặt: " + occupiedSeats);
            return;
        }
    }
}

System.out.println("✅ All seats available");

// ========== BƯỚC 8: TÍNH GIÁ VÉ TỪ SERVER ==========
long serverSeatTotal = ticketDAO.calculateTotalSeatPrice(scheduleId, seatIds);
if (serverSeatTotal < 0) {
    sendError(req, resp, "Lỗi tính toán giá vé từ server");
    return;
}

List<Long> seatPrices = new ArrayList<>();
for (Integer seatId : seatIds) {
    long price = ticketDAO.calculateSeatPrice(scheduleId, seatId);
    if (price < 0) {
        sendError(req, resp, "Lỗi tính toán giá ghế " + seatId);
        return;
    }
    seatPrices.add(price);
}

System.out.println("💰 [SERVER] Seat total calculated: " + serverSeatTotal);

// ========== BƯỚC 9: XÁC ĐỊNH GIÁ VÉ SỬ DỤNG ==========
long seatTotal;
long originalSeatAmount;

if (voucherId != null && discountAmount > 0) {
    // CÓ VOUCHER: Ưu tiên sử dụng giá từ client
    if (originalStr != null && !originalStr.trim().isEmpty()) {
        try {
            originalSeatAmount = Long.parseLong(originalStr.trim());
        } catch (NumberFormatException e) {
            originalSeatAmount = serverSeatTotal;
        }
    } else {
        originalSeatAmount = serverSeatTotal;
    }
    
    // totalAmount từ client đã bao gồm combo, cần trừ combo để lấy seat amount
    seatTotal = originalSeatAmount - discountAmount;
    
    System.out.println("💳 [WITH VOUCHER] Using client prices:");
    System.out.println("  - Original seat amount: " + originalSeatAmount);
    System.out.println("  - Discount: " + discountAmount);
    System.out.println("  - Seat total (after discount): " + seatTotal);
} else {
    // KHÔNG CÓ VOUCHER: Sử dụng giá từ server
    seatTotal = serverSeatTotal;
    originalSeatAmount = serverSeatTotal;
    
    System.out.println("💰 [NO VOUCHER] Using server price: " + serverSeatTotal);
}

// ========== BƯỚC 10: KIỂM TRA COMBO VÀ TÍNH GIÁ COMBO ==========
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
        comboPrices.add(Math.round(combo.getPrice()));
    }
}

System.out.println("🍿 [COMBO] Total: " + comboTotal);

// ========== BƯỚC 11: TÍNH TỔNG THANH TOÁN ==========
long finalTotal = seatTotal + comboTotal;

System.out.println("💰 [FINAL CALCULATION]:");
System.out.println("  - Original seat amount: " + originalSeatAmount);
System.out.println("  - Discount: " + discountAmount);
System.out.println("  - Seat total (after discount): " + seatTotal);
System.out.println("  - Combo total: " + comboTotal);
System.out.println("  - FINAL TOTAL: " + finalTotal);

// ========== BƯỚC 12: TẠO ORDER VỚI TRANSACTION ==========
long payOrderCode = System.currentTimeMillis();
String displayOrderCode = "ORD" + payOrderCode;
Timestamp expiredAt = Timestamp.from(Instant.now().plusSeconds(15 * 60));

Connection conn = null;
int orderId = 0;

try {
    DBContext dbContext = new DBContext();
    conn = dbContext.getConnection();
    conn.setAutoCommit(false);

    orderId = orderDAO.createPendingOrder(conn, user.getId(), finalTotal, displayOrderCode, expiredAt);
    if (orderId <= 0) {
        throw new SQLException("Không thể tạo order");
    }
    
    System.out.println("✅ Order created: " + orderId + " (" + displayOrderCode + ")");
    
    try {
        ticketDAO.holdSeatsForOrder(conn, orderId, scheduleId, seatIds, seatPrices);
        System.out.println("✅ Seats held: " + seatIds.size());
    } catch (SQLException e) {
        if (e.getMessage() != null && e.getMessage().contains("already held/paid")) {
            throw new SQLException("Một số ghế đã được đặt bởi người dùng khác. Vui lòng chọn ghế khác và thử lại.", e);
        }
        throw e;
    }
    
    if (!comboIds.isEmpty()) {
        boolean combosAdded = orderComboDAO.addOrderCombos(conn, orderId, comboIds, comboQuantities, comboPrices);
        if (!combosAdded) {
            throw new SQLException("Không thể lưu combo");
        }
        System.out.println("✅ Combos added: " + comboIds.size());
    }
    
    if (voucherId != null && voucherCode != null && discountAmount > 0) {
        try {
            boolean voucherUsed = voucherDAO.useVoucherForOrder(voucherId, orderId, discountAmount);
            if (voucherUsed) {
                voucherDAO.updateVoucherQuantity(voucherId);
                voucherDAO.deactivateIfExhausted(voucherId);
                System.out.println("✅ Voucher applied: " + voucherCode + " (-" + discountAmount + ")");
            }
        } catch (Exception e) {
            System.out.println("⚠️ Voucher error (continuing): " + e.getMessage());
        }
    }
    
    conn.commit();
    System.out.println("✅ Transaction committed");
    
} catch (SQLException e) {
    System.err.println("❌ Transaction error: " + e.getMessage());
    e.printStackTrace();
    
    if (conn != null) {
        try {
            conn.rollback();
            System.out.println("🔄 Transaction rolled back");
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
    }
    
    String errorMessage = e.getMessage();
    if (errorMessage != null && errorMessage.contains("already held/paid")) {
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

// ========== BƯỚC 13: TẠO PAYMENT REQUEST ==========
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
    
    // ========== BƯỚC 14: FORWARD TO CHECKOUT PAGE ==========
    req.setAttribute("orderCode", displayOrderCode);
    req.setAttribute("amount", finalTotal);
    req.setAttribute("originalAmount", originalSeatAmount + comboTotal);
    req.setAttribute("discountAmount", discountAmount);
    req.setAttribute("voucherCode", voucherCode);
    req.setAttribute("seatTotal", seatTotal);
    req.setAttribute("comboTotal", comboTotal);
    req.setAttribute("expireAt", expiredAt.getTime());
    req.setAttribute("qrDataUri", pr.qrDataUri);
    req.setAttribute("qrPlain", pr.qrPlain);
    req.setAttribute("checkoutUrl", pr.checkoutUrl);

    System.out.println("🎯 [FORWARD] Attributes set:");
    System.out.println("  - amount (final): " + finalTotal);
    System.out.println("  - originalAmount: " + (originalSeatAmount + comboTotal));
    System.out.println("  - discountAmount: " + discountAmount);
    System.out.println("  - voucherCode: " + voucherCode);
    
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
