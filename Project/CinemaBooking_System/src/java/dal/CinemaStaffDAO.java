package dal;

import model.CinemaStaff;
import util.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CinemaStaffDAO extends DBContext {

    // GET ALL CINEMA-STAFF ASSIGNMENTS
    public List<CinemaStaff> getAllCinemaStaffAssignments() {
        List<CinemaStaff> list = new ArrayList<>();
        String sql = "SELECT cs.*, c.Name as cinema_name, u.username as staff_name, u.email as staff_email " +
                    "FROM Cinema_Staff cs " +
                    "INNER JOIN Cinema c ON cs.cinema_id = c.Id " +
                    "INNER JOIN Users u ON cs.staff_id = u.id " +
                    "ORDER BY c.Name, u.username";
        
        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql); 
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                list.add(mapResultSetToCinemaStaff(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
    // GET ASSIGNMENTS BY CINEMA ID
    public List<CinemaStaff> getAssignmentsByCinemaId(int cinemaId) {
        List<CinemaStaff> list = new ArrayList<>();
        String sql = "SELECT cs.*, c.Name as cinema_name, u.username as staff_name, u.email as staff_email " +
                    "FROM Cinema_Staff cs " +
                    "INNER JOIN Cinema c ON cs.cinema_id = c.Id " +
                    "INNER JOIN Users u ON cs.staff_id = u.id " +
                    "WHERE cs.cinema_id = ? " +
                    "ORDER BY u.username";
        
        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, cinemaId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToCinemaStaff(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
    // GET ASSIGNMENT BY ID
    public CinemaStaff getAssignmentById(int id) {
        String sql = "SELECT cs.*, c.Name as cinema_name, u.username as staff_name, u.email as staff_email " +
                    "FROM Cinema_Staff cs " +
                    "INNER JOIN Cinema c ON cs.cinema_id = c.Id " +
                    "INNER JOIN Users u ON cs.staff_id = u.id " +
                    "WHERE cs.id = ?";
        
        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToCinemaStaff(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // CREATE CINEMA-STAFF ASSIGNMENT
    public boolean addCinemaStaffAssignment(CinemaStaff assignment) {
        String sql = "INSERT INTO Cinema_Staff (cinema_id, staff_id, role_in_cinema, assigned_at, status) " +
                    "VALUES (?, ?, ?, GETDATE(), ?)";
        
        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, assignment.getCinemaId());
            ps.setInt(2, assignment.getStaffId());
            ps.setString(3, assignment.getRoleInCinema());
            ps.setBoolean(4, assignment.isStatus());
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // UPDATE CINEMA-STAFF ASSIGNMENT
    public boolean updateCinemaStaffAssignment(CinemaStaff assignment) {
        String sql = "UPDATE Cinema_Staff SET role_in_cinema = ?, status = ? WHERE id = ?";
        
        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, assignment.getRoleInCinema());
            ps.setBoolean(2, assignment.isStatus());
            ps.setInt(3, assignment.getId());
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // DELETE CINEMA-STAFF ASSIGNMENT
    public boolean deleteCinemaStaffAssignment(int id) {
        String sql = "DELETE FROM Cinema_Staff WHERE id = ?";
        
        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // CHECK IF STAFF IS ALREADY ASSIGNED TO CINEMA
    public boolean isStaffAssignedToCinema(int staffId, int cinemaId) {
        String sql = "SELECT COUNT(*) FROM Cinema_Staff WHERE staff_id = ? AND cinema_id = ? AND status = 1";
        
        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, staffId);
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
    
    // ===== HELPER METHOD =====
    private CinemaStaff mapResultSetToCinemaStaff(ResultSet rs) throws SQLException {
        CinemaStaff assignment = new CinemaStaff();
        assignment.setId(rs.getInt("id"));
        assignment.setCinemaId(rs.getInt("cinema_id"));
        assignment.setStaffId(rs.getInt("staff_id"));
        assignment.setRoleInCinema(rs.getString("role_in_cinema"));
        assignment.setAssignedAt(rs.getTimestamp("assigned_at"));
        assignment.setStatus(rs.getBoolean("status"));
        
        // Thông tin từ join
        assignment.setCinemaName(rs.getString("cinema_name"));
        assignment.setStaffName(rs.getString("staff_name"));
        assignment.setStaffEmail(rs.getString("staff_email"));
        
        return assignment;
    }
}