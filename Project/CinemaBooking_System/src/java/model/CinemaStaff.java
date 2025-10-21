package model;

import java.sql.Timestamp;

public class CinemaStaff {
    private int id;
    private int cinemaId;
    private int staffId;
    private String roleInCinema;
    private Timestamp assignedAt;
    private boolean status;
    
    // Thông tin thêm từ join
    private String cinemaName;
    private String staffName;
    private String staffEmail;
    
    // ===== CONSTRUCTORS =====
    public CinemaStaff() {}
    
    public CinemaStaff(int cinemaId, int staffId, String roleInCinema, boolean status) {
        this.cinemaId = cinemaId;
        this.staffId = staffId;
        this.roleInCinema = roleInCinema;
        this.status = status;
    }
    
    // ===== GETTERS & SETTERS =====
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getCinemaId() { return cinemaId; }
    public void setCinemaId(int cinemaId) { this.cinemaId = cinemaId; }
    
    public int getStaffId() { return staffId; }
    public void setStaffId(int staffId) { this.staffId = staffId; }
    
    public String getRoleInCinema() { return roleInCinema; }
    public void setRoleInCinema(String roleInCinema) { this.roleInCinema = roleInCinema; }
    
    public Timestamp getAssignedAt() { return assignedAt; }
    public void setAssignedAt(Timestamp assignedAt) { this.assignedAt = assignedAt; }
    
    public boolean isStatus() { return status; }
    public void setStatus(boolean status) { this.status = status; }
    
    public String getCinemaName() { return cinemaName; }
    public void setCinemaName(String cinemaName) { this.cinemaName = cinemaName; }
    
    public String getStaffName() { return staffName; }
    public void setStaffName(String staffName) { this.staffName = staffName; }
    
    public String getStaffEmail() { return staffEmail; }
    public void setStaffEmail(String staffEmail) { this.staffEmail = staffEmail; }
    
    // ===== HELPER METHODS =====
    public String getStatusText() {
        return this.status ? "Đang làm việc" : "Đã ngừng";
    }
    
    public String getFormattedAssignedAt() {
        if (assignedAt != null) {
            return new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(assignedAt);
        }
        return "N/A";
    }
}