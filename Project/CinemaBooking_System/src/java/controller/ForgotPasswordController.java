package controller;

import dal.UsersDAO;
import model.Users;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Random;

@WebServlet("/forgot_password")
public class ForgotPasswordController extends HttpServlet {

    // Utility method to generate a random 6-digit code
    private String generateResetCode() {
        Random rand = new Random();
        int code = 100000 + rand.nextInt(900000);
        return String.valueOf(code);
    }

    // Placeholder for sending email (implement with your mail service)
    private void sendResetEmail(String toEmail, String code) {
        // TODO: Integrate with your email service provider
        // For now, this is just a placeholder.
        System.out.println("Sending reset code " + code + " to email: " + toEmail);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("views/users/forgot_password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        UsersDAO dao = new UsersDAO();
        Users user = dao.findByEmailOrUsername(email);

        if (user == null) {
            request.setAttribute("message", "Email not found in the system!");
            request.getRequestDispatcher("views/users/forgot_password.jsp").forward(request, response);
        } else {
            // Generate a reset code
            String resetCode = generateResetCode();

            // Save the reset code in session (or DB if you want persistence)
            HttpSession session = request.getSession();
            session.setAttribute("resetEmail", email);
            session.setAttribute("resetCode", resetCode);

            // Send the reset code to user's email
            sendResetEmail(email, resetCode);

            // Notify user to check their email for the code
            request.setAttribute("message", "A reset code has been sent to your email. Please check your inbox.");
            request.getRequestDispatcher("views/users/reset_code.jsp").forward(request, response);
        }
    }
}
