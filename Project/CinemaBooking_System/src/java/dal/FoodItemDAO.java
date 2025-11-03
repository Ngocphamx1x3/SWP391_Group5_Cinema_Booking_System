package dal;

import model.FoodItem;
import util.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class FoodItemDAO extends DBContext {

    // ===== CRUD OPERATIONS =====
    
    // GET ALL FOOD ITEMS
    public List<FoodItem> getAllFoodItems() {
        List<FoodItem> list = new ArrayList<>();
        String sql = "SELECT * FROM FoodItem ORDER BY CreatedDate DESC";

        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql); 
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapResultSetToFoodItem(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // GET FOOD ITEM BY ID
    public FoodItem getFoodItemById(int id) {
        String sql = "SELECT * FROM FoodItem WHERE ItemID = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToFoodItem(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // CREATE FOOD ITEM
    public boolean addFoodItem(FoodItem item) {
        String sql = "INSERT INTO FoodItem (Name, Type, Price, Image, Description, Status, CreatedDate, UpdatedDate) "
                + "VALUES (?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, item.getName());
            ps.setString(2, item.getType());
            ps.setDouble(3, item.getPrice());
            ps.setString(4, item.getImage());
            ps.setString(5, item.getDescription());
            ps.setBoolean(6, item.getStatus());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // UPDATE FOOD ITEM
    public boolean updateFoodItem(FoodItem item) {
        String sql = "UPDATE FoodItem SET Name = ?, Type = ?, Price = ?, Image = ?, "
                + "Description = ?, Status = ?, UpdatedDate = GETDATE() WHERE ItemID = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, item.getName());
            ps.setString(2, item.getType());
            ps.setDouble(3, item.getPrice());
            ps.setString(4, item.getImage());
            ps.setString(5, item.getDescription());
            ps.setBoolean(6, item.getStatus());
            ps.setInt(7, item.getItemID());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // DELETE FOOD ITEM (hard delete)
    public boolean deleteFoodItem(int id) {
        String sql = "DELETE FROM FoodItem WHERE ItemID = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // TOGGLE STATUS (Active/Inactive)
    public boolean toggleFoodItemStatus(int id) {
        // First get current status, then toggle it
        FoodItem item = getFoodItemById(id);
        if (item == null) {
            return false;
        }
        
        String sql = "UPDATE FoodItem SET Status = ?, UpdatedDate = GETDATE() WHERE ItemID = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setBoolean(1, !item.getStatus());
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ===== SEARCH AND FILTER METHODS =====
    
    // SEARCH FOOD ITEMS BY KEYWORD (Name, Description)
    public List<FoodItem> searchFoodItems(String keyword) {
        List<FoodItem> list = new ArrayList<>();
        String sql = "SELECT * FROM FoodItem WHERE Name LIKE ? OR Description LIKE ? ORDER BY CreatedDate DESC";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToFoodItem(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // FILTER FOOD ITEMS BY TYPE
    public List<FoodItem> getFoodItemsByType(String type) {
        List<FoodItem> list = new ArrayList<>();
        String sql = "SELECT * FROM FoodItem WHERE Type = ? ORDER BY CreatedDate DESC";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, type);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToFoodItem(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // SEARCH AND FILTER FOOD ITEMS (Combined)
    public List<FoodItem> searchAndFilterFoodItems(String keyword, String type) {
        List<FoodItem> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM FoodItem WHERE 1=1 ");
        List<Object> parameters = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (Name LIKE ? OR Description LIKE ?) ");
            String searchPattern = "%" + keyword.trim() + "%";
            parameters.add(searchPattern);
            parameters.add(searchPattern);
        }

        if (type != null && !type.trim().isEmpty()) {
            sql.append("AND Type = ? ");
            parameters.add(type.trim());
        }

        sql.append("ORDER BY CreatedDate DESC");

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            // Set parameters
            for (int i = 0; i < parameters.size(); i++) {
                ps.setObject(i + 1, parameters.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToFoodItem(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // GET ACTIVE FOOD ITEMS ONLY
    public List<FoodItem> getActiveFoodItems() {
        List<FoodItem> list = new ArrayList<>();
        String sql = "SELECT * FROM FoodItem WHERE Status = 1 ORDER BY CreatedDate DESC";

        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql); 
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapResultSetToFoodItem(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ===== HELPER METHOD =====
    private FoodItem mapResultSetToFoodItem(ResultSet rs) throws SQLException {
        FoodItem item = new FoodItem();
        item.setItemID(rs.getInt("ItemID"));
        item.setName(rs.getString("Name"));
        item.setType(rs.getString("Type"));
        item.setPrice(rs.getDouble("Price"));
        item.setImage(rs.getString("Image"));
        item.setDescription(rs.getString("Description"));
        item.setStatus(rs.getBoolean("Status"));
        item.setCreatedDate(rs.getTimestamp("CreatedDate"));
        item.setUpdatedDate(rs.getTimestamp("UpdatedDate"));
        return item;
    }
}

