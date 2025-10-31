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
}
