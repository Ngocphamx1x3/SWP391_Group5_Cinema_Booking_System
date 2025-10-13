package dal;

import util.DBContext;

import java.sql.*;
import model.UserProfile;
import model.Users;
import util.DBContext;

public class UserDAO extends DBContext {

    // kiểm tra username hoặc email đã tồn tại
    public boolean existsByUsernameOrEmail(String username, String email) throws SQLException {
        String sql = "SELECT COUNT(*) FROM dbo.Users WHERE Username = ? OR Email = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, email);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1) > 0;
            }
        } catch (ClassNotFoundException ex) {
            throw new SQLException(ex);
        }
    }

    // tạo user, trả về generated Id (assume Users.Id is IDENTITY)
    public long createUser(String email, String phoneNumber, String password, String username,
            String role, int status, String verificationCode, Timestamp verificationExpiresAt) throws SQLException {
        String sql = "INSERT INTO dbo.Users (Email, PhoneNumber, Password, Point, Username, Role, Status, CreatedAt, UpdatedAt, EmailConfirmed, VerificationCode, VerificationExpiresAt) "
                + "VALUES (?, ?, ?, 0, ?, ?, ?, SYSUTCDATETIME(), SYSUTCDATETIME(), 0, ?, ?)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, email);
            ps.setString(2, phoneNumber);
            ps.setString(3, password);
            ps.setString(4, username);
            ps.setString(5, role);
            ps.setInt(6, status);
            ps.setString(7, verificationCode);
            ps.setTimestamp(8, verificationExpiresAt);
            int rows = ps.executeUpdate();
            if (rows == 0) {
                throw new SQLException("Creating user failed, no rows affected.");
            }
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getLong(1);
                } else {
                    throw new SQLException("Creating user failed, no ID obtained.");
                }
            }
        } catch (ClassNotFoundException ex) {
            throw new SQLException(ex);
        }
    }

    // tạo userprofile (FullName)
    public boolean createUserProfile(long userId, String fullName) throws SQLException {
        String sql = "INSERT INTO dbo.UserProfile (UserId, FullName) VALUES (?, ?)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setString(2, fullName);
            return ps.executeUpdate() == 1;
        } catch (ClassNotFoundException ex) {
            throw new SQLException(ex);
        }
    }

    // verify code: nếu đúng và chưa hết hạn -> set EmailConfirmed = 1 và clear code
    public boolean verifyCode(String email, String code) throws SQLException {
        String sql = "UPDATE dbo.Users SET EmailConfirmed = 1, VerificationCode = NULL, VerificationExpiresAt = NULL, UpdatedAt = SYSUTCDATETIME() "
                + "WHERE Email = ? AND VerificationCode = ? AND VerificationExpiresAt > SYSUTCDATETIME()";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, code);
            int rows = ps.executeUpdate();
            return rows == 1;
        } catch (ClassNotFoundException ex) {
            throw new SQLException(ex);
        }
    }

    public void updateUser(Users user) {
        String sql = "UPDATE Users SET Username = ?, PhoneNumber = ? WHERE Id = ?";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getPhoneNumber());
            ps.setLong(3, user.getId());
            ps.executeUpdate();
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    public void updateOrInsertUserProfile(UserProfile profile) {
        if (existsUserProfile(profile.getUserId())) {
            updateUserProfile(profile);
        } else {
            insertUserProfile(profile);
        }
    }

    private boolean existsUserProfile(long userId) {
        String sql = "SELECT COUNT(*) FROM UserProfile WHERE UserId = ?";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return false;
    }

    private void insertUserProfile(UserProfile profile) {
        String sql = "INSERT INTO UserProfile (UserId, FullName, Gender, Birthday, Address, AvatarUrl) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, profile.getUserId());
            ps.setString(2, profile.getFullName());
            ps.setString(3, profile.getGender());
            if (profile.getBirthday() != null) {
                ps.setDate(4, new java.sql.Date(profile.getBirthday().getTime()));
            } else {
                ps.setNull(4, Types.DATE);
            }
            ps.setString(5, profile.getAddress());
            ps.setString(6, profile.getAvatarUrl());
            ps.executeUpdate();
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    private void updateUserProfile(UserProfile profile) {
        String sql = "UPDATE UserProfile SET FullName = ?, Gender = ?, Birthday = ?, Address = ?, AvatarUrl = ? WHERE UserId = ?";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, profile.getFullName());
            ps.setString(2, profile.getGender());
            if (profile.getBirthday() != null) {
                ps.setDate(3, new java.sql.Date(profile.getBirthday().getTime()));
            } else {
                ps.setNull(3, Types.DATE);
            }
            ps.setString(4, profile.getAddress());
            ps.setString(5, profile.getAvatarUrl());
            ps.setLong(6, profile.getUserId());
            ps.executeUpdate();
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    public UserProfile getUserProfileByUserId(long userId) {
        String sql = "SELECT * FROM UserProfile WHERE UserId = ?";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                UserProfile profile = new UserProfile();
                profile.setUserId(rs.getInt("UserId"));
                profile.setFullName(rs.getString("FullName"));
                profile.setGender(rs.getString("Gender"));
                profile.setBirthday(rs.getDate("Birthday"));
                profile.setAddress(rs.getString("Address"));
                profile.setAvatarUrl(rs.getString("AvatarUrl"));
                return profile;
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return null;
    }

}
