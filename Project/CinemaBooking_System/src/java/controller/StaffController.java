package controller;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Users;
import dal.RecentBookingDAO;
import model.RecentBooking;

@WebServlet(name = "StaffController", urlPatterns = {"/staffdashboard"}) 
public class StaffController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Users user = (Users) session.getAttribute("account");
        
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        if (!"staff".equalsIgnoreCase(user.getRole()) && !"admin".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }
        
        if (user.getEmailConfirmed() != 1) {
            session.setAttribute("error", "Please verify your email to access staff dashboard");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        // Lấy recent bookings từ database
        RecentBookingDAO recentBookingDAO = new RecentBookingDAO();
        List<RecentBooking> recentBookings = recentBookingDAO.getRecentBookingsByStaffCinema(user.getId(), 5);
        
        request.setAttribute("staffUser", user);
        request.setAttribute("recentBookings", recentBookings);
        request.getRequestDispatcher("/views/staff/dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}