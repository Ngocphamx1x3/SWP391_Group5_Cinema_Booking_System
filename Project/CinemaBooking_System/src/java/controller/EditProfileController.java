/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
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
@MultipartConfig
public class EditProfileController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Users user = (Users) session.getAttribute("account");

        if (user == null) {
            response.sendRedirect("login");
            return;
        }

        // Lấy dữ liệu từ form
        String username = request.getParameter("username");
        String phone = request.getParameter("phone");
        String fullName = request.getParameter("fullName");
        String gender = request.getParameter("gender");
        String birthdayStr = request.getParameter("birthday");
        String address = request.getParameter("address");

        // Cập nhật Users
        user.setUsername(username);
        user.setPhoneNumber(phone);

        // Parse ngày sinh
        Date birthday = null;
        if (birthdayStr != null && !birthdayStr.isEmpty()) {
            birthday = Date.valueOf(birthdayStr);
        }

        //Xử lý avatar
        Part avatarFile = request.getPart("avatarFile");
        String avatarUrl = null;
        if (avatarFile != null && avatarFile.getSize() > 0) {
            String uploadPath = getServletContext().getRealPath("/uploads");
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            String fileName = System.currentTimeMillis() + "_" + avatarFile.getSubmittedFileName();
            avatarFile.write(uploadPath + File.separator + fileName);
            avatarUrl = request.getContextPath() + "/uploads/" + fileName;
        } else {
            // Giữ nguyên avatar cũ nếu không có file mới
            UserDAO dao = new UserDAO();
            UserProfile existingProfile = dao.getUserProfileByUserId(user.getId());
            if (existingProfile != null) {
                avatarUrl = existingProfile.getAvatarUrl();
            }
        }

        // Tạo UserProfile
        UserProfile profile = new UserProfile();
        profile.setUserId(user.getId());
        profile.setFullName(fullName);
        profile.setGender(gender);
        profile.setBirthday(birthday);
        profile.setAddress(address);
        if (avatarUrl != null) {
            profile.setAvatarUrl(avatarUrl);
        }

        // Gọi DAO
        UserDAO dao = new UserDAO();
        dao.updateUser(user);
        dao.updateOrInsertUserProfile(profile);

        // Cập nhật session
        session.setAttribute("account", user);

        // Load lại profile và forward
        request.setAttribute("message", "Cập nhật hồ sơ thành công!");
        request.setAttribute("profile", dao.getUserProfileByUserId(user.getId()));
       response.sendRedirect("userProfile?success=true");

    }

}
