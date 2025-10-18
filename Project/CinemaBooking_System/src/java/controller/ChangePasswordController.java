package controller;

import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import model.Users;

@WebServlet("/changePassword")
public class ChangePasswordController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Users user = (Users) session.getAttribute("account");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        request.getRequestDispatcher("/views/users/changePassword.jsp").forward(request, response);
    }

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
            String oldPassword = request.getParameter("oldPassword");
            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");

            // Kiểm tra dữ liệu đầu vào
            if (oldPassword == null || newPassword == null || confirmPassword == null
                    || oldPassword.trim().isEmpty() || newPassword.trim().isEmpty() || confirmPassword.trim().isEmpty()) {
                request.setAttribute("error", "Vui lòng nhập đầy đủ thông tin.");
                request.getRequestDispatcher("/views/users/changePassword.jsp").forward(request, response);
                return;
            }

            if (!newPassword.equals(confirmPassword)) {
                request.setAttribute("error", "Xác nhận mật khẩu không khớp.");
                request.getRequestDispatcher("/views/users/changePassword.jsp").forward(request, response);
                return;
            }

            // Validate mật khẩu mới
            String pattern = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$";
            if (!newPassword.matches(pattern)) {
                request.setAttribute("error", "Mật khẩu phải có ít nhất 8 ký tự, bao gồm 1 chữ hoa, 1 chữ thường, 1 số và 1 ký tự đặc biệt.");
                request.getRequestDispatcher("/views/users/changePassword.jsp").forward(request, response);
                return;
            }

            UserDAO dao = new UserDAO();
            Users dbUser = dao.getUserById(user.getId());

            if (dbUser == null) {
                request.setAttribute("error", "Không tìm thấy người dùng trong hệ thống.");
                request.getRequestDispatcher("/views/users/changePassword.jsp").forward(request, response);
                return;
            }

            // Kiểm tra mật khẩu cũ (giả sử mật khẩu chưa mã hóa)
            if (!dbUser.getPassword().equals(oldPassword)) {
                request.setAttribute("error", "Mật khẩu cũ không đúng.");
                request.getRequestDispatcher("/views/users/changePassword.jsp").forward(request, response);
                return;
            }

            // Cập nhật mật khẩu mới
            boolean updated = dao.updatePassword(user.getId(), newPassword);
            if (updated) {
                // Cập nhật session
                user.setPassword(newPassword);
                session.setAttribute("account", user);
                request.setAttribute("message", "Đổi mật khẩu thành công!");
            } else {
                request.setAttribute("error", "Không thể cập nhật mật khẩu. Vui lòng thử lại.");
            }

            request.getRequestDispatcher("/views/users/changePassword.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            request.getRequestDispatcher("/views/users/changePassword.jsp").forward(request, response);
        }
    }
}