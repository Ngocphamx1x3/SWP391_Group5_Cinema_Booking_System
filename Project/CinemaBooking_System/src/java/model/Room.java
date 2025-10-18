package model;

import java.sql.Timestamp;

public class Room {
    private int id;
    private int cinemaId;
    private String code;
    private String name;
    private String description;
    private int capacity;
    private int seatRows;
    private int seatColumns;
    private String screenType;
    private String soundSystem;
    private boolean status;
    private Timestamp createdDate;
    private Timestamp updatedDate;
    
    // ===== CONSTRUCTORS =====
    public Room() {}
    
    public Room(int cinemaId, String code, String name, String description, 
                int capacity, int seatRows, int seatColumns, String screenType, 
                String soundSystem, boolean status) {
        this.cinemaId = cinemaId;
        this.code = code;
        this.name = name;
        this.description = description;
        this.capacity = capacity;
        this.seatRows = seatRows;
        this.seatColumns = seatColumns;
        this.screenType = screenType;
        this.soundSystem = soundSystem;
        this.status = status;
    }
    
    // ===== GETTERS & SETTERS =====
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getCinemaId() { return cinemaId; }
    public void setCinemaId(int cinemaId) { this.cinemaId = cinemaId; }
    
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public int getCapacity() { return capacity; }
    public void setCapacity(int capacity) { this.capacity = capacity; }
    
    public int getSeatRows() { return seatRows; }
    public void setSeatRows(int seatRows) { this.seatRows = seatRows; }
    
    public int getSeatColumns() { return seatColumns; }
    public void setSeatColumns(int seatColumns) { this.seatColumns = seatColumns; }
    
    public String getScreenType() { return screenType; }
    public void setScreenType(String screenType) { this.screenType = screenType; }
    
    public String getSoundSystem() { return soundSystem; }
    public void setSoundSystem(String soundSystem) { this.soundSystem = soundSystem; }
    
    public boolean isStatus() { return status; }
    public void setStatus(boolean status) { this.status = status; }
    
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
}