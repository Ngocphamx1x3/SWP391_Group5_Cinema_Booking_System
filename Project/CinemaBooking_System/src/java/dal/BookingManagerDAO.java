package dal;

import util.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.Booking;

public class BookingManagerDAO extends DBContext {

    public List<Booking> getAllBookingsByStaff(int staffId, String search, String statusFilter, String dateFilter, int page, int pageSize) {
        List<Booking> bookings = new ArrayList<>();
        
        // Sửa query để lấy đúng dữ liệu
        String sql = "SELECT DISTINCT " +
                    "t.Code AS ticket_code, " +
                    "u.Username AS customer_name, " +
                    "u.Email AS customer_email, " +
                    "u.PhoneNumber AS customer_phone, " +
                    "m.Name AS movie_name, " +
                    "s.StartAt AS showtime, " +
                    "o.TotalMoney AS total_amount, " +
                    "o.Status AS order_status, " +
                    "o.OrderDate AS order_date, " +
                    "r.Name AS room_name, " +
                    "c.Name AS cinema_name " +
                    "FROM Orders o " +
                    "INNER JOIN Ticket t ON o.Id = t.OrderId " +
                    "INNER JOIN Users u ON o.UserId = u.Id " +
                    "INNER JOIN Schedule s ON t.ScheduleId = s.Id " +
                    "INNER JOIN Movie m ON s.MovieId = m.Id " +
                    "INNER JOIN Seat st ON t.SeatId = st.Id " +
                    "INNER JOIN Room r ON st.RoomId = r.Id " +
                    "INNER JOIN Cinema c ON r.CinemaId = c.Id " +
                    "WHERE c.Id IN (SELECT current_cinema_id FROM Users WHERE Id = ?) ";
        
        // Thêm điều kiện tìm kiếm
        if (search != null && !search.trim().isEmpty()) {
            sql += "AND (u.Username LIKE ? OR u.Email LIKE ? OR m.Name LIKE ? OR t.Code LIKE ?) ";
        }
        
        // Thêm điều kiện filter status
        // Thêm điều kiện filter status
if (statusFilter != null && !statusFilter.isEmpty() && !"ALL".equals(statusFilter)) {
    sql += "AND o.Status = ? ";
}
        
        // Thêm điều kiện filter date
        if (dateFilter != null && !dateFilter.isEmpty()) {
            sql += "AND CAST(o.OrderDate AS DATE) = ? ";
        }
        
        sql += "ORDER BY o.OrderDate DESC " +
               "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        
        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            int paramIndex = 1;
            ps.setInt(paramIndex++, staffId);
            
            // Set search parameters
            if (search != null && !search.trim().isEmpty()) {
                String searchPattern = "%" + search + "%";
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
            }
            
            // Set status filter
            if (statusFilter != null && !statusFilter.isEmpty() && !"ALL".equals(statusFilter)) {
                ps.setString(paramIndex++, statusFilter);
            }
            
            // Set date filter
            if (dateFilter != null && !dateFilter.isEmpty()) {
                ps.setString(paramIndex++, dateFilter);
            }
            
            // Set pagination parameters
            int offset = (page - 1) * pageSize;
            ps.setInt(paramIndex++, offset);
            ps.setInt(paramIndex, pageSize);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String ticketCode = rs.getString("ticket_code");
                    
                    // Kiểm tra xem booking đã tồn tại chưa
                    Booking existingBooking = findBookingByTicketCode(bookings, ticketCode);
                    
                    if (existingBooking == null) {
                        // Tạo booking mới
                        Booking booking = new Booking();
                        booking.setTicketCode(ticketCode);
                        booking.setCustomerName(rs.getString("customer_name"));
                        booking.setCustomerEmail(rs.getString("customer_email"));
                        booking.setCustomerPhone(rs.getString("customer_phone"));
                        booking.setMovieName(rs.getString("movie_name"));
                        
                        java.sql.Timestamp timestamp = rs.getTimestamp("showtime");
                        booking.setShowtime(timestamp != null ? new java.util.Date(timestamp.getTime()) : null);
                        
                        booking.setTotalAmount(rs.getDouble("total_amount"));
                        booking.setStatus(rs.getString("order_status"));
                        
                        java.sql.Timestamp orderDateTimestamp = rs.getTimestamp("order_date");
                        booking.setOrderDate(orderDateTimestamp != null ? new java.util.Date(orderDateTimestamp.getTime()) : null);
                        
                        booking.setRoomName(rs.getString("room_name"));
                        booking.setCinemaName(rs.getString("cinema_name"));
                        
                        // Lấy danh sách ghế
                        List<String> seats = getSeatsByTicketCode(ticketCode);
                        booking.setSeats(seats);
                        
                        bookings.add(booking);
                    }
                }
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return bookings;
    }
    
    // Helper method để tìm booking theo ticket code
    private Booking findBookingByTicketCode(List<Booking> bookings, String ticketCode) {
        for (Booking booking : bookings) {
            if (booking.getTicketCode().equals(ticketCode)) {
                return booking;
            }
        }
        return null;
    }
    
    public int getTotalBookings(int staffId, String search, String statusFilter, String dateFilter) {
        String sql = "SELECT COUNT(DISTINCT t.Code) " +
                    "FROM Orders o " +
                    "INNER JOIN Ticket t ON o.Id = t.OrderId " +
                    "INNER JOIN Users u ON o.UserId = u.Id " +
                    "INNER JOIN Schedule s ON t.ScheduleId = s.Id " +
                    "INNER JOIN Movie m ON s.MovieId = m.Id " +
                    "INNER JOIN Seat st ON t.SeatId = st.Id " +
                    "INNER JOIN Room r ON st.RoomId = r.Id " +
                    "INNER JOIN Cinema c ON r.CinemaId = c.Id " +
                    "WHERE c.Id IN (SELECT current_cinema_id FROM Users WHERE Id = ?) ";
        
        // ... phần còn lại giữ nguyên
        if (search != null && !search.trim().isEmpty()) {
            sql += "AND (u.Username LIKE ? OR u.Email LIKE ? OR m.Name LIKE ? OR t.Code LIKE ?) ";
        }
        
        if (statusFilter != null && !statusFilter.isEmpty() && !"ALL".equals(statusFilter)) {
            sql += "AND o.Status = ? ";
        }
        
        if (dateFilter != null && !dateFilter.isEmpty()) {
            sql += "AND CAST(o.OrderDate AS DATE) = ? ";
        }
        
        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            int paramIndex = 1;
            ps.setInt(paramIndex++, staffId);
            
            if (search != null && !search.trim().isEmpty()) {
                String searchPattern = "%" + search + "%";
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
            }
            
            if (statusFilter != null && !statusFilter.isEmpty() && !"ALL".equals(statusFilter)) {
                ps.setString(paramIndex++, statusFilter);
            }
            
            if (dateFilter != null && !dateFilter.isEmpty()) {
                ps.setString(paramIndex, dateFilter);
            }
            
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
    
    private List<String> getSeatsByTicketCode(String ticketCode) {
        List<String> seats = new ArrayList<>();
        String sql = "SELECT st.Line + CAST(st.Number AS VARCHAR) AS seat " +
                    "FROM Ticket t " +
                    "INNER JOIN Seat st ON t.SeatId = st.Id " +
                    "WHERE t.Code = ?";
        
        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, ticketCode);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    seats.add(rs.getString("seat"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return seats;
    }
    
    // Thêm method này vào BookingManagerDAO
public Booking getBookingByTicketCode(String ticketCode, int staffId) {
    String sql = "SELECT DISTINCT " +
                "t.Code AS ticket_code, " +
                "u.Username AS customer_name, " +
                "u.Email AS customer_email, " +
                "u.PhoneNumber AS customer_phone, " +
                "m.Name AS movie_name, " +
                "s.StartAt AS showtime, " +
                "o.TotalMoney AS total_amount, " +
                "o.Status AS order_status, " +
                "o.OrderDate AS order_date, " +
                "r.Name AS room_name, " +
                "c.Name AS cinema_name " +
                "FROM Orders o " +
                "INNER JOIN Ticket t ON o.Id = t.OrderId " +
                "INNER JOIN Users u ON o.UserId = u.Id " +
                "INNER JOIN Schedule s ON t.ScheduleId = s.Id " +
                "INNER JOIN Movie m ON s.MovieId = m.Id " +
                "INNER JOIN Seat st ON t.SeatId = st.Id " +
                "INNER JOIN Room r ON st.RoomId = r.Id " +
                "INNER JOIN Cinema c ON r.CinemaId = c.Id " +
                "WHERE EXISTS ( " +
                "    SELECT 1 FROM Users staff " +
                "    WHERE staff.Id = ? AND staff.current_cinema_id = c.Id " +
                ") " +
                "AND t.Code = ?";
    
    try (Connection conn = getConnection(); 
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setInt(1, staffId);
        ps.setString(2, ticketCode);
        
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                Booking booking = new Booking();
                booking.setTicketCode(rs.getString("ticket_code"));
                booking.setCustomerName(rs.getString("customer_name"));
                booking.setCustomerEmail(rs.getString("customer_email"));
                booking.setCustomerPhone(rs.getString("customer_phone"));
                booking.setMovieName(rs.getString("movie_name"));
                
                java.sql.Timestamp timestamp = rs.getTimestamp("showtime");
                booking.setShowtime(timestamp != null ? new java.util.Date(timestamp.getTime()) : null);
                
                booking.setTotalAmount(rs.getDouble("total_amount"));
                booking.setStatus(rs.getString("order_status"));
                
                java.sql.Timestamp orderDateTimestamp = rs.getTimestamp("order_date");
                booking.setOrderDate(orderDateTimestamp != null ? new java.util.Date(orderDateTimestamp.getTime()) : null);
                
                booking.setRoomName(rs.getString("room_name"));
                booking.setCinemaName(rs.getString("cinema_name"));
                
                // Lấy danh sách ghế
                List<String> seats = getSeatsByTicketCode(ticketCode);
                booking.setSeats(seats);
                
                return booking;
            }
        }
        
    } catch (Exception e) {
        e.printStackTrace();
    }
    
    return null;
}
}