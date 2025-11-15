package dal;

import model.Room;
import util.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RoomDAO extends DBContext {

    // ===== CRUD OPERATIONS =====
    // GET ALL ROOMS (for admin)
    public List<Room> getAllRooms() {
        List<Room> list = new ArrayList<>();
        String sql = "SELECT r.*, c.Name as cinema_name, c.Code as cinema_code "
                + "FROM Room r "
                + "INNER JOIN Cinema c ON r.CinemaId = c.Id "
                + "ORDER BY c.Name, r.Name";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapResultSetToRoom(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // GET ROOMS BY CINEMA ID (for staff)
    public List<Room> getRoomsByCinemaId(int cinemaId) {
        List<Room> list = new ArrayList<>();
        String sql = "SELECT r.*, c.Name as cinema_name, c.Code as cinema_code "
                + "FROM Room r "
                + "INNER JOIN Cinema c ON r.CinemaId = c.Id "
                + "WHERE r.CinemaId = ? "
                + "ORDER BY r.Name";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, cinemaId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToRoom(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // GET ACTIVE ROOMS BY CINEMA ID
    public List<Room> getActiveRoomsByCinemaId(int cinemaId) {
        List<Room> list = new ArrayList<>();
        String sql = "SELECT r.*, c.Name as cinema_name, c.Code as cinema_code "
                + "FROM Room r "
                + "INNER JOIN Cinema c ON r.CinemaId = c.Id "
                + "WHERE r.CinemaId = ? AND r.Status = 1 "
                + "ORDER BY r.Name";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, cinemaId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToRoom(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
    // ===== Lấy số phòng đang hoạt động / tổng số phòng theo staff =====
public int[] getRoomUsageByStaff(int staffId) {
    String sql = """
        SELECT 
            SUM(CASE WHEN r.Status = 1 THEN 1 ELSE 0 END) AS ActiveRooms,
            COUNT(*) AS TotalRooms
        FROM Room r
        JOIN Cinema c ON r.CinemaId = c.Id
        JOIN Cinema_Staff cs ON c.Id = cs.cinema_id
        WHERE cs.staff_id = ? AND cs.status = 1
    """;

    try (Connection conn = getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {

        ps.setInt(1, staffId);

        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                int activeRooms = rs.getInt("ActiveRooms");
                int totalRooms = rs.getInt("TotalRooms");
                return new int[]{activeRooms, totalRooms};
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return new int[]{0, 0};
}


    // GET ROOM BY ID
    public Room getRoomById(int id) {
        String sql = "SELECT r.*, c.Name as cinema_name, c.Code as cinema_code "
                + "FROM Room r "
                + "INNER JOIN Cinema c ON r.CinemaId = c.Id "
                + "WHERE r.Id = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToRoom(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // CREATE ROOM
    public boolean addRoom(Room room) {
        String sql = "INSERT INTO Room (CinemaId, Code, Name, Description, Capacity, SeatRows, SeatColumns, ScreenType, SoundSystem, Status, CreatedDate, UpdatedDate) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, room.getCinemaId());
            ps.setString(2, room.getCode());
            ps.setString(3, room.getName());
            ps.setString(4, room.getDescription());
            ps.setInt(5, room.getCapacity());
            ps.setInt(6, room.getSeatRows());
            ps.setInt(7, room.getSeatColumns());
            ps.setString(8, room.getScreenType());
            ps.setString(9, room.getSoundSystem());
            ps.setBoolean(10, room.isStatus());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // UPDATE ROOM
    public boolean updateRoom(Room room) {
        String sql = "UPDATE Room SET Code = ?, Name = ?, Description = ?, Capacity = ?, "
                + "SeatRows = ?, SeatColumns = ?, ScreenType = ?, SoundSystem = ?, Status = ?, "
                + "UpdatedDate = GETDATE() WHERE Id = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, room.getCode());
            ps.setString(2, room.getName());
            ps.setString(3, room.getDescription());
            ps.setInt(4, room.getCapacity());
            ps.setInt(5, room.getSeatRows());
            ps.setInt(6, room.getSeatColumns());
            ps.setString(7, room.getScreenType());
            ps.setString(8, room.getSoundSystem());
            ps.setBoolean(9, room.isStatus());
            ps.setInt(10, room.getId());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // DELETE ROOM (soft delete)
    public boolean deleteRoom(int id) {
        String sql = "UPDATE Room SET Status = 0, UpdatedDate = GETDATE() WHERE Id = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ===== VALIDATION METHODS =====
    public boolean isCodeExists(String code, int cinemaId) {
        String sql = "SELECT COUNT(*) FROM Room WHERE Code = ? AND CinemaId = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, code);
            ps.setInt(2, cinemaId);
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

    public boolean isCodeExists(String code, int cinemaId, int excludeId) {
        String sql = "SELECT COUNT(*) FROM Room WHERE Code = ? AND CinemaId = ? AND Id != ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, code);
            ps.setInt(2, cinemaId);
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

    // SEARCH ROOMS
    public List<Room> searchRooms(String keyword, int cinemaId) {
        List<Room> list = new ArrayList<>();
        String sql = "SELECT r.*, c.Name as cinema_name, c.Code as cinema_code "
                + "FROM Room r "
                + "INNER JOIN Cinema c ON r.CinemaId = c.Id "
                + "WHERE r.CinemaId = ? AND (r.Code LIKE ? OR r.Name LIKE ? OR r.ScreenType LIKE ?) "
                + "ORDER BY r.Name";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            String searchPattern = "%" + keyword + "%";
            ps.setInt(1, cinemaId);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            ps.setString(4, searchPattern);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToRoom(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // GET ROOMS BY SCREEN TYPE
    public List<Room> getRoomsByScreenType(String screenType, int cinemaId) {
        List<Room> list = new ArrayList<>();
        String sql = "SELECT r.*, c.Name as cinema_name, c.Code as cinema_code "
                + "FROM Room r "
                + "INNER JOIN Cinema c ON r.CinemaId = c.Id "
                + "WHERE r.CinemaId = ? AND r.ScreenType = ? "
                + "ORDER BY r.Name";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, cinemaId);
            ps.setString(2, screenType);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToRoom(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ===== HELPER METHOD =====
    private Room mapResultSetToRoom(ResultSet rs) throws SQLException {
        Room room = new Room();
        room.setId(rs.getInt("Id"));
        room.setCinemaId(rs.getInt("CinemaId"));
        room.setCode(rs.getString("Code"));
        room.setName(rs.getString("Name"));
        room.setDescription(rs.getString("Description"));
        room.setCapacity(rs.getInt("Capacity"));
        room.setSeatRows(rs.getInt("SeatRows"));
        room.setSeatColumns(rs.getInt("SeatColumns"));
        room.setScreenType(rs.getString("ScreenType"));
        room.setSoundSystem(rs.getString("SoundSystem"));
        room.setStatus(rs.getBoolean("Status"));
        room.setCreatedDate(rs.getTimestamp("CreatedDate"));
        room.setUpdatedDate(rs.getTimestamp("UpdatedDate"));

        // Thông tin từ join
        room.setCinemaName(rs.getString("cinema_name"));
        room.setCinemaCode(rs.getString("cinema_code"));

        return room;
    }
}


