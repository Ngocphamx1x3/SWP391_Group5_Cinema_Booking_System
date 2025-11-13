package controller;

import dal.RoomDAO;
import dal.ScheduleDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import model.Schedule;
import model.Users;

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

        // --- START: Lấy dữ liệu dashboard ---
        ScheduleDAO scheduleDAO = new ScheduleDAO();
        int staffId = user.getId();

        // Số vé đã bán hôm nay
        int ticketsSoldToday = scheduleDAO.getTotalTicketsByStaff(staffId);

        // Doanh thu ca
        double revenueCurrentShift = scheduleDAO.getTotalRevenueByStaff(staffId);

        // Tạm tính % thay đổi (nếu bạn muốn hiển thị)
        double ticketsChangePercent = 15.0; // placeholder
        double revenueChangePercent = 8.3;  // placeholder

        RoomDAO roomDAO = new RoomDAO();
        int[] roomStats = roomDAO.getRoomUsageByStaff(staffId);
        int activeRooms = roomStats[0];
        int totalRooms = roomStats[1];

        int todaySchedules = scheduleDAO.getTodaySchedulesByStaff(staffId);

        request.setAttribute("staffUser", user);
        request.setAttribute("ticketsSoldToday", ticketsSoldToday);
        request.setAttribute("ticketsChangePercent", ticketsChangePercent);
        request.setAttribute("revenueCurrentShift", revenueCurrentShift);
        request.setAttribute("revenueChangePercent", revenueChangePercent);
        request.setAttribute("activeRooms", activeRooms);
        request.setAttribute("totalRooms", totalRooms);
        request.setAttribute("todaySchedules", todaySchedules);
        // --- END: Lấy dữ liệu dashboard ---
        request.getRequestDispatcher("/views/staff/dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
