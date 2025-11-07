package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Users;
import dal.BookingManagerDAO;
import model.Booking;

@WebServlet(name = "BookingDetailsController", urlPatterns = {"/staff/booking-details"})
public class BookingDetailsController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Users user = (Users) session.getAttribute("account");
        
        if (user == null || (!"staff".equalsIgnoreCase(user.getRole()) && !"admin".equalsIgnoreCase(user.getRole()))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String ticketCode = request.getParameter("ticketCode");
        
        System.out.println("BookingDetailsController - ticketCode: " + ticketCode); // Debug
        
        if (ticketCode != null && !ticketCode.trim().isEmpty()) {
            BookingManagerDAO bookingDAO = new BookingManagerDAO();
            
            // Lấy chi tiết booking
            Booking booking = getBookingDetails(ticketCode, user.getId());
            
            if (booking != null) {
                request.setAttribute("booking", booking);
                request.getRequestDispatcher("/views/staff/bookingDetails.jsp").forward(request, response);
            } else {
                // Hiển thị trang lỗi thân thiện hơn
                request.setAttribute("errorMessage", "Không tìm thấy thông tin vé: " + ticketCode);
                request.getRequestDispatcher("/views/staff/bookingNotFound.jsp").forward(request, response);
            }
        } else {
            request.setAttribute("errorMessage", "Mã vé không được để trống");
            request.getRequestDispatcher("/views/staff/bookingNotFound.jsp").forward(request, response);
        }
    }
    
    private Booking getBookingDetails(String ticketCode, int staffId) {
        BookingManagerDAO bookingDAO = new BookingManagerDAO();
        return bookingDAO.getBookingByTicketCode(ticketCode, staffId);
    }
}