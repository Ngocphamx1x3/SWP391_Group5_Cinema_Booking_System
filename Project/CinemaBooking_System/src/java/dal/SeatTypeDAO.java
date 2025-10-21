package dal;

import model.SeatType;
import util.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SeatTypeDAO extends DBContext {

    // ===== CRUD OPERATIONS =====
    public List<SeatType> getAllSeatTypes() {
        List<SeatType> list = new ArrayList<>();
        String sql = "SELECT * FROM SeatType ORDER BY id";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapResultSetToSeatType(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // GET ACTIVE SEAT TYPES ONLY
    public List<SeatType> getActiveSeatTypes() {
        List<SeatType> list = new ArrayList<>();
        String sql = "SELECT * FROM SeatType WHERE status = 1 ORDER BY id";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapResultSetToSeatType(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // GET SEAT TYPE BY ID
    public SeatType getSeatTypeById(int id) {
        String sql = "SELECT * FROM SeatType WHERE id = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToSeatType(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // GET SEAT TYPE BY CODE
    public SeatType getSeatTypeByCode(String code) {
        String sql = "SELECT * FROM SeatType WHERE code = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, code);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToSeatType(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // CREATE NEW SEAT TYPE 
    public boolean addSeatType(SeatType seatType) {
        String sql = "INSERT INTO SeatType (code, name, surcharge, color, description, status, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, seatType.getCode());
            ps.setString(2, seatType.getName());
            ps.setDouble(3, seatType.getSurcharge());
            ps.setString(4, seatType.getColor());
            ps.setString(5, seatType.getDescription());
            ps.setBoolean(6, seatType.isStatus());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // UPDATE SEAT TYPE 
    public boolean updateSeatType(SeatType seatType) {
        String sql = "UPDATE SeatType SET code = ?, name = ?, surcharge = ?, color = ?, description = ?, status = ?, updated_at = GETDATE() WHERE id = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, seatType.getCode());
            ps.setString(2, seatType.getName());
            ps.setDouble(3, seatType.getSurcharge());
            ps.setString(4, seatType.getColor());
            ps.setString(5, seatType.getDescription());
            ps.setBoolean(6, seatType.isStatus());
            ps.setInt(7, seatType.getId());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // DELETE SEAT TYPE 
    public boolean deleteSeatType(int id) {
        String sql = "UPDATE SeatType SET status = 0, updated_at = GETDATE() WHERE id = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // HARD DELETE 
    public boolean hardDeleteSeatType(int id) {
        String sql = "DELETE FROM SeatType WHERE id = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ===== HELPER METHOD =====
    private SeatType mapResultSetToSeatType(ResultSet rs) throws SQLException {
        SeatType seatType = new SeatType();
        seatType.setId(rs.getInt("id"));
        seatType.setCode(rs.getString("code"));
        seatType.setName(rs.getString("name"));
        seatType.setSurcharge(rs.getDouble("surcharge"));
        seatType.setColor(rs.getString("color"));
        seatType.setDescription(rs.getString("description"));
        seatType.setStatus(rs.getBoolean("status"));
        seatType.setCreatedAt(rs.getTimestamp("created_at"));
        seatType.setUpdatedAt(rs.getTimestamp("updated_at")); // THÊM DÒNG NÀY
        return seatType;
    }

    // ===== VALIDATION METHODS =====
    public boolean isCodeExists(String code) {
        return getSeatTypeByCode(code) != null;
    }

    public boolean isCodeExists(String code, int excludeId) {
        String sql = "SELECT COUNT(*) FROM SeatType WHERE code = ? AND id != ?";

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

    public List<SeatType> searchSeatTypes(String keyword) {
        List<SeatType> list = new ArrayList<>();
        String sql = "SELECT * FROM SeatType WHERE code LIKE ? OR name LIKE ? OR description LIKE ? ORDER BY id";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToSeatType(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}