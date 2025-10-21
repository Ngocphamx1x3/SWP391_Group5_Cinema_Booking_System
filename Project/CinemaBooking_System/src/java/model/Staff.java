package model;

import java.sql.Timestamp;

public class Staff {
    private int id;
    private String email;
    private String phoneNumber;
    private String username;
    private String role;
    private boolean status;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private Integer currentCinemaId;
    
    // Thông tin từ join với cinema_staff và cinema
    private String cinemaName;
    private String roleInCinema;
    private Timestamp assignedAt;
    private boolean assignmentStatus;
    
    // ===== CONSTRUCTORS =====
    public Staff() {}
    
    // Constructor cho thêm mới staff (KHÔNG có id)
    public Staff(String email, String phoneNumber, String username, String role, boolean status) {
        this.email = email;
        this.phoneNumber = phoneNumber;
        this.username = username;
        this.role = role;
        this.status = status;
    }
    
    // Constructor đầy đủ (có id)
    public Staff(int id, String email, String phoneNumber, String username, String role, boolean status) {
        this.id = id;
        this.email = email;
        this.phoneNumber = phoneNumber;
        this.username = username;
        this.role = role;
        this.status = status;
    }
    
    // ===== GETTERS & SETTERS =====
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
    
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    
    public boolean isStatus() { return status; }
    public void setStatus(boolean status) { this.status = status; }
    
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    
    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
    
    public Integer getCurrentCinemaId() { return currentCinemaId; }
    public void setCurrentCinemaId(Integer currentCinemaId) { this.currentCinemaId = currentCinemaId; }
    
    public String getCinemaName() { return cinemaName; }
    public void setCinemaName(String cinemaName) { this.cinemaName = cinemaName; }
    
    public String getRoleInCinema() { return roleInCinema; }
    public void setRoleInCinema(String roleInCinema) { this.roleInCinema = roleInCinema; }
    
    public Timestamp getAssignedAt() { return assignedAt; }
    public void setAssignedAt(Timestamp assignedAt) { this.assignedAt = assignedAt; }
    
    public boolean isAssignmentStatus() { return assignmentStatus; }
    public void setAssignmentStatus(boolean assignmentStatus) { this.assignmentStatus = assignmentStatus; }
    
    // ===== HELPER METHODS =====
    public String getStatusText() {
        return this.status ? "Đang hoạt động" : "Ngừng hoạt động";
    }
    
    public String getAssignmentStatusText() {
        return this.assignmentStatus ? "Đang làm việc" : "Đã ngừng";
    }
    
    public String getFormattedCreatedAt() {
        if (createdAt != null) {
            return new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(createdAt);
        }
        return "N/A";
    }
    
    public String getFormattedAssignedAt() {
        if (assignedAt != null) {
            return new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(assignedAt);
        }
        return "Chưa phân công";
    }
    
    public String getCinemaInfo() {
        if (cinemaName != null && !cinemaName.trim().isEmpty()) {
            return cinemaName + (roleInCinema != null ? " - " + roleInCinema : "");
        }
        return "Chưa phân công";
    }
    
    public boolean hasCinemaAssignment() {
        return cinemaName != null && !cinemaName.trim().isEmpty();
    }
    
    public String getRoleDisplayName() {
        switch (this.role) {
            case "admin": return "Quản trị viên";
            case "manager": return "Quản lý rạp"; 
            case "staff": return "Nhân viên";
            case "support": return "Hỗ trợ KH";
            default: return this.role;
        }
    }
}