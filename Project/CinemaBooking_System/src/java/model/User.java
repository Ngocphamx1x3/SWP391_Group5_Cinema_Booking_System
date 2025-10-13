package model;

import java.sql.Timestamp;

public class User {
    private long id;
    private String email;
    private String phoneNumber;
    private String password;
    private int point;
    private String username;
    private String role;
    private int status;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private boolean emailConfirmed;
    private String verificationCode;
    private Timestamp verificationExpiresAt;

    // getters / setters
    public long getId() { return id; }
    public void setId(long id) { this.id = id; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public int getPoint() { return point; }
    public void setPoint(int point) { this.point = point; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public int getStatus() { return status; }
    public void setStatus(int status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public boolean isEmailConfirmed() { return emailConfirmed; }
    public void setEmailConfirmed(boolean emailConfirmed) { this.emailConfirmed = emailConfirmed; }

    public String getVerificationCode() { return verificationCode; }
    public void setVerificationCode(String verificationCode) { this.verificationCode = verificationCode; }

    public Timestamp getVerificationExpiresAt() { return verificationExpiresAt; }
    public void setVerificationExpiresAt(Timestamp verificationExpiresAt) { this.verificationExpiresAt = verificationExpiresAt; }
}
