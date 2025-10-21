package dal;

import model.Room;
import util.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RoomDAO extends DBContext {

    // ===== CRUD OPERATIONS =====
    public List<Room> getAllRooms() {
        List<Room> list = new ArrayList<>();
        String sql = "SELECT * FROM Room ORDER BY id";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapResultSetToRoom(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // GET ROOMS BY CINEMA ID
    public List<Room> getRoomsByCinemaId(int cinemaId) {
        List<Room> list = new ArrayList<>();
        String sql = "SELECT * FROM Room WHERE CinemaId = ? ORDER BY code";

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

    // GET ROOM BY ID
    public Room getRoomById(int id) {
        String sql = "SELECT * FROM Room WHERE id = ?";

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
        return room;
    }

    // ===== VALIDATION METHODS =====
    public boolean isCodeExists(String code) {
        String sql = "SELECT COUNT(*) FROM Room WHERE Code = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, code);
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

    public boolean isCodeExists(String code, int excludeId) {
        String sql = "SELECT COUNT(*) FROM Room WHERE Code = ? AND Id != ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, code);
            ps.setInt(2, excludeId);
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

    public boolean updateRoom(Room room) {
        String sql = "UPDATE Room SET CinemaId = ?, Code = ?, Name = ?, Description = ?, Capacity = ?, "
                + "SeatRows = ?, SeatColumns = ?, ScreenType = ?, SoundSystem = ?, Status = ?, "
                + "UpdatedDate = GETDATE() WHERE Id = ?";

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
            ps.setInt(11, room.getId());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

// DELETE ROOM (soft delete - update status to false)
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

// HARD DELETE (chỉ dùng khi thực sự cần)
    public boolean hardDeleteRoom(int id) {
        String sql = "DELETE FROM Room WHERE Id = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

// SEARCH ROOMS
    public List<Room> searchRooms(String keyword) {
        List<Room> list = new ArrayList<>();
        String sql = "SELECT r.* FROM Room r "
                + "INNER JOIN Cinema c ON r.CinemaId = c.Id "
                + "WHERE r.Code LIKE ? OR r.Name LIKE ? OR c.Name LIKE ? "
                + "ORDER BY r.Code";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);

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
}
