/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
// dal/VoucherDAO.java
package dal;

import model.Voucher;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import util.DBContext;

public class VoucherDAO {

    // Tạo voucher mới
    public boolean createVoucher(Voucher voucher) {
        String sql = "INSERT INTO Voucher (Code, Name, Description, DiscountType, DiscountValue, " +
                    "MinOrderAmount, MaxDiscountAmount, Quantity, StartDate, EndDate, CreatedBy) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, voucher.getCode());
            stmt.setString(2, voucher.getName());
            stmt.setString(3, voucher.getDescription());
            stmt.setInt(4, voucher.getDiscountType());
            stmt.setDouble(5, voucher.getDiscountValue());
            stmt.setDouble(6, voucher.getMinOrderAmount());
            stmt.setDouble(7, voucher.getMaxDiscountAmount());
            stmt.setInt(8, voucher.getQuantity());
            stmt.setTimestamp(9, voucher.getStartDate());
            stmt.setTimestamp(10, voucher.getEndDate());
            stmt.setInt(11, voucher.getCreatedBy());
            
            return stmt.executeUpdate() > 0;
            
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Kiểm tra code đã tồn tại chưa
    public boolean isCodeExists(String code) {
        String sql = "SELECT COUNT(*) FROM Voucher WHERE Code = ?";
        
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, code);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Lấy tất cả voucher (cho danh sách sau này)
    public List<Voucher> getAllVouchers() {
        List<Voucher> vouchers = new ArrayList<>();
        String sql = "SELECT * FROM Voucher ORDER BY CreatedAt DESC";
        
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Voucher voucher = new Voucher();
                voucher.setId(rs.getInt("Id"));
                voucher.setCode(rs.getString("Code"));
                voucher.setName(rs.getString("Name"));
                voucher.setDescription(rs.getString("Description"));
                voucher.setDiscountType(rs.getInt("DiscountType"));
                voucher.setDiscountValue(rs.getDouble("DiscountValue"));
                voucher.setMinOrderAmount(rs.getDouble("MinOrderAmount"));
                voucher.setMaxDiscountAmount(rs.getDouble("MaxDiscountAmount"));
                voucher.setQuantity(rs.getInt("Quantity"));
                voucher.setUsedQuantity(rs.getInt("UsedQuantity"));
                voucher.setStartDate(rs.getTimestamp("StartDate"));
                voucher.setEndDate(rs.getTimestamp("EndDate"));
                voucher.setIsActive(rs.getBoolean("IsActive"));
                voucher.setCreatedAt(rs.getTimestamp("CreatedAt"));
                voucher.setCreatedBy(rs.getInt("CreatedBy"));
                
                vouchers.add(voucher);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        return vouchers;
    }
    
     public Voucher getVoucherById(int id) {
        String sql = "SELECT * FROM Voucher WHERE Id = ?";
        
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                Voucher voucher = new Voucher();
                voucher.setId(rs.getInt("Id"));
                voucher.setCode(rs.getString("Code"));
                voucher.setName(rs.getString("Name"));
                voucher.setDescription(rs.getString("Description"));
                voucher.setDiscountType(rs.getInt("DiscountType"));
                voucher.setDiscountValue(rs.getDouble("DiscountValue"));
                voucher.setMinOrderAmount(rs.getDouble("MinOrderAmount"));
                voucher.setMaxDiscountAmount(rs.getDouble("MaxDiscountAmount"));
                voucher.setQuantity(rs.getInt("Quantity"));
                voucher.setUsedQuantity(rs.getInt("UsedQuantity"));
                voucher.setStartDate(rs.getTimestamp("StartDate"));
                voucher.setEndDate(rs.getTimestamp("EndDate"));
                voucher.setIsActive(rs.getBoolean("IsActive"));
                voucher.setCreatedAt(rs.getTimestamp("CreatedAt"));
                voucher.setCreatedBy(rs.getInt("CreatedBy"));
                voucher.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
                voucher.setUpdatedBy(rs.getInt("UpdatedBy"));
                
                return voucher;
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Cập nhật voucher
    public boolean updateVoucher(Voucher voucher) {
        String sql = "UPDATE Voucher SET Code = ?, Name = ?, Description = ?, " +
                    "DiscountType = ?, DiscountValue = ?, MinOrderAmount = ?, " +
                    "MaxDiscountAmount = ?, Quantity = ?, StartDate = ?, EndDate = ?, " +
                    "IsActive = ?, UpdatedAt = GETDATE(), UpdatedBy = ? " +
                    "WHERE Id = ?";
        
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, voucher.getCode());
            stmt.setString(2, voucher.getName());
            stmt.setString(3, voucher.getDescription());
            stmt.setInt(4, voucher.getDiscountType());
            stmt.setDouble(5, voucher.getDiscountValue());
            stmt.setDouble(6, voucher.getMinOrderAmount());
            stmt.setDouble(7, voucher.getMaxDiscountAmount());
            stmt.setInt(8, voucher.getQuantity());
            stmt.setTimestamp(9, voucher.getStartDate());
            stmt.setTimestamp(10, voucher.getEndDate());
            stmt.setBoolean(11, voucher.getIsActive());
            stmt.setInt(12, voucher.getUpdatedBy());
            stmt.setInt(13, voucher.getId());
            
            return stmt.executeUpdate() > 0;
            
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Kiểm tra code đã tồn tại (trừ voucher hiện tại)
    public boolean isCodeExists(String code, int excludeVoucherId) {
        String sql = "SELECT COUNT(*) FROM Voucher WHERE Code = ? AND Id != ?";
        
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, code);
            stmt.setInt(2, excludeVoucherId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
