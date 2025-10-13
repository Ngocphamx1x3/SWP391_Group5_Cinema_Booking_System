/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.File;
import java.io.IOException;
import model.Users;
import model.UserProfile;

@WebServlet("/uploadAvatar")
@MultipartConfig
public class UploadAvatarController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Users user = (Users) session.getAttribute("account");

        if (user == null) {
            response.sendRedirect("login");
            return;
        }

        // Nhận file ảnh
        Part avatarFile = request.getPart("avatarFile");
        if (avatarFile != null && avatarFile.getSize() > 0) {
            String uploadPath = getServletContext().getRealPath("/uploads");
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            String fileName = System.currentTimeMillis() + "_" + avatarFile.getSubmittedFileName();
            avatarFile.write(uploadPath + File.separator + fileName);
            String avatarUrl = request.getContextPath() + "/uploads/" + fileName;

            // Cập nhật DB
            UserDAO dao = new UserDAO();
            UserProfile profile = dao.getUserProfileByUserId(user.getId());
            if (profile == null) {
                profile = new UserProfile();
                profile.setUserId(user.getId());
            }
            profile.setAvatarUrl(avatarUrl);
            dao.updateOrInsertUserProfile(profile);

            // Load lại trang profile
            request.setAttribute("profile", dao.getUserProfileByUserId(user.getId()));
            request.getRequestDispatcher("/views/users/userProfile.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Vui lòng chọn ảnh để tải lên.");
            request.getRequestDispatcher("/views/users/userProfile.jsp").forward(request, response);
        }
    }
}

