package controller;

import dal.UserDAO;
import model.Users;
import util.EmailUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Timestamp;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Random;
import java.util.regex.Pattern;

@WebServlet(name = "ChangeEmailController", urlPatterns = {"/changeEmail", "/verifyEmailChange"})
public class ChangeEmailController extends HttpServlet {

    private UserDAO userDao;
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");

    @Override
    public void init() {
        userDao = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        Users user = (Users) session.getAttribute("account");

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        req.getRequestDispatcher("/views/users/changeEmail.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        HttpSession session = req.getSession();
        Users user = (Users) session.getAttribute("account");

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        switch (path) {
            case "/changeEmail":
                handleChangeEmailRequest(req, resp, user);
                break;
            case "/verifyEmailChange":
                handleVerifyEmailChange(req, resp, user);
                break;
        }
    }

    private void handleChangeEmailRequest(HttpServletRequest req, HttpServletResponse resp, Users user) 
            throws ServletException, IOException {
        
        String newEmail = req.getParameter("newEmail");
        String password = req.getParameter("password");

        // Validate input
        if (newEmail == null || newEmail.isEmpty() || password == null || password.isEmpty()) {
            req.setAttribute("error", "Vui lòng điền đầy đủ thông tin");
            req.getRequestDispatcher("/views/users/changeEmail.jsp").forward(req, resp);
            return;
        }

        // Validate email format
        if (!EMAIL_PATTERN.matcher(newEmail).matches()) {
            req.setAttribute("error", "Email không đúng định dạng");
            req.getRequestDispatcher("/views/users/changeEmail.jsp").forward(req, resp);
            return;
        }

        // Check if new email is different from current email
        if (newEmail.equals(user.getEmail())) {
            req.setAttribute("error", "Email mới phải khác email hiện tại");
            req.getRequestDispatcher("/views/users/changeEmail.jsp").forward(req, resp);
            return;
        }

        // Verify password
        if (!verifyPassword(user.getId(), password)) {
            req.setAttribute("error", "Mật khẩu không chính xác");
            req.getRequestDispatcher("/views/users/changeEmail.jsp").forward(req, resp);
            return;
        }

        // Check if new email already exists
        try {
            if (userDao.existsByUsernameOrEmail(newEmail, newEmail)) {
                req.setAttribute("error", "Email này đã được sử dụng bởi tài khoản khác");
                req.getRequestDispatcher("/views/users/changeEmail.jsp").forward(req, resp);
                return;
            }

            // Generate verification code
            int n = new Random().nextInt(1_000_000);
            String code = String.format("%06d", n);
            Timestamp expires = Timestamp.from(Instant.now().plus(24, ChronoUnit.HOURS));

            // Store verification code in session temporarily
            HttpSession session = req.getSession();
            session.setAttribute("emailVerificationCode", code);
            session.setAttribute("emailVerificationExpires", expires);
            session.setAttribute("pendingNewEmail", newEmail);

            // Send verification email
            String subject = "Mã xác thực đổi email - CinemaBooking";
            String body = buildEmailVerificationBody(user.getUsername(), code);
            
            boolean mailOk = EmailUtil.sendHtmlEmail(newEmail, subject, body);

            if (mailOk) {
                req.setAttribute("verificationSent", true);
                req.setAttribute("newEmail", newEmail);
                req.setAttribute("successMessage", "Mã xác thực đã được gửi đến email mới!");
            } else {
                req.setAttribute("error", "Không thể gửi email xác thực. Vui lòng thử lại sau.");
            }

            req.getRequestDispatcher("/views/users/changeEmail.jsp").forward(req, resp);

        } catch (Exception ex) {
            ex.printStackTrace();
            req.setAttribute("error", "Lỗi server: " + ex.getMessage());
            req.getRequestDispatcher("/views/users/changeEmail.jsp").forward(req, resp);
        }
    }

    private void handleVerifyEmailChange(HttpServletRequest req, HttpServletResponse resp, Users user) 
            throws ServletException, IOException {
        
        String verificationCode = req.getParameter("verificationCode");
        String newEmail = req.getParameter("newEmail");

        HttpSession session = req.getSession();
        String storedCode = (String) session.getAttribute("emailVerificationCode");
        Timestamp storedExpires = (Timestamp) session.getAttribute("emailVerificationExpires");
        String pendingEmail = (String) session.getAttribute("pendingNewEmail");

        // Validate verification
        if (verificationCode == null || verificationCode.isEmpty() || 
            newEmail == null || newEmail.isEmpty() ||
            storedCode == null || storedExpires == null || 
            !newEmail.equals(pendingEmail)) {
            
            // Chuyển hướng đến trang kết quả với thông báo lỗi
            req.setAttribute("success", false);
            req.setAttribute("error", "Thông tin xác thực không hợp lệ");
            req.setAttribute("retryUrl", req.getContextPath() + "/changeEmail");
            req.getRequestDispatcher("/views/users/verify_result.jsp").forward(req, resp);
            return;
        }

        // Check if code is expired
        if (storedExpires.before(Timestamp.from(Instant.now()))) {
            req.setAttribute("success", false);
            req.setAttribute("error", "Mã xác thực đã hết hạn. Vui lòng yêu cầu mã mới.");
            req.setAttribute("retryUrl", req.getContextPath() + "/changeEmail");
            req.getRequestDispatcher("/views/users/verify_result.jsp").forward(req, resp);
            return;
        }

        // Verify code
        if (!storedCode.equals(verificationCode)) {
            req.setAttribute("success", false);
            req.setAttribute("error", "Mã xác thực không chính xác");
            req.setAttribute("retryUrl", req.getContextPath() + "/changeEmail");
            req.getRequestDispatcher("/views/users/verify_result.jsp").forward(req, resp);
            return;
        }

        // Update email in database
        try {
            boolean updateSuccess = updateUserEmail(user.getId(), newEmail);
            
            if (updateSuccess) {
                // Update user object in session
                user.setEmail(newEmail);
                session.setAttribute("account", user);
                
                // Clear verification data
                session.removeAttribute("emailVerificationCode");
                session.removeAttribute("emailVerificationExpires");
                session.removeAttribute("pendingNewEmail");
                
                // Chuyển hướng đến trang kết quả thành công
                req.setAttribute("success", true);
                req.setAttribute("message", "Đổi email thành công!");
                req.setAttribute("subMessage", "Email của bạn đã được cập nhật thành: " + newEmail);
                req.setAttribute("redirectUrl", req.getContextPath() + "/userProfile");
                req.setAttribute("autoRedirect", true);
                req.getRequestDispatcher("/views/users/verify_result.jsp").forward(req, resp);
                
            } else {
                req.setAttribute("success", false);
                req.setAttribute("error", "Không thể cập nhật email. Vui lòng thử lại.");
                req.setAttribute("retryUrl", req.getContextPath() + "/changeEmail");
                req.getRequestDispatcher("/views/users/verify_result.jsp").forward(req, resp);
            }
            
        } catch (Exception ex) {
            ex.printStackTrace();
            req.setAttribute("success", false);
            req.setAttribute("error", "Lỗi server khi cập nhật email");
            req.setAttribute("errorDetail", ex.getMessage());
            req.setAttribute("retryUrl", req.getContextPath() + "/changeEmail");
            req.getRequestDispatcher("/views/users/verify_result.jsp").forward(req, resp);
        }
    }

    private boolean verifyPassword(int userId, String password) {
        // Implement proper password verification
        Users user = userDao.getUserById(userId);
        return user != null && user.getPassword().equals(password);
    }

    private boolean updateUserEmail(int userId, String newEmail) {
        String sql = "UPDATE Users SET Email = ?, UpdatedAt = SYSUTCDATETIME() WHERE Id = ?";
        try (var conn = new util.DBContext().getConnection();
             var ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, newEmail);
            ps.setInt(2, userId);
            
            return ps.executeUpdate() == 1;
            
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private String buildEmailVerificationBody(String username, String code) {
        return "<!DOCTYPE html>"
                + "<html>"
                + "<head>"
                + "<meta charset='UTF-8'>"
                + "<style>"
                + "body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }"
                + ".container { max-width: 600px; margin: 0 auto; padding: 20px; }"
                + ".header { background-color: #17a2b8; color: white; padding: 20px; text-align: center; }"
                + ".content { background-color: #f9f9f9; padding: 30px; border-radius: 5px; }"
                + ".code { background-color: #fff; padding: 20px; border: 2px dashed #17a2b8; margin: 20px 0; font-size: 32px; font-weight: bold; text-align: center; letter-spacing: 5px; color: #17a2b8; }"
                + ".instruction { background-color: #d1ecf1; padding: 15px; border-radius: 5px; border-left: 4px solid #17a2b8; }"
                + ".footer { text-align: center; margin-top: 20px; color: #777; font-size: 12px; }"
                + "</style>"
                + "</head>"
                + "<body>"
                + "<div class='container'>"
                + "<div class='header'>"
                + "<h1>📧 Xác thực Đổi Email - CinemaBooking</h1>"
                + "</div>"
                + "<div class='content'>"
                + "<h2>Xin chào " + escape(username) + "!</h2>"
                + "<p>Bạn đang yêu cầu thay đổi địa chỉ email cho tài khoản Cinema Booking System.</p>"
                + "<p>Để hoàn tất quá trình thay đổi email, vui lòng sử dụng mã xác thực sau:</p>"
                + "<div class='code'>" + code + "</div>"
                + "<div class='instruction'>"
                + "<p><strong>Hướng dẫn sử dụng:</strong></p>"
                + "<ol>"
                + "<li>Quay lại trang đổi email</li>"
                + "<li>Nhập mã xác thực 6 số ở trên</li>"
                + "<li>Hoàn tất xác thực để đổi email</li>"
                + "</ol>"
                + "</div>"
                + "<p><strong>Lưu ý quan trọng:</strong></p>"
                + "<ul>"
                + "<li>Mã xác thực có hiệu lực trong 24 giờ</li>"
                + "<li>Không chia sẻ mã này với bất kỳ ai</li>"
                + "<li>Nếu bạn không yêu cầu đổi email, vui lòng bỏ qua email này</li>"
                + "</ul>"
                + "</div>"
                + "<div class='footer'>"
                + "<p>© 2025 Cinema Booking System. All rights reserved.</p>"
                + "<p>Email này được gửi tự động, vui lòng không trả lời.</p>"
                + "</div>"
                + "</div>"
                + "</body>"
                + "</html>";
    }

    private String escape(String s) {
        if (s == null) {
            return "";
        }
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;");
    }
}