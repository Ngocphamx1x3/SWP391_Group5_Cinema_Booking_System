package model;

import java.util.Date;

    // Class Users
    public class Users {
    private int id;
    private String email;
    private String phoneNumber;
    private String password;
    private int point;
    private String username;
    private String role;
    private String status;
    private Date createdAt;
    private Date updatedAt;
    private int emailConfirmed;

    // Constructor
    public Users() {
    }

        public Users(int id, String email, String phoneNumber, String password, int point, String username, String role, String status, Date createdAt, Date updatedAt) {
            this.id = id;
            this.email = email;
            this.phoneNumber = phoneNumber;
            this.password = password;
            this.point = point;
            this.username = username;
            this.role = role;
            this.status = status;
            this.createdAt = createdAt;
            this.updatedAt = updatedAt;
        }

    // Getter & Setter
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public int getPoint() {
        return point;
    }

    public void setPoint(int point) {
        this.point = point;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }
    
    public Date getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Date updatedAt) {
        this.updatedAt = updatedAt;
    }
    public int getEmailConfirmed() {
    return emailConfirmed;
}

public void setEmailConfirmed(int emailConfirmed) {
    this.emailConfirmed = emailConfirmed;
}
}