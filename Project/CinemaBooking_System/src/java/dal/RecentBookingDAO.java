package dal;

import util.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.RecentBooking;

public class RecentBookingDAO extends DBContext {

    public List<RecentBooking> getRecentBookingsByStaffCinema(int staffId, int limit) {
        List<RecentBooking> recentBookings = new ArrayList<>();
        
        String sql = "SELECT TOP (?) " +
                    "t.Code AS ticket_code, " +
                    "u.Username AS customer_name, " +
                    "m.Name AS movie_name, " +
                    "s.StartAt AS showtime, " +
                    "st.Line + CAST(st.Number AS VARCHAR) AS seat, " +
                    "o.TotalMoney AS total_amount, " +
                    "o.Status AS order_status " +
                    "FROM Ticket t " +
                    "INNER JOIN Orders o ON t.OrderId = o.Id " +
                    "INNER JOIN Users u ON o.UserId = u.Id " +
                    "INNER JOIN Schedule s ON t.ScheduleId = s.Id " +
                    "INNER JOIN Movie m ON s.MovieId = m.Id " +
                    "INNER JOIN Seat st ON t.SeatId = st.Id " +
                    "INNER JOIN Room r ON st.RoomId = r.Id " +
                    "INNER JOIN Cinema c ON r.CinemaId = c.Id " +
                    "INNER JOIN Users staff ON staff.current_cinema_id = c.Id " +
                    "WHERE staff.Id = ? " +
                    "AND o.OrderDate >= DATEADD(DAY, -7, GETDATE()) " +
                    "ORDER BY o.OrderDate DESC, t.Code ASC";
        
        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, limit);
            ps.setInt(2, staffId);
            
            try (ResultSet rs = ps.executeQuery()) {
                // Sử dụng map tạm để nhóm các ghế cùng vé
                java.util.Map<String, RecentBooking> bookingMap = new java.util.LinkedHashMap<>();
                
                while (rs.next()) {
                    String ticketCode = rs.getString("ticket_code");
                    String customerName = rs.getString("customer_name");
                    String movieName = rs.getString("movie_name");
                    
                    // SỬA Ở ĐÂY: Chuyển Timestamp sang Date
                    java.sql.Timestamp timestamp = rs.getTimestamp("showtime");
                    java.util.Date showtime = timestamp != null ? new java.util.Date(timestamp.getTime()) : null;
                    
                    String seat = rs.getString("seat");
                    double totalAmount = rs.getDouble("total_amount");
                    String orderStatus = rs.getString("order_status");
                    
                    // Nếu vé chưa có trong map, tạo mới
                    if (!bookingMap.containsKey(ticketCode)) {
                        RecentBooking booking = new RecentBooking();
                        booking.setTicketCode(ticketCode);
                        booking.setCustomerName(customerName);
                        booking.setMovieName(movieName);
                        booking.setShowtime(showtime);
                        booking.setTotalAmount(totalAmount);
                        booking.setStatus(orderStatus);
                        booking.setSeats(new ArrayList<>());
                        
                        bookingMap.put(ticketCode, booking);
                    }
                    
                    // Thêm ghế vào danh sách ghế của vé
                    RecentBooking booking = bookingMap.get(ticketCode);
                    booking.getSeats().add(seat);
                }
                
                // Chuyển từ map sang list
                recentBookings.addAll(bookingMap.values());
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return recentBookings;
    }
    
    // Alternative method với cách tiếp cận khác
    public List<RecentBooking> getRecentBookingsByCinema(int cinemaId, int limit) {
        List<RecentBooking> recentBookings = new ArrayList<>();
        
        String sql = "WITH RecentTickets AS ( " +
                    "SELECT DISTINCT " +
                    "t.Code AS ticket_code, " +
                    "u.Username AS customer_name, " +
                    "m.Name AS movie_name, " +
                    "s.StartAt AS showtime, " +
                    "o.TotalMoney AS total_amount, " +
                    "o.Status AS order_status " +
                    "FROM Ticket t " +
                    "INNER JOIN Orders o ON t.OrderId = o.Id " +
                    "INNER JOIN Users u ON o.UserId = u.Id " +
                    "INNER JOIN Schedule s ON t.ScheduleId = s.Id " +
                    "INNER JOIN Movie m ON s.MovieId = m.Id " +
                    "INNER JOIN Seat st ON t.SeatId = st.Id " +
                    "INNER JOIN Room r ON st.RoomId = r.Id " +
                    "WHERE r.CinemaId = ? " +
                    "AND o.OrderDate >= DATEADD(DAY, -7, GETDATE()) " +
                    ") " +
                    "SELECT TOP (?) rt.*, " +
                    "STUFF(( " +
                    "    SELECT ', ' + st.Line + CAST(st.Number AS VARCHAR) " +
                    "    FROM Ticket t2 " +
                    "    INNER JOIN Seat st ON t2.SeatId = st.Id " +
                    "    WHERE t2.Code = rt.ticket_code " +
                    "    FOR XML PATH('') " +
                    "), 1, 2, '') AS seats " +
                    "FROM RecentTickets rt " +
                    "ORDER BY rt.showtime DESC";
        
        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, cinemaId);
            ps.setInt(2, limit);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String ticketCode = rs.getString("ticket_code");
                    String customerName = rs.getString("customer_name");
                    String movieName = rs.getString("movie_name");
                    
                    // SỬA Ở ĐÂY: Chuyển Timestamp sang Date
                    java.sql.Timestamp timestamp = rs.getTimestamp("showtime");
                    java.util.Date showtime = timestamp != null ? new java.util.Date(timestamp.getTime()) : null;
                    
                    String seatsStr = rs.getString("seats");
                    double totalAmount = rs.getDouble("total_amount");
                    String orderStatus = rs.getString("order_status");
                    
                    // Parse seats string to list
                    List<String> seats = new ArrayList<>();
                    if (seatsStr != null && !seatsStr.isEmpty()) {
                        String[] seatArray = seatsStr.split(", ");
                        for (String seat : seatArray) {
                            seats.add(seat);
                        }
                    }
                    
                    RecentBooking booking = new RecentBooking(
                        ticketCode, customerName, movieName, showtime, 
                        seats, totalAmount, orderStatus
                    );
                    
                    recentBookings.add(booking);
                }
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return recentBookings;
    }
}