/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
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
            response.sendRedirect("login");
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
            response.sendRedirect("login");
            return;
        }

        String oldPassword = request.getParameter("oldPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (oldPassword == null || newPassword == null || confirmPassword == null
                || oldPassword.isEmpty() || newPassword.isEmpty() || confirmPassword.isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập đầy đủ thông tin.");
            request.getRequestDispatcher("/views/users/changePassword.jsp").forward(request, response);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "Xác nhận mật khẩu không khớp.");
            request.getRequestDispatcher("/views/users/changePassword.jsp").forward(request, response);
            return;
        }

        String pattern = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^a-zA-Z0-9]).{8,}$";
        if (!newPassword.matches(pattern)) {
            request.setAttribute("error", "Mật khẩu phải có ít nhất 1 chữ hoa, 1 chữ thường, 1 số và 1 ký tự đặc biệt (tối thiểu 8 ký tự).");
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

        // Nếu mật khẩu trong DB đã mã hóa thì cần so sánh đúng cách ở đây
        if (!dbUser.getPassword().equals(oldPassword)) {
            request.setAttribute("error", "Mật khẩu cũ không đúng.");
            request.getRequestDispatcher("/views/users/changePassword.jsp").forward(request, response);
            return;
        }

        boolean updated = dao.updatePassword(user.getId(), newPassword);
        if (!updated) {
            request.setAttribute("error", "Không thể cập nhật mật khẩu. Vui lòng thử lại.");
        } else {
            user.setPassword(newPassword);
            session.setAttribute("account", user);
            request.setAttribute("message", "Đổi mật khẩu thành công!");
        }

        request.getRequestDispatcher("/views/users/changePassword.jsp").forward(request, response);
    }
}
