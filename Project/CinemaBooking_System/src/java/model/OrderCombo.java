/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
// OrderCombo.java
package model;

import java.sql.Timestamp;

public class OrderCombo {
    private int id;
    private int orderId;
    private int comboId;
    private int quantity;
    private long price;
    private Timestamp createdAt;
    
    // Additional info from join
    private String comboName;
    private String comboImage;
    
    // Constructors
    public OrderCombo() {}
    
    public OrderCombo(int id, int orderId, int comboId, int quantity, long price, Timestamp createdAt) {
        this.id = id;
        this.orderId = orderId;
        this.comboId = comboId;
        this.quantity = quantity;
        this.price = price;
        this.createdAt = createdAt;
    }
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }
    
    public int getComboId() { return comboId; }
    public void setComboId(int comboId) { this.comboId = comboId; }
    
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    
    public long getPrice() { return price; }
    public void setPrice(long price) { this.price = price; }
    
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    
    public String getComboName() { return comboName; }
    public void setComboName(String comboName) { this.comboName = comboName; }
    
    public String getComboImage() { return comboImage; }
    public void setComboImage(String comboImage) { this.comboImage = comboImage; }
    
    // Helper methods
    public String getFormattedPrice() {
        return String.format("%,d", this.price) + " đ";
    }
    
    public long getSubTotal() {
        return this.price * this.quantity;
    }
    
    public String getFormattedSubTotal() {
        return String.format("%,d", getSubTotal()) + " đ";
    }
    
    public String getImageUrl() {
        if (comboImage != null && !comboImage.isEmpty()) {
            return "${pageContext.request.contextPath}/assets/user/img/" + comboImage;
        }
        return "${pageContext.request.contextPath}/assets/user/img/default-combo.png";
    }
}
