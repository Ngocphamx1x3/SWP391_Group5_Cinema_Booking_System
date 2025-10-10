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

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        // Check email format
        if (email == null || !email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$")) {
            request.setAttribute("error", "Invalid email format!");
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
        Users user = dao.login(email, password);

        if (user != null) {
            HttpSession session = request.getSession();
            session.setAttribute("account", user);
            response.sendRedirect("home");
        } else {
            request.setAttribute("error", "Incorrect or account password not found, try again");
            request.getRequestDispatcher("/views/users/login.jsp").forward(request, response);
        }
    }
}
