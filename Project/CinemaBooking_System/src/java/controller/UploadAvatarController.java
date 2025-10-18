package controller;

import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import model.Users;
import model.UserProfile;

@WebServlet("/uploadAvatar")
@MultipartConfig(
    maxFileSize = 1024 * 1024 * 5, // 5MB
    maxRequestSize = 1024 * 1024 * 10 // 10MB
)
public class UploadAvatarController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Users user = (Users) session.getAttribute("account");

        // Thiết lập response type
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        if (user == null) {
            sendErrorResponse(out, "Người dùng chưa đăng nhập");
            return;
        }

        try {
            Part avatarFile = request.getPart("avatarFile");
            if (avatarFile != null && avatarFile.getSize() > 0) {
                // Kiểm tra loại file
                String contentType = avatarFile.getContentType();
                if (!contentType.startsWith("image/")) {
                    sendErrorResponse(out, "Chỉ được phép tải lên file ảnh");
                    return;
                }

                // Tạo thư mục uploads nếu chưa tồn tại
                String uploadPath = getServletContext().getRealPath("/uploads");
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }

                // Tạo tên file duy nhất
                String fileName = "avatar_" + user.getId() + "_" + System.currentTimeMillis() + 
                                 getFileExtension(avatarFile.getSubmittedFileName());
                
                // Lưu file
                String filePath = uploadPath + File.separator + fileName;
                avatarFile.write(filePath);
                
                // Tạo URL cho avatar
                String avatarUrl = request.getContextPath() + "/uploads/" + fileName;

                // Cập nhật database
                UserDAO dao = new UserDAO();
                UserProfile profile = dao.getUserProfileByUserId(user.getId());
                
                if (profile == null) {
                    profile = new UserProfile();
                    profile.setUserId(user.getId());
                }
                profile.setAvatarUrl(avatarUrl);
                dao.updateOrInsertUserProfile(profile);

                // Gửi response JSON thành công
                sendSuccessResponse(out, "Ảnh đại diện đã được cập nhật", avatarUrl);
            } else {
                sendErrorResponse(out, "Vui lòng chọn ảnh để tải lên");
            }
        } catch (Exception e) {
            e.printStackTrace();
            sendErrorResponse(out, "Có lỗi xảy ra khi tải ảnh lên: " + e.getMessage());
        }
    }

    private String getFileExtension(String fileName) {
        if (fileName == null || fileName.lastIndexOf(".") == -1) {
            return ".jpg";
        }
        return fileName.substring(fileName.lastIndexOf("."));
    }

    private void sendSuccessResponse(PrintWriter out, String message, String avatarUrl) {
        out.print("{\"success\": true, \"message\": \"" + message + "\", \"avatarUrl\": \"" + avatarUrl + "\"}");
        out.flush();
    }

    private void sendErrorResponse(PrintWriter out, String message) {
        out.print("{\"success\": false, \"message\": \"" + message + "\"}");
        out.flush();
    }
}