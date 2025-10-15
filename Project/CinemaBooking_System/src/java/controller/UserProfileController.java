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
import model.UserProfile;
import model.Users;

@WebServlet("/userProfile")
public class UserProfileController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Users user = (Users) session.getAttribute("account");

        if (user == null) {
            response.sendRedirect("login");
            return;
        }

        UserDAO dao = new UserDAO();
        UserProfile profile = dao.getUserProfileByUserId(user.getId());

        request.setAttribute("profile", profile);

        String success = request.getParameter("success");
        if ("true".equals(success)) {
            request.setAttribute("message", "Cập nhật hồ sơ thành công!");
        }

        request.getRequestDispatcher("/views/users/userProfile.jsp").forward(request, response);
    }
}
