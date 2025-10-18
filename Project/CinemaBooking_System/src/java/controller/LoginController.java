package controller;

import dal.UsersDAO;
import model.Users;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/login")
public class LoginController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("views/users/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String usernameOrEmail = request.getParameter("usernameOrEmail");
        String password = request.getParameter("password");

        // Check input format (email or username)
        if (usernameOrEmail == null || usernameOrEmail.trim().isEmpty()) {
            request.setAttribute("error", "Please enter email or username!");
            request.getRequestDispatcher("/views/users/login.jsp").forward(request, response);
            return;
        }

        // Check password empty
        if (password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Please enter your password!");
            request.getRequestDispatcher("/views/users/login.jsp").forward(request, response);
            return;
        }

        UsersDAO dao = new UsersDAO();
        Users user = dao.login(usernameOrEmail, password);

        if (user != null) {
            // Check if email is confirmed
            if (user.getEmailConfirmed() != 1) {
                request.setAttribute("error", "Please verify your email account before logging in!");
                request.getRequestDispatcher("/views/users/login.jsp").forward(request, response);
                return;
            }

            HttpSession session = request.getSession();
            session.setAttribute("account", user);
            
            // Redirect based on role
            String role = user.getRole();
            switch (role.toLowerCase()) {
                case "admin":
                    response.sendRedirect("admindashboard");
                    break;
                case "staff":
                    response.sendRedirect("staffdashboard");
                    break;
                default:
                    response.sendRedirect("home");
                    break;
            }
        } else {
            request.setAttribute("error", "Incorrect email/username or password!");
            request.getRequestDispatcher("/views/users/login.jsp").forward(request, response);
        }
    }
}