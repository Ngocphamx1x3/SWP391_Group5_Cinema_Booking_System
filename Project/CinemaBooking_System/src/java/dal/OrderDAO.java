package dal;

import util.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.Order;
import model.OrderCombo;

public class OrderDAO extends DBContext {

    public int createPendingOrder(int userId, long totalMoney, String orderCode, Timestamp expiredAt) {
        String sql = "INSERT INTO Orders (UserId, OrderDate, Status, TotalMoney, OrderCode, ExpiredAt) "
                + "VALUES (?, GETDATE(), N'PENDING', ?, ?, ?); SELECT SCOPE_IDENTITY();";
        try (Connection c = getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setLong(2, totalMoney);
            ps.setString(3, orderCode);
            ps.setTimestamp(4, expiredAt);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Create pending order using existing connection (for transaction)
     */
    public int createPendingOrder(Connection conn, int userId, long totalMoney, String orderCode, Timestamp expiredAt) throws SQLException {
        String sql = "INSERT INTO Orders (UserId, OrderDate, Status, TotalMoney, OrderCode, ExpiredAt) "
                + "VALUES (?, GETDATE(), N'PENDING', ?, ?, ?); SELECT SCOPE_IDENTITY();";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setLong(2, totalMoney);
            ps.setString(3, orderCode);
            ps.setTimestamp(4, expiredAt);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    public int getOrderIdByCode(String orderCode) {
        String sql = "SELECT Id FROM Orders WHERE OrderCode = ?";
        try (Connection c = getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, orderCode);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public void updateProviderRef(int orderId, String providerRef)
            throws SQLException, ClassNotFoundException {
        String sql = "UPDATE Orders SET ProviderRef = ? WHERE Id = ?";
        try (Connection c = getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, providerRef);
            ps.setInt(2, orderId);
            ps.executeUpdate();
        }
    }

    public void markPaidByCode(String orderCode)
            throws SQLException, ClassNotFoundException {
        String sql = "UPDATE Orders SET Status='PAID', PaidAt=GETDATE() WHERE OrderCode=?";
        try (Connection c = getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, orderCode);
            ps.executeUpdate();
        }
    }

    public void markCancelledByCode(String orderCode)
            throws SQLException, ClassNotFoundException {
        String sql = "UPDATE Orders SET Status='CANCELLED' WHERE OrderCode=?";
        try (Connection c = getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, orderCode);
            ps.executeUpdate();
        }
    }

    public void markPaidByProviderRef(String providerRef) throws SQLException, ClassNotFoundException {
        String sql = "UPDATE Orders SET Status='PAID', PaidAt=GETDATE() WHERE ProviderRef=?";
        try (Connection c = getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, providerRef);
            ps.executeUpdate();
        }
    }

    public int getOrderIdByProviderRef(String providerRef) throws SQLException, ClassNotFoundException {
        String sql = "SELECT Id FROM Orders WHERE ProviderRef=?";
        try (Connection c = getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, providerRef);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public int cancelExpiredPending() throws SQLException, ClassNotFoundException {
        String sql = "UPDATE Orders SET Status='CANCELLED' WHERE Status='PENDING' AND ExpiredAt < GETDATE()";
        try (Connection c = getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            return ps.executeUpdate();
        }
    }

// (Tuỳ chọn) lấy trạng thái hiện tại của đơn
    public String getStatusByCode(String orderCode) throws SQLException, ClassNotFoundException {
        String sql = "SELECT Status FROM Orders WHERE OrderCode=?";
        try (Connection c = getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, orderCode);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString(1) : null;
            }
        }
    }

    public static class OrderEmailInfo {

        public int orderId;
        public String orderCode;
        public String userEmail;
        public String userName;
        public String movieName;
        public String cinemaName;
        public String roomName;
        public java.sql.Timestamp startAt;
        public String seatCodes; // "A1,A2,A3"
        public long totalMoney;
    }

    public OrderEmailInfo getOrderEmailInfoByOrderId(int orderId)
            throws SQLException, ClassNotFoundException {

        String sql
                = "SELECT o.Id AS orderId, o.OrderCode, o.TotalMoney, "
                + "       u.Email AS userEmail, up.FullName AS userName, "
                + "       m.Name AS movieName, c.Name AS cinemaName, r.Name AS roomName, s.StartAt, "
                + "       STUFF((SELECT ',' + se.Code "
                + "              FROM Ticket t2 "
                + "              JOIN Seat se ON se.Id = t2.SeatId "
                + "              WHERE t2.OrderId = o.Id AND t2.Status = 'CONFIRMED' "
                + "              ORDER BY se.Code "
                + "              FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),1,1,'') AS seatCodes "
                + "FROM Orders o "
                + "JOIN Users u            ON u.Id = o.UserId "
                + "LEFT JOIN UserProfile up ON up.UserId = u.Id "
                + "JOIN Ticket tt          ON tt.OrderId = o.Id AND tt.Status = 'CONFIRMED' "
                + "JOIN Schedule s         ON s.Id = tt.ScheduleId "
                + "JOIN Movie m            ON m.Id = s.MovieId "
                + "JOIN Room r             ON r.Id = s.RoomId "
                + "JOIN Cinema c           ON c.Id = r.CinemaId "
                + "WHERE o.Id = ? "
                + "GROUP BY o.Id, o.OrderCode, o.TotalMoney, u.Email, up.FullName, "
                + "         m.Name, c.Name, r.Name, s.StartAt";

        try (Connection c = getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                OrderEmailInfo info = new OrderEmailInfo();
                info.orderId = rs.getInt("orderId");
                info.orderCode = rs.getString("OrderCode");
                info.totalMoney = rs.getLong("TotalMoney");
                info.userEmail = rs.getString("userEmail");
                info.userName = rs.getString("userName");
                info.movieName = rs.getString("movieName");
                info.cinemaName = rs.getString("cinemaName");
                info.roomName = rs.getString("roomName");
                info.startAt = rs.getTimestamp("StartAt");
                info.seatCodes = rs.getString("seatCodes"); // ví dụ: "A1, C14"
                return info;
            }
        }
    }

    // Thêm vào OrderDAO
    public Integer getVoucherIdByOrder(int orderId) {
        String sql = "SELECT VoucherId FROM VoucherUsage WHERE OrderId = ?";

        try (Connection conn = new DBContext().getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, orderId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt("VoucherId");
            }
            return null;

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

   public List<Order> getOrderHistoryByUserId(int userId) {
    List<Order> orders = new ArrayList<>();
    String sql = "SELECT Id, UserId, OrderDate, Status, TotalMoney, OrderCode, " +
                 "ExpiredAt, PaidAt, ProviderRef " +
                 "FROM Orders " +
                 "WHERE UserId = ? " +
                 "ORDER BY OrderDate DESC";

    try (Connection conn = getConnection(); 
         PreparedStatement ps = conn.prepareStatement(sql)) {

        ps.setInt(1, userId);
        
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Order order = mapResultSetToOrder(rs);
                
                // Load combos và tickets cho MỌI đơn hàng
                order.setOrderCombos(getOrderCombosByOrderId(order.getId()));
                order.setTickets(getTicketInfoByOrderId(order.getId()));
                
                orders.add(order);
            }
        }
        
        System.out.println("Found " + orders.size() + " orders for userId: " + userId);
        
    } catch (Exception e) {
        e.printStackTrace();
        System.err.println("Error in getOrderHistoryByUserId: " + e.getMessage());
    }
    return orders;
}

/**
 * Get order combos for a specific order
 */
public List<OrderCombo> getOrderCombosByOrderId(int orderId) {
    List<OrderCombo> orderCombos = new ArrayList<>();
    String sql = "SELECT oc.Id, oc.OrderId, oc.ComboId, oc.Quantity, oc.Price, oc.CreatedAt, " +
                 "fc.Name as ComboName, fc.Image as ComboImage " +
                 "FROM OrderCombo oc " +
                 "JOIN FoodCombo fc ON oc.ComboId = fc.ComboID " +
                 "WHERE oc.OrderId = ?";

    try (Connection conn = getConnection(); 
         PreparedStatement ps = conn.prepareStatement(sql)) {

        ps.setInt(1, orderId);
        
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                OrderCombo orderCombo = mapResultSetToOrderCombo(rs);
                orderCombos.add(orderCombo);
            }
        }
        
        System.out.println("Found " + orderCombos.size() + " combos for orderId: " + orderId);
        
    } catch (Exception e) {
        e.printStackTrace();
        System.err.println("Error in getOrderCombosByOrderId: " + e.getMessage());
    }
    return orderCombos;
}

// Helper method to map ResultSet to Order
private Order mapResultSetToOrder(ResultSet rs) throws SQLException {
    Order order = new Order();
    order.setId(rs.getInt("Id"));
    order.setUserId(rs.getInt("UserId"));
    order.setOrderDate(rs.getTimestamp("OrderDate"));
    order.setStatus(rs.getString("Status"));
    order.setTotalMoney(rs.getLong("TotalMoney"));
    order.setOrderCode(rs.getString("OrderCode"));
    
    // Handle nullable fields
    Timestamp expiredAt = rs.getTimestamp("ExpiredAt");
    order.setExpiresAt(expiredAt);
    
    Timestamp paidAt = rs.getTimestamp("PaidAt");
    order.setPaidAt(paidAt);
    
    String providerRef = rs.getString("ProviderRef");
    order.setProviderRef(providerRef);
    
    return order;
}

// Helper method to map ResultSet to OrderCombo
private OrderCombo mapResultSetToOrderCombo(ResultSet rs) throws SQLException {
    OrderCombo orderCombo = new OrderCombo();
    orderCombo.setId(rs.getInt("Id"));
    orderCombo.setOrderId(rs.getInt("OrderId"));
    orderCombo.setComboId(rs.getInt("ComboId"));
    orderCombo.setQuantity(rs.getInt("Quantity"));
    orderCombo.setPrice(rs.getLong("Price"));
    
    Timestamp createdAt = rs.getTimestamp("CreatedAt");
    orderCombo.setCreatedAt(createdAt);

    // Additional combo info
    orderCombo.setComboName(rs.getString("ComboName"));
    orderCombo.setComboImage(rs.getString("ComboImage"));

    return orderCombo;
}

public List<TicketInfo> getTicketInfoByOrderId(int orderId) {
    List<TicketInfo> tickets = new ArrayList<>();
    String sql = "SELECT t.Id as TicketId, m.Name as MovieName, c.Name as CinemaName, " +
                 "r.Name as RoomName, s.StartAt, se.Code as SeatCode, t.Price as TicketPrice, t.Status as TicketStatus " +
                 "FROM Ticket t " +
                 "JOIN Schedule s ON t.ScheduleId = s.Id " +
                 "JOIN Movie m ON s.MovieId = m.Id " +
                 "JOIN Room r ON s.RoomId = r.Id " +
                 "JOIN Cinema c ON r.CinemaId = c.Id " +
                 "JOIN Seat se ON t.SeatId = se.Id " +
                 "WHERE t.OrderId = ?"; // Bỏ điều kiện AND t.Status = 'CONFIRMED'
    
    try (Connection conn = getConnection(); 
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setInt(1, orderId);
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                TicketInfo ticket = new TicketInfo();
                ticket.setTicketId(rs.getInt("TicketId"));
                ticket.setMovieName(rs.getString("MovieName"));
                ticket.setCinemaName(rs.getString("CinemaName"));
                ticket.setRoomName(rs.getString("RoomName"));
                ticket.setStartAt(rs.getTimestamp("StartAt"));
                ticket.setSeatCode(rs.getString("SeatCode"));
                ticket.setTicketPrice(rs.getLong("TicketPrice"));
                ticket.setTicketStatus(rs.getString("TicketStatus")); // Thêm trạng thái vé
                tickets.add(ticket);
            }
        }
        
        System.out.println("Found " + tickets.size() + " tickets for orderId: " + orderId);
        
    } catch (Exception e) {
        e.printStackTrace();
        System.err.println("Error in getTicketInfoByOrderId: " + e.getMessage());
    }
    return tickets;
}

// Inner class for ticket information
// Inner class for ticket information
public static class TicketInfo {
    private int ticketId;
    private String movieName;
    private String cinemaName;
    private String roomName;
    private Timestamp startAt;
    private String seatCode;
    private long ticketPrice;
    private String ticketStatus; // Thêm trường này
    
    // Getters and Setters
    public int getTicketId() { return ticketId; }
    public void setTicketId(int ticketId) { this.ticketId = ticketId; }
    
    public String getMovieName() { return movieName; }
    public void setMovieName(String movieName) { this.movieName = movieName; }
    
    public String getCinemaName() { return cinemaName; }
    public void setCinemaName(String cinemaName) { this.cinemaName = cinemaName; }
    
    public String getRoomName() { return roomName; }
    public void setRoomName(String roomName) { this.roomName = roomName; }
    
    public Timestamp getStartAt() { return startAt; }
    public void setStartAt(Timestamp startAt) { this.startAt = startAt; }
    
    public String getSeatCode() { return seatCode; }
    public void setSeatCode(String seatCode) { this.seatCode = seatCode; }
    
    public long getTicketPrice() { return ticketPrice; }
    public void setTicketPrice(long ticketPrice) { this.ticketPrice = ticketPrice; }
    
    public String getTicketStatus() { return ticketStatus; }
    public void setTicketStatus(String ticketStatus) { this.ticketStatus = ticketStatus; }
    
    public String getFormattedStartAt() {
        if (startAt != null) {
            return new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(startAt);
        }
        return "N/A";
    }
    
    public String getFormattedTicketPrice() {
        return String.format("%,d", this.ticketPrice) + " đ";
    }
    
    // Helper method để kiểm tra vé có hợp lệ không
    public boolean isValidTicket() {
        return "CONFIRMED".equals(ticketStatus);
    }
}
}
