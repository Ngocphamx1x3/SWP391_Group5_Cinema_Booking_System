package dal;

import util.DBContext;
import java.sql.*;
import java.util.List;

public class TicketDAO extends DBContext {

    /**
     * Ghế bận nếu: - CONFIRMED, hoặc - đang HOLD và đơn PENDING chưa hết hạn
     */
    private boolean isSeatBusy(Connection c, int scheduleId, int seatId) throws SQLException {
        String sql
                = "SELECT COUNT(*) "
                + "FROM Ticket t "
                + "JOIN Orders o ON o.Id = t.OrderId "
                + "WHERE t.ScheduleId=? AND t.SeatId=? "
                + "AND ( t.Status='CONFIRMED' "
                + "   OR (t.Status='HOLD' AND o.Status='PENDING' AND o.ExpiredAt > GETDATE()) )";
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            ps.setInt(2, seatId);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1) > 0;
            }
        }
    }

    /**
     * Giữ ghế: chèn bản ghi Status='HOLD'
     */
    public boolean holdSeatsForOrder(int orderId, int scheduleId, List<Integer> seatIds, long unitPrice) {
        String insert = "INSERT INTO Ticket (Code, Status, Price, ScheduleId, SeatId, OrderId, CreatedAt) "
                + "VALUES (?, 'HOLD', ?, ?, ?, ?, GETDATE())";
        try (Connection c = getConnection()) {
            c.setAutoCommit(false);
            try (PreparedStatement ps = c.prepareStatement(insert)) {
                for (Integer seatId : seatIds) {
                    if (isSeatBusy(c, scheduleId, seatId)) {
                        throw new SQLException("Seat " + seatId + " is already held/paid");
                    }
                    String code = "T" + System.currentTimeMillis() + "-" + seatId;
                    ps.setString(1, code);
                    ps.setLong(2, unitPrice);
                    ps.setInt(3, scheduleId);
                    ps.setInt(4, seatId);
                    ps.setInt(5, orderId);
                    ps.addBatch();
                }
                ps.executeBatch();
            }
            c.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Xác nhận vé sau khi thanh toán thành công
     */
    public boolean confirmTicketsByOrder(int orderId) throws SQLException, ClassNotFoundException {
        String sql = "UPDATE Ticket SET Status='CONFIRMED' WHERE OrderId=? AND Status='HOLD'";
        try (Connection c = getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Thu hồi ghế khi đơn bị huỷ
     */
    public boolean releaseHeldSeats(int orderId) throws SQLException, ClassNotFoundException {
        String sql = "DELETE FROM Ticket WHERE OrderId=? AND Status='HOLD'";
        try (Connection c = getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Dọn vé HOLD của các đơn đã CANCELLED (tiện cho cron)
     */
    public int cleanupHoldOfCancelled() throws SQLException, ClassNotFoundException {
        String sql
                = "DELETE t FROM Ticket t "
                + "JOIN Orders o ON o.Id = t.OrderId "
                + "WHERE o.Status='CANCELLED' AND t.Status='HOLD'";
        try (Connection c = getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            return ps.executeUpdate();
        }
    }

    public java.util.Set<Integer> getOccupiedSeatIdsForSchedule(int scheduleId)
            throws SQLException, ClassNotFoundException {
        String sql
                = "SELECT DISTINCT t.SeatId "
                + "FROM Ticket t "
                + "JOIN Orders o ON o.Id = t.OrderId "
                + "WHERE t.ScheduleId = ? "
                + "AND ( t.Status='CONFIRMED' "
                + "   OR (t.Status='HOLD' AND o.Status='PENDING' AND o.ExpiredAt > GETDATE()) )";
        java.util.Set<Integer> ids = new java.util.HashSet<>();
        try (Connection c = getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ids.add(rs.getInt(1));
                }
            }
        }
        return ids;
    }
    
    /**
     * Validate seats are available for booking
     * @param scheduleId Schedule ID
     * @param seatIds List of seat IDs to validate
     * @return List of occupied seat IDs (empty if all available)
     */
    public java.util.List<Integer> validateSeatsAvailable(int scheduleId, List<Integer> seatIds) {
        java.util.List<Integer> occupiedSeats = new java.util.ArrayList<>();
        if (seatIds == null || seatIds.isEmpty()) {
            return occupiedSeats;
        }
        
        String sql = "SELECT DISTINCT t.SeatId "
                + "FROM Ticket t "
                + "JOIN Orders o ON o.Id = t.OrderId "
                + "WHERE t.ScheduleId = ? AND t.SeatId IN ("
                + String.join(",", java.util.Collections.nCopies(seatIds.size(), "?"))
                + ") "
                + "AND ( t.Status='CONFIRMED' "
                + "   OR (t.Status='HOLD' AND o.Status='PENDING' AND o.ExpiredAt > GETDATE()) )";
        
        try (Connection c = getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            for (int i = 0; i < seatIds.size(); i++) {
                ps.setInt(i + 2, seatIds.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    occupiedSeats.add(rs.getInt(1));
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ SQL Error validating seats: " + e.getMessage());
            System.err.println("   SQL State: " + e.getSQLState());
            System.err.println("   Error Code: " + e.getErrorCode());
            // Log full stack trace để debug
            if (e.getMessage() != null && (e.getMessage().contains("Invalid column name") 
                    || e.getMessage().contains("column") || e.getMessage().contains("Column"))) {
                System.err.println("⚠️ Possible database schema mismatch! Check if columns 'OrderId' in Ticket and 'ExpiredAt' in Orders exist.");
            }
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("Error validating seats: " + e.getMessage());
            e.printStackTrace();
        }
        return occupiedSeats;
    }
    
    /**
     * Calculate seat price from server (Schedule.price + SeatType.surcharge)
     * @param scheduleId Schedule ID
     * @param seatId Seat ID
     * @return Seat price, or -1 if error
     */
    public long calculateSeatPrice(int scheduleId, int seatId) {
        // Get schedule price and roomId
        String sql1 = "SELECT Price, RoomId FROM Schedule WHERE Id = ?";
        double schedulePrice = 0;
        int roomId = 0;
        
        try (Connection c = getConnection(); PreparedStatement ps = c.prepareStatement(sql1)) {
            ps.setInt(1, scheduleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    schedulePrice = rs.getDouble("Price");
                    roomId = rs.getInt("RoomId");
                } else {
                    return -1; // Schedule not found
                }
            }
        } catch (Exception e) {
            System.err.println("Error getting schedule: " + e.getMessage());
            e.printStackTrace();
            return -1;
        }
        
        // Get seat surcharge
        String sql2 = "SELECT ISNULL(st.Surcharge, 0) as seatSurcharge "
                + "FROM Seat se "
                + "LEFT JOIN SeatType st ON se.SeatTypeId = st.Id "
                + "WHERE se.Id = ? AND se.RoomId = ?";
        
        double seatSurcharge = 0;
        try (Connection c = getConnection(); PreparedStatement ps = c.prepareStatement(sql2)) {
            ps.setInt(1, seatId);
            ps.setInt(2, roomId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    seatSurcharge = rs.getDouble("seatSurcharge");
                } else {
                    return -1; // Seat not found or not in this room
                }
            }
        } catch (Exception e) {
            System.err.println("Error getting seat surcharge: " + e.getMessage());
            e.printStackTrace();
            return -1;
        }
        
        return Math.round(schedulePrice + seatSurcharge);
    }
    
    /**
     * Calculate total seat price for multiple seats
     * @param scheduleId Schedule ID
     * @param seatIds List of seat IDs
     * @return Total price, or -1 if error
     */
    public long calculateTotalSeatPrice(int scheduleId, List<Integer> seatIds) {
        if (seatIds == null || seatIds.isEmpty()) {
            return 0;
        }
        
        long total = 0;
        for (Integer seatId : seatIds) {
            long price = calculateSeatPrice(scheduleId, seatId);
            if (price < 0) {
                return -1; // Error
            }
            total += price;
        }
        return total;
    }
    
    /**
     * Hold seats for order using existing connection (for transaction)
     */
    public boolean holdSeatsForOrder(Connection conn, int orderId, int scheduleId, 
                                      List<Integer> seatIds, List<Long> seatPrices) throws SQLException {
        if (seatIds == null || seatIds.isEmpty()) {
            return true;
        }
        
        if (seatPrices == null || seatPrices.size() != seatIds.size()) {
            throw new SQLException("seatIds and seatPrices must have same length");
        }
        
        String insert = "INSERT INTO Ticket (Code, Status, Price, ScheduleId, SeatId, OrderId, CreatedAt) "
                + "VALUES (?, 'HOLD', ?, ?, ?, ?, GETDATE())";
        
        try (PreparedStatement ps = conn.prepareStatement(insert)) {
            for (int i = 0; i < seatIds.size(); i++) {
                Integer seatId = seatIds.get(i);
                // Validate seat is not busy
                if (isSeatBusy(conn, scheduleId, seatId)) {
                    throw new SQLException("Seat " + seatId + " is already held/paid");
                }
                String code = "T" + System.currentTimeMillis() + "-" + seatId;
                ps.setString(1, code);
                ps.setLong(2, seatPrices.get(i));
                ps.setInt(3, scheduleId);
                ps.setInt(4, seatId);
                ps.setInt(5, orderId);
                ps.addBatch();
            }
            ps.executeBatch();
            return true;
        }
    }
    
    /**
     * Debug method: Get seat status information for a specific seat
     * This method uses the same logic as isSeatBusy but returns detailed information
     * @param scheduleId Schedule ID
     * @param seatId Seat ID
     * @return String with seat status information, or null if seat is available
     */
    public String getSeatStatusInfo(int scheduleId, int seatId) {
        String sql = "SELECT t.Id as TicketId, t.Status as TicketStatus, t.Code as TicketCode, "
                + "o.Id as OrderId, o.Status as OrderStatus, o.OrderCode, o.ExpiredAt, "
                + "o.OrderDate, u.Id as UserId "
                + "FROM Ticket t "
                + "JOIN Orders o ON o.Id = t.OrderId "
                + "LEFT JOIN Users u ON u.Id = o.UserId "
                + "WHERE t.ScheduleId = ? AND t.SeatId = ? "
                + "AND ( t.Status = 'CONFIRMED' "
                + "   OR (t.Status = 'HOLD' AND o.Status = 'PENDING' AND o.ExpiredAt > GETDATE()) )";
        
        try (Connection c = getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            ps.setInt(2, seatId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    StringBuilder info = new StringBuilder();
                    info.append("Seat ").append(seatId).append(" is ");
                    info.append("Status: ").append(rs.getString("TicketStatus")).append(", ");
                    info.append("OrderId: ").append(rs.getInt("OrderId")).append(", ");
                    info.append("OrderStatus: ").append(rs.getString("OrderStatus")).append(", ");
                    info.append("OrderCode: ").append(rs.getString("OrderCode"));
                    if (rs.getTimestamp("ExpiredAt") != null) {
                        info.append(", ExpiredAt: ").append(rs.getTimestamp("ExpiredAt"));
                    }
                    return info.toString();
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ SQL Error getting seat status info: " + e.getMessage());
            System.err.println("   SQL State: " + e.getSQLState());
            System.err.println("   Error Code: " + e.getErrorCode());
            // Log full stack trace để debug
            if (e.getMessage() != null && (e.getMessage().contains("Invalid column name") 
                    || e.getMessage().contains("column") || e.getMessage().contains("Column"))) {
                System.err.println("⚠️ Possible database schema mismatch! Check if columns exist in Ticket and Orders tables.");
                System.err.println("   Expected columns: Ticket.OrderId, Orders.ExpiredAt");
            }
            e.printStackTrace();
            return "SQL Error: " + e.getMessage();
        } catch (Exception e) {
            System.err.println("Error getting seat status info: " + e.getMessage());
            e.printStackTrace();
            return "Error: " + e.getMessage();
        }
        return null; // Seat is available
    }
    
    /**
     * Get order ID and user ID that is holding a specific seat
     * @param scheduleId Schedule ID
     * @param seatId Seat ID
     * @return Array with [orderId, userId], or null if seat is not held
     */
    public int[] getSeatHoldingOrderInfo(int scheduleId, int seatId) {
        String sql = "SELECT o.Id as OrderId, o.UserId "
                + "FROM Ticket t "
                + "JOIN Orders o ON o.Id = t.OrderId "
                + "WHERE t.ScheduleId = ? AND t.SeatId = ? "
                + "AND ( t.Status = 'CONFIRMED' "
                + "   OR (t.Status = 'HOLD' AND o.Status = 'PENDING' AND o.ExpiredAt > GETDATE()) )";
        
        try (Connection c = getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            ps.setInt(2, seatId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int orderId = rs.getInt("OrderId");
                    int userId = rs.getInt("UserId");
                    return new int[]{orderId, userId};
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting seat holding order info: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("Error getting seat holding order info: " + e.getMessage());
            e.printStackTrace();
        }
        return null; // Seat is not held
    }
    
    /**
     * Cancel a specific order and release its held seats
     * @param orderId Order ID to cancel
     * @return true if successful
     */
    public boolean cancelOrderAndReleaseSeats(int orderId) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            // Release held seats
            String deleteTickets = "DELETE FROM Ticket WHERE OrderId = ? AND Status = 'HOLD'";
            try (PreparedStatement ps = conn.prepareStatement(deleteTickets)) {
                ps.setInt(1, orderId);
                ps.executeUpdate();
            }
            
            // Cancel order
            String cancelOrder = "UPDATE Orders SET Status = 'CANCELLED' WHERE Id = ?";
            try (PreparedStatement ps = conn.prepareStatement(cancelOrder)) {
                ps.setInt(1, orderId);
                ps.executeUpdate();
            }
            
            conn.commit();
            return true;
        } catch (SQLException e) {
            System.err.println("Error canceling order and releasing seats: " + e.getMessage());
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            return false;
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
    }
}
