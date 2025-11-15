package model;

public class ComboItem {
    private int comboID;
    private int itemID;
    private int quantity;

    // Thông tin từ join với FoodItem
    private FoodItem foodItem;

    // Thông tin từ join với FoodCombo
    private FoodCombo foodCombo;

    // Constructors
    public ComboItem() {}

    public ComboItem(int comboID, int itemID, int quantity) {
        this.comboID = comboID;
        this.itemID = itemID;
        this.quantity = quantity;
    }

    // Getters and Setters
    public int getComboID() { return comboID; }
    public void setComboID(int comboID) { this.comboID = comboID; }

    public int getItemID() { return itemID; }
    public void setItemID(int itemID) { this.itemID = itemID; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public FoodItem getFoodItem() { return foodItem; }
    public void setFoodItem(FoodItem foodItem) { this.foodItem = foodItem; }

    public FoodCombo getFoodCombo() { return foodCombo; }
    public void setFoodCombo(FoodCombo foodCombo) { this.foodCombo = foodCombo; }

    // Helper methods
    /**
     * Tính giá trị của item này trong combo (price * quantity)
     */
    public double getSubTotal() {
        if (foodItem != null) {
            return foodItem.getPrice() * quantity;
        }
        return 0;
    }

    /**
     * Format sub total thành chuỗi tiền tệ
     */
    public String getFormattedSubTotal() {
        return String.format("%,.0f", getSubTotal()) + " đ";
    }

    /**
     * Lấy tên item (nếu có)
     */
    public String getItemName() {
        return foodItem != null ? foodItem.getName() : "N/A";
    }

    /**
     * Lấy giá item đơn lẻ (nếu có)
     */
    public double getItemPrice() {
        return foodItem != null ? foodItem.getPrice() : 0;
    }

    /**
     * Format giá item thành chuỗi tiền tệ
     */
    public String getFormattedItemPrice() {
        return String.format("%,.0f", getItemPrice()) + " đ";
    }
}

