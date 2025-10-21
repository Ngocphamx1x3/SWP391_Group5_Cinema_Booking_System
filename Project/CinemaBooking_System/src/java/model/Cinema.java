package model;

import java.sql.Timestamp;

public class Cinema {
    private int id;
    private String code;
    private String name;
    private String address;
    private String description;
    private int capacity;
    private boolean status;
    private String phone;
    private int totalRooms;
    private String operatingHours;
    private Timestamp createdDate;
    private Timestamp updatedDate;
    
    // ===== CONSTRUCTORS =====
    public Cinema() {}
    
    public Cinema(String code, String name, String address, String description, 
                  int capacity, boolean status, String phone, int totalRooms, 
                  String operatingHours) {
        this.code = code;
        this.name = name;
        this.address = address;
        this.description = description;
        this.capacity = capacity;
        this.status = status;
        this.phone = phone;
        this.totalRooms = totalRooms;
        this.operatingHours = operatingHours;
    }
    
    // ===== GETTERS & SETTERS =====
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public int getCapacity() { return capacity; }
    public void setCapacity(int capacity) { this.capacity = capacity; }
    
    public boolean isStatus() { return status; }
    public void setStatus(boolean status) { this.status = status; }
    
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    
    public int getTotalRooms() { return totalRooms; }
    public void setTotalRooms(int totalRooms) { this.totalRooms = totalRooms; }
    
    public String getOperatingHours() { return operatingHours; }
    public void setOperatingHours(String operatingHours) { this.operatingHours = operatingHours; }
    
    public Timestamp getCreatedDate() { return createdDate; }
    public void setCreatedDate(Timestamp createdDate) { this.createdDate = createdDate; }
    
    public Timestamp getUpdatedDate() { return updatedDate; }
    public void setUpdatedDate(Timestamp updatedDate) { this.updatedDate = updatedDate; }
    
    // ===== HELPER METHODS =====
    public String getStatusText() {
        return this.status ? "Đang hoạt động" : "Ngừng hoạt động";
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
        return "N/A";
    }
    
    public String getFormattedCapacity() {
        return String.format("%,d ghế", this.capacity);
    }
}