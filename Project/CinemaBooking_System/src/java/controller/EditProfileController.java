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

@WebServlet("/editProfile")
@MultipartConfig(
    maxFileSize = 1024 * 1024 * 5, // 5MB
    maxRequestSize = 1024 * 1024 * 10 // 10MB
)
public class EditProfileController extends HttpServlet {

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

            // Cập nhật thông tin Users
            user.setUsername(username);
            user.setPhoneNumber(phone);

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
                avatarUrl = "/uploads/" + fileName;
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
            }

            // Cập nhật database
            dao.updateUser(user);
            dao.updateOrInsertUserProfile(profile);

            // Cập nhật session
            session.setAttribute("account", user);

            // Chuyển hướng về trang profile với thông báo thành công
            response.sendRedirect(request.getContextPath() + "/userProfile?success=true");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/userProfile?error=Có lỗi xảy ra khi cập nhật hồ sơ");
        }
    }

    private String getFileExtension(String fileName) {
        if (fileName == null || fileName.lastIndexOf(".") == -1) {
            return "";
        }
        return fileName.substring(fileName.lastIndexOf("."));
    }
}