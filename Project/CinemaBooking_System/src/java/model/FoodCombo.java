package model;

import java.sql.Timestamp;
import java.util.List;

public class FoodCombo {
    private int comboID;
    private String name;
    private String description;
    private double price;
    private String image;
    private int createdBy;
    private Timestamp createdDate;
    private Timestamp updatedDate;
    private Integer updatedBy;
    private boolean status;
    
    // Danh sách món trong combo
    private List<ComboItem> items;

    // Constructors
    public FoodCombo() {}

    public FoodCombo(String name, String description, double price, String image, int createdBy, boolean status) {
        this.name = name;
        this.description = description;
        this.price = price;
        this.image = image;
        this.createdBy = createdBy;
        this.status = status;
    }

    public FoodCombo(int comboID, String name, String description, double price, String image,
            int createdBy, Timestamp createdDate, Timestamp updatedDate, Integer updatedBy, boolean status) {
        this.comboID = comboID;
        this.name = name;
        this.description = description;
        this.price = price;
        this.image = image;
        this.createdBy = createdBy;
        this.createdDate = createdDate;
        this.updatedDate = updatedDate;
        this.updatedBy = updatedBy;
        this.status = status;
    }

    // Getters and Setters
    public int getComboID() { return comboID; }
    public void setComboID(int comboID) { this.comboID = comboID; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }

    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }

    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }

    public Timestamp getCreatedDate() { return createdDate; }
    public void setCreatedDate(Timestamp createdDate) { this.createdDate = createdDate; }

    public Timestamp getUpdatedDate() { return updatedDate; }
    public void setUpdatedDate(Timestamp updatedDate) { this.updatedDate = updatedDate; }

    public Integer getUpdatedBy() { return updatedBy; }
    public void setUpdatedBy(Integer updatedBy) { this.updatedBy = updatedBy; }

    public boolean getStatus() { return status; }
    public void setStatus(boolean status) { this.status = status; }

    public List<ComboItem> getItems() { return items; }
    public void setItems(List<ComboItem> items) { this.items = items; }

    // Helper methods
    public String getStatusText() {
        return this.status ? "Còn bán" : "Ngừng bán";
    }

    public String getFormattedPrice() {
        return String.format("%,.0f", this.price) + " đ";
    }

    public String getFormattedCreatedDate() {
        if (createdDate != null) {
            return new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(createdDate);
        }
        return "N/A";
    }

    public String getFormattedUpdatedDate() {
        if (updatedDate != null) {
            return new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(updatedDate);
        }
        return "Chưa cập nhật";
    }

    /**
     * Tính tổng số lượng món trong combo
     */
    public int getTotalItemsCount() {
        if (items == null || items.isEmpty()) {
            return 0;
        }
        return items.stream().mapToInt(ComboItem::getQuantity).sum();
    }

    /**
     * Tính tổng giá trị gốc của tất cả món trong combo
     */
    public double getTotalOriginalPrice() {
        if (items == null || items.isEmpty()) {
            return 0;
        }
        return items.stream()
                .mapToDouble(ci -> ci.getFoodItem() != null ? 
                    ci.getFoodItem().getPrice() * ci.getQuantity() : 0)
                .sum();
    }

    /**
     * Tính số tiền tiết kiệm (giá gốc - giá combo)
     */
    public double getSavings() {
        return getTotalOriginalPrice() - price;
    }

    /**
     * Format số tiền tiết kiệm
     */
    public String getFormattedSavings() {
        double savings = getSavings();
        if (savings > 0) {
            return "Tiết kiệm: " + String.format("%,.0f", savings) + " đ";
        }
        return "";
    }
}
