package model;

import java.sql.Timestamp;

public class FoodItem {
    private int itemID;
    private String name;
    private String type;
    private double price;
    private String image;
    private String description;
    private boolean status;
    private Timestamp createdDate;
    private Timestamp updatedDate;

    // Constructors
    public FoodItem() {}

    public FoodItem(String name, String type, double price, String image, String description, boolean status) {
        this.name = name;
        this.type = type;
        this.price = price;
        this.image = image;
        this.description = description;
        this.status = status;
    }

    public FoodItem(int itemID, String name, String type, double price, String image,
            String description, boolean status, Timestamp createdDate, Timestamp updatedDate) {
        this.itemID = itemID;
        this.name = name;
        this.type = type;
        this.price = price;
        this.image = image;
        this.description = description;
        this.status = status;
        this.createdDate = createdDate;
        this.updatedDate = updatedDate;
    }

    // Getters and Setters
    public int getItemID() { return itemID; }
    public void setItemID(int itemID) { this.itemID = itemID; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }

    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public boolean getStatus() { return status; }
    public void setStatus(boolean status) { this.status = status; }

    public Timestamp getCreatedDate() { return createdDate; }
    public void setCreatedDate(Timestamp createdDate) { this.createdDate = createdDate; }

    public Timestamp getUpdatedDate() { return updatedDate; }
    public void setUpdatedDate(Timestamp updatedDate) { this.updatedDate = updatedDate; }

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

    public String getTypeDisplayName() {
        if (type == null) return "Khác";
        switch (type.toLowerCase()) {
            case "popcorn": return "Bắp rang";
            case "drink": return "Nước uống";
            case "snack": return "Đồ ăn vặt";
            default: return type;
        }
    }
}

