package model;

import java.sql.Timestamp;

public class SeatType {
    private int id;
    private String code;
    private String name;
    private double surcharge;
    private String color;
    private String description;
    private boolean status;
    private Timestamp createdAt;
    private Timestamp updatedAt; 
    
    // ===== CONSTRUCTORS =====
    public SeatType() {}
    
    // Constructor đầy đủ
    public SeatType(int id, String code, String name, double surcharge, String color, 
                   String description, boolean status, Timestamp createdAt, Timestamp updatedAt) {
        this.id = id;
        this.code = code;
        this.name = name;
        this.surcharge = surcharge;
        this.color = color;
        this.description = description;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }
    
    // Constructor không có id và timestamps (dùng khi tạo mới)
    public SeatType(String code, String name, double surcharge, String color, 
                   String description, boolean status) {
        this.code = code;
        this.name = name;
        this.surcharge = surcharge;
        this.color = color;
        this.description = description;
        this.status = status;
    }
    
    // ===== GETTERS & SETTERS =====
    public int getId() { 
        return id; 
    }
    public void setId(int id) { 
        this.id = id; 
    }
    
    public String getCode() { 
        return code; 
    }
    public void setCode(String code) { 
        this.code = code; 
    }
    
    public String getName() { 
        return name; 
    }
    public void setName(String name) { 
        this.name = name; 
    }
    
    public double getSurcharge() { 
        return surcharge; 
    }
    public void setSurcharge(double surcharge) { 
        this.surcharge = surcharge; 
    }
    
    public String getColor() { 
        return color; 
    }
    public void setColor(String color) { 
        this.color = color; 
    }
    
    public String getDescription() { 
        return description; 
    }
    public void setDescription(String description) { 
        this.description = description; 
    }
    
    public boolean isStatus() { 
        return status; 
    }
    public void setStatus(boolean status) { 
        this.status = status; 
    }
    
    public Timestamp getCreatedAt() { 
        return createdAt; 
    }
    public void setCreatedAt(Timestamp createdAt) { 
        this.createdAt = createdAt; 
    }
    
    public Timestamp getUpdatedAt() { 
        return updatedAt; 
    }
    public void setUpdatedAt(Timestamp updatedAt) { 
        this.updatedAt = updatedAt; 
    }
    
    // ===== HELPER METHODS =====
    
    // Format surcharge để hiển thị (VD: 50,000 VND)
    public String getFormattedSurcharge() {
        return String.format("%,d VND", (int) this.surcharge);
    }
    
    // Hiển thị trạng thái dạng text
    public String getStatusText() {
        return this.status ? "Đang hoạt động" : "Ngừng hoạt động";
    }
    
    // Hiển thị màu status 
    public String getStatusColor() {
        return this.status ? "#10b981" : "#ef4444"; 
    }
    
    // Format timestamp để hiển thị
    public String getFormattedCreatedAt() {
        if (createdAt != null) {
            return new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(createdAt);
        }
        return "N/A";
    }
    
    public String getFormattedUpdatedAt() {
        if (updatedAt != null) {
            return new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(updatedAt);
        }
        return "N/A";
    }
    
    @Override
    public String toString() {
        return "SeatType{" +
                "id=" + id +
                ", code='" + code + '\'' +
                ", name='" + name + '\'' +
                ", surcharge=" + surcharge +
                ", color='" + color + '\'' +
                ", description='" + description + '\'' +
                ", status=" + status +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}