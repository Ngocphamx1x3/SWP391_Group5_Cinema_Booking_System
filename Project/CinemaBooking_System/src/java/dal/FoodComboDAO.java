package dal;

import model.FoodCombo;
import model.ComboItem;
import util.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class FoodComboDAO extends DBContext {

    // ===== CRUD OPERATIONS =====
    
    // GET ALL FOOD COMBOS
    public List<FoodCombo> getAllFoodCombos() {
        List<FoodCombo> list = new ArrayList<>();
        String sql = "SELECT * FROM FoodCombo ORDER BY CreatedDate DESC";

        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql); 
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                try {
                    FoodCombo combo = mapResultSetToFoodCombo(rs);
                    // Load items for each combo
                    combo.setItems(getComboItems(combo.getComboID()));
                    list.add(combo);
                } catch (SQLException e) {
                    System.err.println("Error loading combo with ID " + rs.getInt("ComboID") + ": " + e.getMessage());
                    // Continue with next combo instead of failing completely
                }
            }
        } catch (SQLException e) {
            System.err.println("Database error loading food combos: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("Unexpected error loading food combos: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    // GET FOOD COMBO BY ID
    public FoodCombo getFoodComboById(int id) {
        String sql = "SELECT * FROM FoodCombo WHERE ComboID = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    FoodCombo combo = mapResultSetToFoodCombo(rs);
                    // Load items
                    combo.setItems(getComboItems(id));
                    return combo;
                }
            }
        } catch (SQLException e) {
            System.err.println("Database error loading food combo with ID " + id + ": " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("Unexpected error loading food combo with ID " + id + ": " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    // CREATE FOOD COMBO
    public int addFoodCombo(FoodCombo combo) {
        String sql = "INSERT INTO FoodCombo (Name, Description, Price, Image, CreatedBy, CreatedDate, Status) "
                + "VALUES (?, ?, ?, ?, ?, GETDATE(), ?)";

        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, combo.getName());
            ps.setString(2, combo.getDescription());
            ps.setDouble(3, combo.getPrice());
            ps.setString(4, combo.getImage());
            ps.setInt(5, combo.getCreatedBy());
            ps.setBoolean(6, combo.getStatus());

            int result = ps.executeUpdate();
            
            if (result > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1); // Return generated ComboID
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    // UPDATE FOOD COMBO
    public boolean updateFoodCombo(FoodCombo combo) {
        String sql = "UPDATE FoodCombo SET Name = ?, Description = ?, Price = ?, Image = ?, "
                + "UpdatedDate = GETDATE(), UpdatedBy = ?, Status = ? WHERE ComboID = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, combo.getName());
            ps.setString(2, combo.getDescription());
            ps.setDouble(3, combo.getPrice());
            ps.setString(4, combo.getImage());
            ps.setObject(5, combo.getUpdatedBy());
            ps.setBoolean(6, combo.getStatus());
            ps.setInt(7, combo.getComboID());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // DELETE FOOD COMBO (hard delete)
    public boolean deleteFoodCombo(int id) {
        String sql = "DELETE FROM FoodCombo WHERE ComboID = ?";

        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                // First delete combo items
                deleteComboItems(id, conn);
                
                // Then delete combo
                ps.setInt(1, id);
                int result = ps.executeUpdate();
                
                conn.commit();
                return result > 0;
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // TOGGLE STATUS (Active/Inactive)
    public boolean toggleFoodComboStatus(int id) {
        // First get current status, then toggle it
        FoodCombo combo = getFoodComboById(id);
        if (combo == null) {
            return false;
        }
        
        String sql = "UPDATE FoodCombo SET Status = ?, UpdatedDate = GETDATE() WHERE ComboID = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setBoolean(1, !combo.getStatus());
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ===== COMBO ITEM OPERATIONS =====
    
    // GET COMBO ITEMS BY COMBO ID
    public List<ComboItem> getComboItems(int comboID) {
        List<ComboItem> list = new ArrayList<>();
        String sql = "SELECT ci.*, fi.Name as ItemName, fi.Price as ItemPrice, fi.Type as ItemType, fi.Image as ItemImage " +
                     "FROM Combo_Item ci " +
                     "LEFT JOIN FoodItem fi ON ci.ItemID = fi.ItemID " +
                     "WHERE ci.ComboID = ? " +
                     "ORDER BY fi.Type, fi.Name";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, comboID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ComboItem item = mapResultSetToComboItem(rs);
                    // Only add item if FoodItem exists (ItemName is not null means FoodItem exists)
                    if (rs.getString("ItemName") != null) {
                        list.add(item);
                    }
                    // If ItemName is null, it means FoodItem was deleted - skip this item
                }
            }
        } catch (SQLException e) {
            System.err.println("Error loading combo items for comboID " + comboID + ": " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("Unexpected error loading combo items for comboID " + comboID + ": " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    // ADD COMBO ITEMS
    public boolean addComboItems(int comboID, List<ComboItem> items) {
        if (items == null || items.isEmpty()) {
            return true; // No items to add
        }

        String sql = "INSERT INTO Combo_Item (ComboID, ItemID, Quantity) VALUES (?, ?, ?)";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            for (ComboItem item : items) {
                ps.setInt(1, comboID);
                ps.setInt(2, item.getItemID());
                ps.setInt(3, item.getQuantity());
                ps.addBatch();
            }

            ps.executeBatch();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // DELETE ALL COMBO ITEMS
    private boolean deleteComboItems(int comboID, Connection conn) throws SQLException {
        String sql = "DELETE FROM Combo_Item WHERE ComboID = ?";
        
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, comboID);
            ps.executeUpdate();
            return true;
        }
    }

    // DELETE ALL COMBO ITEMS (public method)
    public boolean deleteComboItems(int comboID) {
        String sql = "DELETE FROM Combo_Item WHERE ComboID = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, comboID);
            return ps.executeUpdate() >= 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // UPDATE COMBO ITEMS (delete old, insert new)
    public boolean updateComboItems(int comboID, List<ComboItem> items) {
        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            
            try {
                // Delete old items
                deleteComboItems(comboID, conn);
                
                // Insert new items
                if (items != null && !items.isEmpty()) {
                    addComboItems(comboID, items);
                }
                
                conn.commit();
                return true;
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ===== SEARCH AND FILTER METHODS =====
    
    // SEARCH FOOD COMBOS BY KEYWORD
    public List<FoodCombo> searchFoodCombos(String keyword) {
        List<FoodCombo> list = new ArrayList<>();
        String sql = "SELECT * FROM FoodCombo WHERE Name LIKE ? OR Description LIKE ? ORDER BY CreatedDate DESC";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    try {
                        FoodCombo combo = mapResultSetToFoodCombo(rs);
                        combo.setItems(getComboItems(combo.getComboID()));
                        list.add(combo);
                    } catch (SQLException e) {
                        System.err.println("Error loading combo with ID " + rs.getInt("ComboID") + " during search: " + e.getMessage());
                        // Continue with next combo
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Database error searching food combos: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("Unexpected error searching food combos: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    // GET ACTIVE FOOD COMBOS ONLY
    public List<FoodCombo> getActiveFoodCombos() {
        List<FoodCombo> list = new ArrayList<>();
        String sql = "SELECT * FROM FoodCombo WHERE Status = 1 ORDER BY CreatedDate DESC";

        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql); 
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                FoodCombo combo = mapResultSetToFoodCombo(rs);
                combo.setItems(getComboItems(combo.getComboID()));
                list.add(combo);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ===== HELPER METHODS =====
    private FoodCombo mapResultSetToFoodCombo(ResultSet rs) throws SQLException {
        FoodCombo combo = new FoodCombo();
        combo.setComboID(rs.getInt("ComboID"));
        combo.setName(rs.getString("Name"));
        combo.setDescription(rs.getString("Description"));
        combo.setPrice(rs.getDouble("Price"));
        combo.setImage(rs.getString("Image"));
        combo.setCreatedBy(rs.getInt("CreatedBy"));
        combo.setCreatedDate(rs.getTimestamp("CreatedDate"));
        combo.setUpdatedDate(rs.getTimestamp("UpdatedDate"));
        Integer updatedBy = rs.getObject("UpdatedBy", Integer.class);
        combo.setUpdatedBy(updatedBy);
        combo.setStatus(rs.getBoolean("Status"));
        return combo;
    }

    private ComboItem mapResultSetToComboItem(ResultSet rs) throws SQLException {
        ComboItem item = new ComboItem();
        item.setComboID(rs.getInt("ComboID"));
        item.setItemID(rs.getInt("ItemID"));
        item.setQuantity(rs.getInt("Quantity"));
        
        // Load FoodItem info if available (LEFT JOIN may return null for deleted items)
        String itemName = rs.getString("ItemName");
        if (itemName != null && !itemName.trim().isEmpty()) {
            try {
                model.FoodItem foodItem = new model.FoodItem();
                foodItem.setItemID(rs.getInt("ItemID"));
                foodItem.setName(itemName);
                
                // Handle nullable fields
                Object priceObj = rs.getObject("ItemPrice");
                if (priceObj != null) {
                    foodItem.setPrice(rs.getDouble("ItemPrice"));
                }
                
                foodItem.setType(rs.getString("ItemType"));
                foodItem.setImage(rs.getString("ItemImage"));
                item.setFoodItem(foodItem);
            } catch (SQLException e) {
                // If there's an error reading FoodItem data, log it but don't fail completely
                System.err.println("Error mapping FoodItem for ItemID " + rs.getInt("ItemID") + ": " + e.getMessage());
            }
        }
        
        return item;
    }
}

