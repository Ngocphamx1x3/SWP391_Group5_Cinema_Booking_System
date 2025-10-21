package controller;

import dal.UserDAO;
import model.UserProfile;
import model.Users;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.sql.Date;
import java.util.regex.Pattern;

@WebServlet("/editProfile")
@MultipartConfig(
    maxFileSize = 1024 * 1024 * 5, // 5MB
    maxRequestSize = 1024 * 1024 * 10 // 10MB
)
public class EditProfileController extends HttpServlet {

    // Regex patterns
    private static final Pattern USERNAME_PATTERN = Pattern.compile("^[a-zA-Z0-9_]{4,15}$");
    private static final Pattern PHONE_PATTERN = Pattern.compile("^$|^0[0-9]{9}$"); // Cho phép chuỗi rỗng hoặc số điện thoại hợp lệ
    private static final Pattern FULLNAME_PATTERN = Pattern.compile("^[\\p{L} ]{2,50}$");

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Users user = (Users) session.getAttribute("account");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            // Lấy dữ liệu từ form
            String username = request.getParameter("username");
            String phone = request.getParameter("phone");
            String fullName = request.getParameter("fullName");
            String gender = request.getParameter("gender");
            String birthdayStr = request.getParameter("birthday");
            String address = request.getParameter("address");

            // Validate dữ liệu
            StringBuilder errorMessage = new StringBuilder();
            
            // Validate username
            if (username == null || username.trim().isEmpty()) {
                errorMessage.append("Username không được để trống.\\n");
            } else if (!USERNAME_PATTERN.matcher(username).matches()) {
                errorMessage.append("Username phải từ 4-15 ký tự, chỉ chứa chữ cái, số và dấu gạch dưới (_), không chứa khoảng trắng.\\n");
            } else {
                // Kiểm tra username trùng (trừ chính user hiện tại)
                UserDAO dao = new UserDAO();
                Users existingUser = dao.getUserByUsername(username);
                if (existingUser != null && existingUser.getId() != user.getId()) {
                    errorMessage.append("Username đã tồn tại. Vui lòng chọn username khác.\\n");
                }
            }

            // Validate phone - cho phép để trống
            if (phone != null && !phone.trim().isEmpty()) {
                if (!PHONE_PATTERN.matcher(phone).matches()) {
                    errorMessage.append("Số điện thoại phải có 10 số và bắt đầu bằng số 0, hoặc để trống.\\n");
                } else {
                    // Kiểm tra phone trùng (trừ chính user hiện tại) - chỉ kiểm tra nếu có số điện thoại
                    UserDAO dao = new UserDAO();
                    Users existingUser = dao.getUserByPhone(phone);
                    if (existingUser != null && existingUser.getId() != user.getId()) {
                        errorMessage.append("Số điện thoại đã tồn tại. Vui lòng sử dụng số điện thoại khác.\\n");
                    }
                }
            }

            // Validate fullName
            if (fullName != null && !fullName.trim().isEmpty()) {
                if (!FULLNAME_PATTERN.matcher(fullName.trim()).matches()) {
                    errorMessage.append("Họ và tên phải từ 2-50 ký tự.\\n");
                }
            }

            // Nếu có lỗi validation, quay lại trang với thông báo lỗi
            if (errorMessage.length() > 0) {
                session.setAttribute("errorMessage", errorMessage.toString());
                response.sendRedirect(request.getContextPath() + "/userProfile");
                return;
            }

            // Cập nhật thông tin Users
            user.setUsername(username);
            
            // Xử lý số điện thoại: nếu là chuỗi rỗng thì set thành null
            if (phone != null && phone.trim().isEmpty()) {
                user.setPhoneNumber(null);
            } else {
                user.setPhoneNumber(phone);
            }

            // Parse ngày sinh
            Date birthday = null;
            if (birthdayStr != null && !birthdayStr.isEmpty()) {
                try {
                    birthday = Date.valueOf(birthdayStr);
                } catch (IllegalArgumentException e) {
                    // Xử lý lỗi định dạng ngày
                }
            }

            // Xử lý avatar upload (nếu có)
            String avatarUrl = null;
            Part avatarFile = request.getPart("avatarFile");
            
            if (avatarFile != null && avatarFile.getSize() > 0) {
                String uploadPath = getServletContext().getRealPath("/uploads");
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }

                String fileName = "avatar_" + user.getId() + "_" + System.currentTimeMillis() + 
                                 getFileExtension(avatarFile.getSubmittedFileName());
                avatarFile.write(uploadPath + File.separator + fileName);
                avatarUrl = request.getContextPath() + "/uploads/" + fileName;
            }

            // Lấy thông tin profile hiện tại
            UserDAO dao = new UserDAO();
            UserProfile existingProfile = dao.getUserProfileByUserId(user.getId());
            
            // Tạo hoặc cập nhật UserProfile
            UserProfile profile;
            if (existingProfile != null) {
                profile = existingProfile;
            } else {
                profile = new UserProfile();
                profile.setUserId(user.getId());
            }
            
            profile.setFullName(fullName);
            profile.setGender(gender);
            profile.setBirthday(birthday);
            profile.setAddress(address);
            
            // Chỉ cập nhật avatar nếu có file mới
            if (avatarUrl != null) {
                profile.setAvatarUrl(avatarUrl);
                session.setAttribute("avatarUrl", avatarUrl);
            }

            // Cập nhật database
            dao.updateUser(user);
            dao.updateOrInsertUserProfile(profile);

            // Cập nhật session
            session.setAttribute("account", user);

            // Chuyển hướng về trang profile với thông báo thành công
            session.setAttribute("successMessage", "Cập nhật hồ sơ thành công!");
            response.sendRedirect(request.getContextPath() + "/userProfile");

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi xảy ra khi cập nhật hồ sơ: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/userProfile");
        }
    }

    private String getFileExtension(String fileName) {
        if (fileName == null || fileName.lastIndexOf(".") == -1) {
            return "";
        }
        return fileName.substring(fileName.lastIndexOf("."));
    }
}