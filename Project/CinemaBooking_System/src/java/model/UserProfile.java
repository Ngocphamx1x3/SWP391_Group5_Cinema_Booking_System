package model;

import java.util.Date;
import java.util.UUID;

    public class UserProfile {
    private UUID profileId;
    private int userId;
    private String fullName;
    private String gender;
    private Date birthday;
    private String address;
    private String avatarUrl;

    // Constructor
    public UserProfile() {
    }

    public UserProfile(UUID profileId, int userId, String fullName, String gender, Date birthday, String address, String avatarUrl) {
        this.profileId = profileId;
        this.userId = userId;
        this.fullName = fullName;
        this.gender = gender;
        this.birthday = birthday;
        this.address = address;
        this.avatarUrl = avatarUrl;
    }

    // Getter & Setter
    public UUID getProfileId() {
        return profileId;
    }

    public void setProfileId(UUID profileId) {
        this.profileId = profileId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public Date getBirthday() {
        return birthday;
    }

    public void setBirthday(Date birthday) {
        this.birthday = birthday;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }
}