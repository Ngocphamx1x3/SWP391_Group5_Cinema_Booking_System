/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
// dal/UserProfileDAO.java
package dal;

import java.sql.*;
import util.DBContext;

public class UserProfileDAO {
    
    public String getFullNameByUserId(int userId) {
        String sql = "SELECT FullName FROM UserProfile WHERE UserId = ?";
        
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getString("FullName");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
