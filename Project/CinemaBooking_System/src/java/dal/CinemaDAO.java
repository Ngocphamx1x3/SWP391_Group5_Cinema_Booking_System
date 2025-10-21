package dal;

import model.Cinema;
import util.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CinemaDAO extends DBContext {

    // ===== CRUD OPERATIONS =====
    public List<Cinema> getAllCinemas() {
        List<Cinema> list = new ArrayList<>();
        String sql = "SELECT * FROM Cinema ORDER BY id";
        
        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql); 
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                list.add(mapResultSetToCinema(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
    // GET ACTIVE CINEMAS ONLY
    public List<Cinema> getActiveCinemas() {
        List<Cinema> list = new ArrayList<>();
        String sql = "SELECT * FROM Cinema WHERE status = 1 ORDER BY name";
        
        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql); 
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                list.add(mapResultSetToCinema(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
    // GET CINEMA BY ID
    public Cinema getCinemaById(int id) {
        String sql = "SELECT * FROM Cinema WHERE id = ?";
        
        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToCinema(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // CREATE CINEMA
    public boolean addCinema(Cinema cinema) {
        String sql = "INSERT INTO Cinema (Code, Name, Address, Description, Capacity, Status, Phone, TotalRooms, OperatingHours, CreatedDate, UpdatedDate) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())";
        
        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, cinema.getCode());
            ps.setString(2, cinema.getName());
            ps.setString(3, cinema.getAddress());
            ps.setString(4, cinema.getDescription());
            ps.setInt(5, cinema.getCapacity());
            ps.setBoolean(6, cinema.isStatus());
            ps.setString(7, cinema.getPhone());
            ps.setInt(8, cinema.getTotalRooms());
            ps.setString(9, cinema.getOperatingHours());
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // UPDATE CINEMA
    public boolean updateCinema(Cinema cinema) {
        String sql = "UPDATE Cinema SET Code = ?, Name = ?, Address = ?, Description = ?, " +
                    "Capacity = ?, Status = ?, Phone = ?, TotalRooms = ?, OperatingHours = ?, " +
                    "UpdatedDate = GETDATE() WHERE Id = ?";
        
        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, cinema.getCode());
            ps.setString(2, cinema.getName());
            ps.setString(3, cinema.getAddress());
            ps.setString(4, cinema.getDescription());
            ps.setInt(5, cinema.getCapacity());
            ps.setBoolean(6, cinema.isStatus());
            ps.setString(7, cinema.getPhone());
            ps.setInt(8, cinema.getTotalRooms());
            ps.setString(9, cinema.getOperatingHours());
            ps.setInt(10, cinema.getId());
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // DELETE CINEMA (soft delete)
    public boolean deleteCinema(int id) {
        String sql = "UPDATE Cinema SET Status = 0, UpdatedDate = GETDATE() WHERE Id = ?";
        
        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // ===== HELPER METHOD =====
    private Cinema mapResultSetToCinema(ResultSet rs) throws SQLException {
        Cinema cinema = new Cinema();
        cinema.setId(rs.getInt("Id"));
        cinema.setCode(rs.getString("Code"));
        cinema.setName(rs.getString("Name"));
        cinema.setAddress(rs.getString("Address"));
        cinema.setDescription(rs.getString("Description"));
        cinema.setCapacity(rs.getInt("Capacity"));
        cinema.setStatus(rs.getBoolean("Status"));
        cinema.setPhone(rs.getString("Phone"));
        cinema.setTotalRooms(rs.getInt("TotalRooms"));
        cinema.setOperatingHours(rs.getString("OperatingHours"));
        cinema.setCreatedDate(rs.getTimestamp("CreatedDate"));
        cinema.setUpdatedDate(rs.getTimestamp("UpdatedDate"));
        return cinema;
    }
    
    // ===== VALIDATION METHODS =====
    public boolean isCodeExists(String code) {
        String sql = "SELECT COUNT(*) FROM Cinema WHERE Code = ?";
        
        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
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
        String sql = "SELECT COUNT(*) FROM Cinema WHERE Code = ? AND Id != ?";
        
        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
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
    
    // SEARCH CINEMAS
    public List<Cinema> searchCinemas(String keyword) {
        List<Cinema> list = new ArrayList<>();
        String sql = "SELECT * FROM Cinema WHERE Code LIKE ? OR Name LIKE ? OR Address LIKE ? OR Phone LIKE ? ORDER BY Name";
        
        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            ps.setString(4, searchPattern);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToCinema(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}