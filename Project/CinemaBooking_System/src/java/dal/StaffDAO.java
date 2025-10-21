package dal;

import model.Staff;
import util.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class StaffDAO extends DBContext {

    // GET ALL STAFF WITH CINEMA ASSIGNMENT INFO
    public List<Staff> getAllStaffWithAssignments() {
        List<Staff> list = new ArrayList<>();
        String sql = "SELECT u.id, u.email, u.phoneNumber, u.username, u.role, u.status, " +
                    "u.createdAt, u.updatedAt, u.current_cinema_id, " +
                    "c.name as cinema_name, cs.role_in_cinema, cs.assigned_at, cs.status as assignment_status " +
                    "FROM Users u " +
                    "LEFT JOIN Cinema_Staff cs ON u.id = cs.staff_id AND cs.status = 1 " +
                    "LEFT JOIN Cinema c ON cs.cinema_id = c.id " +
                    "WHERE u.role = 'staff' " +
                    "ORDER BY u.username";
        
        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql); 
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                list.add(mapResultSetToStaff(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
    // GET STAFF BY ID WITH ASSIGNMENT INFO
    public Staff getStaffById(int id) {
        String sql = "SELECT u.id, u.email, u.phoneNumber, u.username, u.role, u.status, " +
                    "u.createdAt, u.updatedAt, u.current_cinema_id, " +
                    "c.name as cinema_name, cs.role_in_cinema, cs.assigned_at, cs.status as assignment_status " +
                    "FROM Users u " +
                    "LEFT JOIN Cinema_Staff cs ON u.id = cs.staff_id AND cs.status = 1 " +
                    "LEFT JOIN Cinema c ON cs.cinema_id = c.id " +
                    "WHERE u.id = ? AND u.role = 'staff'";
        
        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToStaff(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // GET ACTIVE STAFF (for assignment)
    public List<Staff> getActiveStaff() {
        List<Staff> list = new ArrayList<>();
        String sql = "SELECT u.id, u.email, u.phoneNumber, u.username, u.role, u.status, " +
                    "u.createdAt, u.updatedAt, u.current_cinema_id " +
                    "FROM Users u " +
                    "WHERE u.role = 'staff' AND u.status = 1 " +
                    "ORDER BY u.username";
        
        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql); 
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Staff staff = new Staff();
                staff.setId(rs.getInt("id"));
                staff.setEmail(rs.getString("email"));
                staff.setPhoneNumber(rs.getString("phoneNumber"));
                staff.setUsername(rs.getString("username"));
                staff.setRole(rs.getString("role"));
                staff.setStatus(rs.getBoolean("status"));
                staff.setCreatedAt(rs.getTimestamp("createdAt"));
                staff.setUpdatedAt(rs.getTimestamp("updatedAt"));
                staff.setCurrentCinemaId(rs.getInt("current_cinema_id"));
                list.add(staff);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
    // UPDATE STAFF STATUS
    public boolean updateStaffStatus(int staffId, boolean status) {
        String sql = "UPDATE Users SET status = ?, updatedAt = GETDATE() WHERE id = ? AND role = 'staff'";
        
        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setBoolean(1, status);
            ps.setInt(2, staffId);
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // SEARCH STAFF
    public List<Staff> searchStaff(String keyword) {
        List<Staff> list = new ArrayList<>();
        String sql = "SELECT u.id, u.email, u.phoneNumber, u.username, u.role, u.status, " +
                    "u.createdAt, u.updatedAt, u.current_cinema_id, " +
                    "c.name as cinema_name, cs.role_in_cinema, cs.assigned_at, cs.status as assignment_status " +
                    "FROM Users u " +
                    "LEFT JOIN Cinema_Staff cs ON u.id = cs.staff_id AND cs.status = 1 " +
                    "LEFT JOIN Cinema c ON cs.cinema_id = c.id " +
                    "WHERE u.role = 'staff' AND (u.username LIKE ? OR u.email LIKE ? OR u.phoneNumber LIKE ?) " +
                    "ORDER BY u.username";
        
        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToStaff(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    // Trong dal/StaffDAO.java - THÊM các phương thức sau:

// CREATE - Thêm staff mới
public boolean addStaff(Staff staff) {
    String sql = "INSERT INTO Users (Email, PhoneNumber, Password, Username, Role, Status, CreatedAt, UpdatedAt, EmailConfirmed) " +
                "VALUES (?, ?, ?, ?, ?, ?, GETDATE(), GETDATE(), 1)";
    
    try (Connection conn = getConnection(); 
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setString(1, staff.getEmail());
        ps.setString(2, staff.getPhoneNumber());
        ps.setString(3, "Default@123"); // Password mặc định
        ps.setString(4, staff.getUsername());
        ps.setString(5, staff.getRole());
        ps.setBoolean(6, staff.isStatus());
        
        return ps.executeUpdate() > 0;
    } catch (Exception e) {
        e.printStackTrace();
    }
    return false;
}

// UPDATE - Cập nhật thông tin staff
public boolean updateStaff(Staff staff) {
    String sql = "UPDATE Users SET Email = ?, PhoneNumber = ?, Username = ?, Role = ?, Status = ?, UpdatedAt = GETDATE() WHERE Id = ?";
    
    try (Connection conn = getConnection(); 
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setString(1, staff.getEmail());
        ps.setString(2, staff.getPhoneNumber());
        ps.setString(3, staff.getUsername());
        ps.setString(4, staff.getRole());
        ps.setBoolean(5, staff.isStatus());
        ps.setInt(6, staff.getId());
        
        return ps.executeUpdate() > 0;
    } catch (Exception e) {
        e.printStackTrace();
    }
    return false;
}

// DELETE - Xóa staff (soft delete)
public boolean deleteStaff(int id) {
    String sql = "UPDATE Users SET Status = 0, UpdatedAt = GETDATE() WHERE Id = ? AND Role = 'staff'";
    
    try (Connection conn = getConnection(); 
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setInt(1, id);
        return ps.executeUpdate() > 0;
    } catch (Exception e) {
        e.printStackTrace();
    }
    return false;
}

// CHECK email exists
public boolean isEmailExists(String email) {
    String sql = "SELECT COUNT(*) FROM Users WHERE Email = ?";
    
    try (Connection conn = getConnection(); 
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setString(1, email);
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

// CHECK email exists (exclude current staff)
public boolean isEmailExists(String email, int excludeId) {
    String sql = "SELECT COUNT(*) FROM Users WHERE Email = ? AND Id != ?";
    
    try (Connection conn = getConnection(); 
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setString(1, email);
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
    // ===== HELPER METHOD =====
    private Staff mapResultSetToStaff(ResultSet rs) throws SQLException {
    Staff staff = new Staff();
    staff.setId(rs.getInt("id"));
    staff.setEmail(rs.getString("email"));
    staff.setPhoneNumber(rs.getString("phoneNumber"));
    staff.setUsername(rs.getString("username"));
    staff.setRole(rs.getString("role"));
    staff.setStatus(rs.getBoolean("status"));
    staff.setCreatedAt(rs.getTimestamp("createdAt"));
    staff.setUpdatedAt(rs.getTimestamp("updatedAt"));
    
    // Sửa lỗi current_cinema_id có thể NULL
    int currentCinemaId = rs.getInt("current_cinema_id");
    staff.setCurrentCinemaId(rs.wasNull() ? null : currentCinemaId);
    
    // Thông tin từ join
    staff.setCinemaName(rs.getString("cinema_name"));
    staff.setRoleInCinema(rs.getString("role_in_cinema"));
    staff.setAssignedAt(rs.getTimestamp("assigned_at"));
    staff.setAssignmentStatus(rs.getBoolean("assignment_status"));
    
    return staff;
}
}