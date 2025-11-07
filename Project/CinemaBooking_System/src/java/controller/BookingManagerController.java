/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

/**
 *
 * @author admin
 */
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Users;
import dal.BookingManagerDAO;
import model.Booking;

@WebServlet(name = "BookingManagerController", urlPatterns = {"/staff/bookings"})
public class BookingManagerController extends HttpServlet {

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
        
        // Lấy các tham số tìm kiếm và filter
        String search = request.getParameter("search");
        String statusFilter = request.getParameter("status");
        String dateFilter = request.getParameter("date");
        
        // Phân trang
        int page = 1;
        int pageSize = 10;
        
        try {
            page = Integer.parseInt(request.getParameter("page"));
        } catch (NumberFormatException e) {
            page = 1;
        }
        
        try {
            pageSize = Integer.parseInt(request.getParameter("pageSize"));
        } catch (NumberFormatException e) {
            pageSize = 10;
        }
        
        BookingManagerDAO bookingDAO = new BookingManagerDAO();
        
        // Lấy tổng số records
        int totalRecords = bookingDAO.getTotalBookings(user.getId(), search, statusFilter, dateFilter);
        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
        
        // Lấy danh sách bookings
        List<Booking> bookings = bookingDAO.getAllBookingsByStaff(
            user.getId(), search, statusFilter, dateFilter, page, pageSize
        );
        
        request.setAttribute("bookings", bookings);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("search", search);
        request.setAttribute("statusFilter", statusFilter);
        request.setAttribute("dateFilter", dateFilter);
        request.setAttribute("staffUser", user);
        
        request.getRequestDispatcher("/views/staff/bookingManager.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
