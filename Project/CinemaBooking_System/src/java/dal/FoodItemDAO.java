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
        // Validation
        if (item == null) {
            System.err.println("Error: FoodItem object is null");
            return false;
        }
        if (item.getName() == null || item.getName().trim().isEmpty()) {
            System.err.println("Error: FoodItem name cannot be null or empty");
            return false;
        }
        if (item.getType() == null || item.getType().trim().isEmpty()) {
            System.err.println("Error: FoodItem type cannot be null or empty");
            return false;
        }
        if (item.getPrice() < 0) {
            System.err.println("Error: FoodItem price cannot be negative");
            return false;
        }
        // Validate type value
        String type = item.getType().trim();
        if (!type.equalsIgnoreCase("Popcorn") && !type.equalsIgnoreCase("Drink") && !type.equalsIgnoreCase("Snack")) {
            System.err.println("Error: FoodItem type must be Popcorn, Drink, or Snack");
            return false;
        }
        
        // UpdatedDate should be NULL when creating new item
        String sql = "INSERT INTO FoodItem (Name, Type, Price, Image, Description, Status, CreatedDate, UpdatedDate) "
                + "VALUES (?, ?, ?, ?, ?, ?, GETDATE(), NULL)";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, item.getName().trim());
            ps.setString(2, type);
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
        // Validation
        if (item == null) {
            System.err.println("Error: FoodItem object is null");
            return false;
        }
        if (item.getItemID() <= 0) {
            System.err.println("Error: FoodItem ID is invalid");
            return false;
        }
        if (item.getName() == null || item.getName().trim().isEmpty()) {
            System.err.println("Error: FoodItem name cannot be null or empty");
            return false;
        }
        if (item.getType() == null || item.getType().trim().isEmpty()) {
            System.err.println("Error: FoodItem type cannot be null or empty");
            return false;
        }
        if (item.getPrice() < 0) {
            System.err.println("Error: FoodItem price cannot be negative");
            return false;
        }
        // Validate type value
        String type = item.getType().trim();
        if (!type.equalsIgnoreCase("Popcorn") && !type.equalsIgnoreCase("Drink") && !type.equalsIgnoreCase("Snack")) {
            System.err.println("Error: FoodItem type must be Popcorn, Drink, or Snack");
            return false;
        }
        
        String sql = "UPDATE FoodItem SET Name = ?, Type = ?, Price = ?, Image = ?, "
                + "Description = ?, Status = ?, UpdatedDate = GETDATE() WHERE ItemID = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, item.getName().trim());
            ps.setString(2, type);
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
    // WARNING: This will fail if FoodItem is referenced in Combo_Item table (FK constraint)
    // Consider using soft delete or cascade delete if needed
    public boolean deleteFoodItem(int id) {
        if (id <= 0) {
            System.err.println("Error: FoodItem ID is invalid");
            return false;
        }
        
        // Check if item is used in any combo
        // Note: This is a basic check. For production, consider soft delete instead
        String checkSql = "SELECT COUNT(*) as count FROM Combo_Item WHERE ItemID = ?";
        String deleteSql = "DELETE FROM FoodItem WHERE ItemID = ?";

        try (Connection conn = getConnection()) {
            // Check if item is in any combo
            try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                checkPs.setInt(1, id);
                try (ResultSet rs = checkPs.executeQuery()) {
                    if (rs.next() && rs.getInt("count") > 0) {
                        System.err.println("Error: Cannot delete FoodItem with ID " + id + 
                                         " because it is used in " + rs.getInt("count") + " combo(s)");
                        return false;
                    }
                }
            }
            
            // Delete the item
            try (PreparedStatement deletePs = conn.prepareStatement(deleteSql)) {
                deletePs.setInt(1, id);
                return deletePs.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            // Handle FK constraint violation
            if (e.getErrorCode() == 547) { // SQL Server FK constraint violation
                System.err.println("Error: Cannot delete FoodItem with ID " + id + 
                                 " because it is referenced in Combo_Item table");
            } else {
                e.printStackTrace();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // TOGGLE STATUS (Active/Inactive) - optimized: single SQL query
    public boolean toggleFoodItemStatus(int id) {
        if (id <= 0) {
            System.err.println("Error: FoodItem ID is invalid");
            return false;
        }
        
        String sql = "UPDATE FoodItem SET Status = CASE WHEN Status = 1 THEN 0 ELSE 1 END, " +
                     "UpdatedDate = GETDATE() WHERE ItemID = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
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

