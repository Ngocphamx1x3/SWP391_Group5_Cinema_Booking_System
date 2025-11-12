package dal;

import util.DBContext;
import java.sql.*;
import java.util.List;

/**
 * DAO for managing OrderCombo (relationship between Orders and FoodCombo)
 */
public class OrderComboDAO extends DBContext {

    /**
     * Add combos to an order
     * @param orderId Order ID
     * @param comboIds List of combo IDs
     * @param comboQuantities List of quantities (must match comboIds length)
     * @param comboPrices List of prices at time of order (must match comboIds length)
     * @return true if successful
     */
    public boolean addOrderCombos(int orderId, List<Integer> comboIds, List<Integer> comboQuantities, List<Long> comboPrices) throws ClassNotFoundException {
        if (comboIds == null || comboIds.isEmpty()) {
            return true; // No combos to add
        }
        
        if (comboQuantities == null || comboQuantities.size() != comboIds.size()) {
            System.err.println("Error: comboIds and comboQuantities must have same length");
            return false;
        }
        
        if (comboPrices == null || comboPrices.size() != comboIds.size()) {
            System.err.println("Error: comboIds and comboPrices must have same length");
            return false;
        }
        
        String sql = "INSERT INTO OrderCombo (OrderId, ComboId, Quantity, Price, CreatedAt) "
                + "VALUES (?, ?, ?, ?, GETDATE())";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            for (int i = 0; i < comboIds.size(); i++) {
                ps.setInt(1, orderId);
                ps.setInt(2, comboIds.get(i));
                ps.setInt(3, comboQuantities.get(i));
                ps.setLong(4, comboPrices.get(i));
                ps.addBatch();
            }
            
            ps.executeBatch();
            return true;
        } catch (SQLException e) {
            System.err.println("Error adding order combos: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Add combos to an order using existing connection (for transaction)
     */
    public boolean addOrderCombos(Connection conn, int orderId, List<Integer> comboIds, 
                                   List<Integer> comboQuantities, List<Long> comboPrices) throws SQLException {
        if (comboIds == null || comboIds.isEmpty()) {
            return true; // No combos to add
        }
        
        if (comboQuantities == null || comboQuantities.size() != comboIds.size()) {
            throw new SQLException("comboIds and comboQuantities must have same length");
        }
        
        if (comboPrices == null || comboPrices.size() != comboIds.size()) {
            throw new SQLException("comboIds and comboPrices must have same length");
        }
        
        String sql = "INSERT INTO OrderCombo (OrderId, ComboId, Quantity, Price, CreatedAt) "
                + "VALUES (?, ?, ?, ?, GETDATE())";
        
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < comboIds.size(); i++) {
                ps.setInt(1, orderId);
                ps.setInt(2, comboIds.get(i));
                ps.setInt(3, comboQuantities.get(i));
                ps.setLong(4, comboPrices.get(i));
                ps.addBatch();
            }
            
            ps.executeBatch();
            return true;
        }
    }
}

