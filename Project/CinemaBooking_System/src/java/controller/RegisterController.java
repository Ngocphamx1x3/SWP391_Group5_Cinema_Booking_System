package controller;

import dal.UserDAO;
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

@WebServlet(name = "RegisterController", urlPatterns = {"/register"})
public class RegisterController extends HttpServlet {

    private UserDAO userDao;
    
    // Regex patterns
    private static final Pattern USERNAME_PATTERN = Pattern.compile("^[a-zA-Z0-9_]{4,15}$");
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    private static final Pattern PASSWORD_PATTERN = Pattern.compile("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,12}$");
    private static final Pattern PHONE_PATTERN = Pattern.compile("^0[0-9]{9}$");

    @Override
    public void init() {
        userDao = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/views/users/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String fullname = req.getParameter("name");
        String username = req.getParameter("username");
        String email = req.getParameter("email");
        String phone = req.getParameter("phoneNumber");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");

        // Validate required fields
        if (fullname == null || email == null || password == null || confirmPassword == null
                || fullname.isEmpty() || email.isEmpty() || password.isEmpty() || confirmPassword.isEmpty()) {
            req.setAttribute("error", "Vui lòng điền đầy đủ thông tin");
            req.getRequestDispatcher("/views/users/register.jsp").forward(req, resp);
            return;
        }

        try {
            // Validate individual fields
            String validationError = validateFields(fullname, username, email, phone, password, confirmPassword);
            if (validationError != null) {
                req.setAttribute("error", validationError);
                req.getRequestDispatcher("/views/users/register.jsp").forward(req, resp);
                return;
            }

            if (username == null || username.isEmpty()) {
                username = email;
            }

            // Check if username or email already exists
            if (userDao.existsByUsernameOrEmail(username, email)) {
                req.setAttribute("error", "Username hoặc Email đã tồn tại");
                req.getRequestDispatcher("/views/users/register.jsp").forward(req, resp);
                return;
            }

            // Tạo mã 6 chữ số
            int n = new Random().nextInt(1_000_000);
            String code = String.format("%06d", n);
            Timestamp expires = Timestamp.from(Instant.now().plus(24, ChronoUnit.HOURS));

            long userId = userDao.createUser(email, phone, password, username, "user", 1, code, expires);
            userDao.createUserProfile(userId, fullname);

            // Gửi email xác thực với mã code
            String subject = "Mã xác thực email - CinemaBooking";
            String body = buildEmailBody(fullname, code);
            
            boolean mailOk = EmailUtil.sendHtmlEmail(email, subject, body);

            if (mailOk) {
                req.setAttribute("successMessage", "Đăng ký thành công! Vui lòng kiểm tra email để lấy mã xác thực.");
            } else {
                req.setAttribute("successMessage", "Đăng ký thành công! (Không gửi được email xác thực - vui lòng liên hệ admin)");
            }

            req.getRequestDispatcher("/views/users/register.jsp").forward(req, resp);

        } catch (Exception ex) {
            ex.printStackTrace();
            req.setAttribute("error", "Lỗi server: " + ex.getMessage());
            req.getRequestDispatcher("/views/users/register.jsp").forward(req, resp);
        }
    }

    private String validateFields(String fullname, String username, String email, String phone, 
                                String password, String confirmPassword) {
        
        // Validate FullName
        if (fullname.length() < 2 || fullname.length() > 50) {
            return "Họ và tên phải từ 2 đến 50 ký tự";
        }

        // Validate Username (if provided)
        if (username != null && !username.isEmpty()) {
            if (username.length() < 4 || username.length() > 15) {
                return "Username phải từ 4 đến 15 ký tự";
            }
            if (!USERNAME_PATTERN.matcher(username).matches()) {
                return "Username chỉ được chứa chữ cái, số và dấu gạch dưới (_)";
            }
            if (username.contains(" ")) {
                return "Username không được chứa khoảng trắng";
            }
        }

        // Validate Email
        if (!EMAIL_PATTERN.matcher(email).matches()) {
            return "Email không đúng định dạng";
        }

        // Validate Phone (if provided)
        if (phone != null && !phone.isEmpty()) {
            if (!PHONE_PATTERN.matcher(phone).matches()) {
                return "Số điện thoại phải có 10 số và bắt đầu bằng số 0";
            }
        }

        // Validate Password
        if (password.length() < 8 || password.length() > 12) {
            return "Mật khẩu phải từ 8 đến 12 ký tự";
        }
        if (!PASSWORD_PATTERN.matcher(password).matches()) {
            return "Mật khẩu phải chứa ít nhất 1 chữ hoa, 1 chữ thường, 1 số và 1 ký tự đặc biệt";
        }

        // Validate Confirm Password
        if (!password.equals(confirmPassword)) {
            return "Mật khẩu xác nhận không khớp";
        }

        return null; // No errors
    }

    private String buildEmailBody(String fullname, String code) {
        return "<!DOCTYPE html>"
                + "<html>"
                + "<head>"
                + "<meta charset='UTF-8'>"
                + "<style>"
                + "body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }"
                + ".container { max-width: 600px; margin: 0 auto; padding: 20px; }"
                + ".header { background-color: #dc3545; color: white; padding: 20px; text-align: center; }"
                + ".content { background-color: #f9f9f9; padding: 30px; border-radius: 5px; }"
                + ".code { background-color: #fff; padding: 20px; border: 2px dashed #dc3545; margin: 20px 0; font-size: 32px; font-weight: bold; text-align: center; letter-spacing: 5px; color: #dc3545; }"
                + ".instruction { background-color: #fff3cd; padding: 15px; border-radius: 5px; border-left: 4px solid #ffc107; }"
                + ".footer { text-align: center; margin-top: 20px; color: #777; font-size: 12px; }"
                + "</style>"
                + "</head>"
                + "<body>"
                + "<div class='container'>"
                + "<div class='header'>"
                + "<h1>🎬 Cinema Booking System</h1>"
                + "</div>"
                + "<div class='content'>"
                + "<h2>Xin chào " + escape(fullname) + "!</h2>"
                + "<p>Cảm ơn bạn đã đăng ký tài khoản tại Cinema Booking System.</p>"
                + "<p>Để hoàn tất quá trình đăng ký, vui lòng sử dụng mã xác thực sau:</p>"
                + "<div class='code'>" + code + "</div>"
                + "<div class='instruction'>"
                + "<p><strong>Hướng dẫn sử dụng:</strong></p>"
                + "<ol>"
                + "<li>Sao chép mã xác thực 6 số ở trên</li>"
                + "<li>Quay lại trang web Cinema Booking</li>"
                + "<li>Nhập mã xác thực vào form xác nhận</li>"
                + "<li>Hoàn tất xác thực tài khoản</li>"
                + "</ol>"
                + "</div>"
                + "<p><strong>Lưu ý quan trọng:</strong></p>"
                + "<ul>"
                + "<li>Mã xác thực có hiệu lực trong 24 giờ</li>"
                + "<li>Không chia sẻ mã này với bất kỳ ai</li>"
                + "<li>Nếu bạn không yêu cầu đăng ký tài khoản, vui lòng bỏ qua email này</li>"
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