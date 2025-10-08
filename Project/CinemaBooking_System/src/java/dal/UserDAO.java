package dal;

import util.DBContext;

import java.sql.*;

public class UserDAO extends DBContext {

    // kiểm tra username hoặc email đã tồn tại
    public boolean existsByUsernameOrEmail(String username, String email) throws SQLException {
        String sql = "SELECT COUNT(*) FROM dbo.Users WHERE Username = ? OR Email = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
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
        String sql = "INSERT INTO dbo.Users (Email, PhoneNumber, Password, Point, Username, Role, Status, CreatedAt, UpdatedAt, EmailConfirmed, VerificationCode, VerificationExpiresAt) " +
                     "VALUES (?, ?, ?, 0, ?, ?, ?, SYSUTCDATETIME(), SYSUTCDATETIME(), 0, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, email);
            ps.setString(2, phoneNumber);
            ps.setString(3, password);
            ps.setString(4, username);
            ps.setString(5, role);
            ps.setInt(6, status);
            ps.setString(7, verificationCode);
            ps.setTimestamp(8, verificationExpiresAt);
            int rows = ps.executeUpdate();
            if (rows == 0) throw new SQLException("Creating user failed, no rows affected.");
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getLong(1);
                else throw new SQLException("Creating user failed, no ID obtained.");
            }
        } catch (ClassNotFoundException ex) {
            throw new SQLException(ex);
        }
    }

    // tạo userprofile (FullName)
    public boolean createUserProfile(long userId, String fullName) throws SQLException {
        String sql = "INSERT INTO dbo.UserProfile (UserId, FullName) VALUES (?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setString(2, fullName);
            return ps.executeUpdate() == 1;
        } catch (ClassNotFoundException ex) {
            throw new SQLException(ex);
        }
    }

    // verify code: nếu đúng và chưa hết hạn -> set EmailConfirmed = 1 và clear code
    public boolean verifyCode(String email, String code) throws SQLException {
        String sql = "UPDATE dbo.Users SET EmailConfirmed = 1, VerificationCode = NULL, VerificationExpiresAt = NULL, UpdatedAt = SYSUTCDATETIME() " +
                     "WHERE Email = ? AND VerificationCode = ? AND VerificationExpiresAt > SYSUTCDATETIME()";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, code);
            int rows = ps.executeUpdate();
            return rows == 1;
        } catch (ClassNotFoundException ex) {
            throw new SQLException(ex);
        }
    }
}
