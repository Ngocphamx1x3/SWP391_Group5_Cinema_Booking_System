package dal;

import util.DBContext;
import java.sql.*;

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
    
    try (Connection conn = new DBContext().getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        
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
}
