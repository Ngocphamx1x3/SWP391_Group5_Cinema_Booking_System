package dal;

import model.Seat;
import model.SeatType;
import util.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class SeatDesignDAO extends DBContext {

    // GET ALL SEATS BY ROOM ID
    public List<Seat> getSeatsByRoomId(int roomId) {
        System.out.println("🪑 SeatDesignDAO.getSeatsByRoomId() called for room: " + roomId);

        List<Seat> list = new ArrayList<>();
        String sql = "SELECT s.*, st.color as type_color, st.name as type_name, st.surcharge as type_surcharge "
                + "FROM Seat s "
                + "LEFT JOIN SeatType st ON s.SeatTypeId = st.Id "
                + "WHERE s.RoomId = ? "
                + "ORDER BY s.position_y, s.position_x";

        System.out.println("📝 SQL: " + sql);

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roomId);
            System.out.println("🔧 Set parameter: roomId = " + roomId);

            try (ResultSet rs = ps.executeQuery()) {
                int count = 0;
                while (rs.next()) {
                    count++;
                    Seat seat = mapResultSetToSeat(rs);
                    list.add(seat);

                    if (count <= 3) { // Log 3 ghế đầu tiên để debug
                        System.out.println("   🪑 Seat " + count + ": " + seat.getCode()
                                + " - Type: " + seat.getTypeName()
                                + " - Position: " + seat.getPositionX() + "," + seat.getPositionY()
                                + " - Color: " + seat.getCustomColor());
                    }
                }
                System.out.println("✅ Total seats found: " + count);
            }
        } catch (Exception e) {
            System.out.println("💥 Error in getSeatsByRoomId: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    // GET ROOM LAYOUT INFORMATION
    public Map<String, Object> getRoomLayout(int roomId) {
        Map<String, Object> layout = new HashMap<>();
        String sql = "SELECT Id, CinemaId, Code, Name, SeatRows, SeatColumns, Capacity, ScreenType "
                + "FROM Room WHERE Id = ?";

        System.out.println("Executing SQL: " + sql + " with roomId: " + roomId);

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roomId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    layout.put("id", rs.getInt("Id"));
                    layout.put("cinemaId", rs.getInt("CinemaId"));
                    layout.put("code", rs.getString("Code"));
                    layout.put("name", rs.getString("Name"));
                    layout.put("rows", rs.getInt("SeatRows"));
                    layout.put("columns", rs.getInt("SeatColumns"));
                    layout.put("capacity", rs.getInt("Capacity"));
                    layout.put("screenType", rs.getString("ScreenType"));
                    System.out.println("Room layout loaded: " + layout);
                } else {
                    System.out.println("No room found with id: " + roomId);
                }
            }
        } catch (Exception e) {
            System.err.println("Error in getRoomLayout: " + e.getMessage());
            e.printStackTrace();
        }
        return layout;
    }

    // SAVE SEAT DESIGN (DELETE OLD AND INSERT NEW)
    public boolean saveSeatDesign(int roomId, List<Seat> seats) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            System.out.println("🗑️ Deleting old seats for room: " + roomId);

            // DELETE OLD SEATS
            String deleteSql = "DELETE FROM Seat WHERE RoomId = ?";
            try (PreparedStatement deletePs = conn.prepareStatement(deleteSql)) {
                deletePs.setInt(1, roomId);
                int deletedRows = deletePs.executeUpdate();
                System.out.println("✅ Deleted " + deletedRows + " old seats");
            }

            // SỬA SQL INSERT - XÓA price VÀ created_at
            String insertSql = "INSERT INTO Seat (Code, Description, Line, Number, Status, "
                    + "RoomId, SeatTypeId, row_code, column_number, position, "
                    + "is_available, position_x, position_y, width_units, "
                    + "height_units, is_draggable, custom_color) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            System.out.println("📝 Inserting " + seats.size() + " new seats...");

            try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                for (Seat seat : seats) {
                    insertPs.setString(1, seat.getCode());
                    insertPs.setString(2, seat.getDescription());
                    insertPs.setString(3, seat.getLine());
                    insertPs.setInt(4, seat.getNumber());
                    insertPs.setBoolean(5, seat.isStatus());
                    insertPs.setInt(6, roomId);
                    insertPs.setInt(7, seat.getSeatTypeId());
                    insertPs.setString(8, seat.getRowCode());
                    insertPs.setInt(9, seat.getColumnNumber());
                    insertPs.setString(10, seat.getPosition());
                    insertPs.setBoolean(11, seat.isAvailable());
                    insertPs.setInt(12, seat.getPositionX());
                    insertPs.setInt(13, seat.getPositionY());
                    insertPs.setInt(14, seat.getWidthUnits());
                    insertPs.setInt(15, seat.getHeightUnits());
                    insertPs.setBoolean(16, seat.isDraggable());
                    insertPs.setString(17, seat.getCustomColor());
                    insertPs.addBatch();

                    System.out.println("➡️ Seat: " + seat.getCode() + " - Type: " + seat.getSeatTypeId());
                }
                int[] results = insertPs.executeBatch();
                System.out.println("✅ Inserted " + results.length + " seats successfully");
            }

            conn.commit();
            System.out.println("🎉 Transaction committed successfully!");
            return true;

        } catch (Exception e) {
            System.err.println("💥 ERROR in DAO saveSeatDesign: " + e.getMessage());
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                    System.out.println("🔁 Transaction rolled back");
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

    // GENERATE DEFAULT SEATS LAYOUT
    public boolean createDefaultSeats(int roomId, int rows, int columns) {
        List<Seat> defaultSeats = new ArrayList<>();

        // SỬA: Generate row letters dynamic
        String[] rowLetters = generateRowLetters(rows);

        int seatCount = 0;
        for (int y = 0; y < rows; y++) {
            for (int x = 0; x < columns; x++) {
                if (seatCount >= rows * columns) {
                    break;
                }

                Seat seat = new Seat();
                seat.setCode(rowLetters[y] + (x + 1));
                seat.setLine(rowLetters[y]);
                seat.setNumber(x + 1);
                seat.setStatus(true);
                seat.setRoomId(roomId);
                seat.setSeatTypeId(1); // STANDARD as default
                seat.setRowCode(rowLetters[y]);
                seat.setColumnNumber(x + 1);
                seat.setPosition(x + "," + y);
                seat.setAvailable(true);
                seat.setPositionX(x);
                seat.setPositionY(y);
                seat.setWidthUnits(1);
                seat.setHeightUnits(1);
                seat.setDraggable(true);
                seat.setCustomColor("#1e90ff"); // Standard blue color

                defaultSeats.add(seat);
                seatCount++;
            }
        }

        return saveSeatDesign(roomId, defaultSeats);
    }

// THÊM: Helper method để generate row letters
    private String[] generateRowLetters(int numRows) {
        String[] rowLetters = new String[numRows];
        for (int i = 0; i < numRows; i++) {
            if (i < 26) {
                // A-Z
                rowLetters[i] = String.valueOf((char) ('A' + i));
            } else {
                // AA, AB, AC, ... BA, BB, ...
                int firstIndex = (i - 26) / 26;
                int secondIndex = (i - 26) % 26;
                rowLetters[i] = String.valueOf((char) ('A' + firstIndex))
                        + String.valueOf((char) ('A' + secondIndex));
            }
        }
        return rowLetters;
    }

    // GET SEAT BY ID
    public Seat getSeatById(int id) {
        String sql = "SELECT s.*, st.color as type_color, st.name as type_name, st.surcharge as type_surcharge "
                + "FROM Seat s "
                + "LEFT JOIN SeatType st ON s.SeatTypeId = st.Id "
                + "WHERE s.Id = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToSeat(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // UPDATE SINGLE SEAT - SỬA SQL XÓA price VÀ updated_at
    public boolean updateSeat(Seat seat) {
        String sql = "UPDATE Seat SET Code = ?, Description = ?, Line = ?, Number = ?, Status = ?, "
                + "SeatTypeId = ?, row_code = ?, column_number = ?, position = ?, " // XÓA price
                + "is_available = ?, position_x = ?, position_y = ?, width_units = ?, "
                + "height_units = ?, is_draggable = ?, custom_color = ? " // XÓA updated_at
                + "WHERE Id = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, seat.getCode());
            ps.setString(2, seat.getDescription());
            ps.setString(3, seat.getLine());
            ps.setInt(4, seat.getNumber());
            ps.setBoolean(5, seat.isStatus());
            ps.setInt(6, seat.getSeatTypeId());
            ps.setString(7, seat.getRowCode());
            ps.setInt(8, seat.getColumnNumber());
            ps.setString(9, seat.getPosition());
            // XÓA: ps.setDouble(10, seat.getPrice());
            ps.setBoolean(10, seat.isAvailable());
            ps.setInt(11, seat.getPositionX());
            ps.setInt(12, seat.getPositionY());
            ps.setInt(13, seat.getWidthUnits());
            ps.setInt(14, seat.getHeightUnits());
            ps.setBoolean(15, seat.isDraggable());
            ps.setString(16, seat.getCustomColor());
            ps.setInt(17, seat.getId());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // DELETE SEAT
    public boolean deleteSeat(int id) {
        String sql = "DELETE FROM Seat WHERE Id = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // CHECK IF SEAT CODE EXISTS IN ROOM
    public boolean isSeatCodeExists(String code, int roomId) {
        String sql = "SELECT COUNT(*) FROM Seat WHERE Code = ? AND RoomId = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, code);
            ps.setInt(2, roomId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // CHECK IF SEAT CODE EXISTS IN ROOM (EXCLUDE CURRENT SEAT)
    public boolean isSeatCodeExists(String code, int roomId, int excludeId) {
        String sql = "SELECT COUNT(*) FROM Seat WHERE Code = ? AND RoomId = ? AND Id != ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, code);
            ps.setInt(2, roomId);
            ps.setInt(3, excludeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // GET TOTAL SEATS COUNT BY ROOM
    public int getSeatCountByRoom(int roomId) {
        String sql = "SELECT COUNT(*) FROM Seat WHERE RoomId = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roomId);
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

    // GET SEATS BY TYPE IN ROOM
    public List<Seat> getSeatsByTypeInRoom(int roomId, int seatTypeId) {
        List<Seat> list = new ArrayList<>();
        String sql = "SELECT s.*, st.color as type_color, st.name as type_name, st.surcharge as type_surcharge "
                + "FROM Seat s "
                + "LEFT JOIN SeatType st ON s.SeatTypeId = st.Id "
                + "WHERE s.RoomId = ? AND s.SeatTypeId = ? "
                + "ORDER BY s.position_y, s.position_x";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roomId);
            ps.setInt(2, seatTypeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToSeat(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // SEARCH SEATS IN ROOM
    public List<Seat> searchSeatsInRoom(int roomId, String keyword) {
        List<Seat> list = new ArrayList<>();
        String sql = "SELECT s.*, st.color as type_color, st.name as type_name, st.surcharge as type_surcharge "
                + "FROM Seat s "
                + "LEFT JOIN SeatType st ON s.SeatTypeId = st.Id "
                + "WHERE s.RoomId = ? AND (s.Code LIKE ? OR s.Line LIKE ? OR s.row_code LIKE ?) "
                + "ORDER BY s.position_y, s.position_x";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            String searchPattern = "%" + keyword + "%";
            ps.setInt(1, roomId);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            ps.setString(4, searchPattern);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToSeat(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ===== HELPER METHOD =====
    private Seat mapResultSetToSeat(ResultSet rs) throws SQLException {
        Seat seat = new Seat();
        seat.setId(rs.getInt("Id"));
        seat.setCode(rs.getString("Code"));
        seat.setDescription(rs.getString("Description"));
        seat.setLine(rs.getString("Line"));
        seat.setNumber(rs.getInt("Number"));
        seat.setStatus(rs.getBoolean("Status"));
        seat.setRoomId(rs.getInt("RoomId"));
        seat.setSeatTypeId(rs.getInt("SeatTypeId"));
        seat.setRowCode(rs.getString("row_code"));
        seat.setColumnNumber(rs.getInt("column_number"));
        seat.setPosition(rs.getString("position"));
        // XÓA: seat.setPrice(rs.getDouble("price"));
        seat.setAvailable(rs.getBoolean("is_available"));
        seat.setPositionX(rs.getInt("position_x"));
        seat.setPositionY(rs.getInt("position_y"));
        seat.setWidthUnits(rs.getInt("width_units"));
        seat.setHeightUnits(rs.getInt("height_units"));
        seat.setDraggable(rs.getBoolean("is_draggable"));
        seat.setCustomColor(rs.getString("custom_color"));

        // Additional info from join
        if (hasColumn(rs, "type_color")) {
            seat.setTypeColor(rs.getString("type_color"));
        }
        if (hasColumn(rs, "type_name")) {
            seat.setTypeName(rs.getString("type_name"));
        }
        if (hasColumn(rs, "type_surcharge")) {
            seat.setTypeSurcharge(rs.getDouble("type_surcharge"));
        }

        return seat;
    }

    // Helper method to check if column exists in ResultSet
    private boolean hasColumn(ResultSet rs, String columnName) {
        try {
            rs.findColumn(columnName);
            return true;
        } catch (SQLException e) {
            return false;
        }
    }

    // THÊM METHOD MỚI ĐỂ TÍNH GIÁ ĐỘNG KHI CẦN
    public double calculateSeatPrice(double basePrice, int seatTypeId) {
        try {
            // Giả sử bạn có method để lấy SeatType by id
            // Nếu chưa có, cần tạo SeatTypeDAO với method getSeatTypeById
            SeatTypeDAO seatTypeDAO = new SeatTypeDAO();
            SeatType seatType = seatTypeDAO.getSeatTypeById(seatTypeId);

            if (seatType != null) {
                return basePrice + seatType.getSurcharge();
            }
        } catch (Exception e) {
            System.err.println("Error calculating seat price: " + e.getMessage());
        }
        return basePrice; // Fallback to base price if error
    }

    public boolean isSeatOccupied(int seatId, int scheduleId) {
        String sql = "SELECT COUNT(*) FROM Ticket t "
                + "INNER JOIN Schedule s ON t.ScheduleId = s.Id "
                + "WHERE t.SeatId = ? AND t.ScheduleId = ? "
                + "AND t.Status IN ( N'Đã thanh toán')";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, seatId);
            ps.setInt(2, scheduleId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            System.err.println("Error checking seat occupancy: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

// GET ALL OCCUPIED SEATS FOR A SCHEDULE
    public List<Integer> getOccupiedSeatIds(int scheduleId) throws Exception {
        String sql
                = "SELECT DISTINCT t.SeatId "
                + "FROM Ticket t "
                + "JOIN Orders o ON o.Id = t.OrderId "
                + "WHERE t.ScheduleId = ? "
                + "  AND ( t.Status = 'CONFIRMED' "
                + "     OR (t.Status = 'HOLD' AND o.Status = 'PENDING' AND o.ExpiredAt > GETDATE()) )";
        List<Integer> ids = new java.util.ArrayList<>();
        try (var c = new util.DBContext().getConnection(); var ps = c.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            try (var rs = ps.executeQuery()) {
                while (rs.next()) {
                    ids.add(rs.getInt(1));
                }
            }
        }
        System.out.println("🔒 [SeatDesignDAO] occupied seatIds for schedule " + scheduleId + ": " + ids);
        return ids;
    }
}
