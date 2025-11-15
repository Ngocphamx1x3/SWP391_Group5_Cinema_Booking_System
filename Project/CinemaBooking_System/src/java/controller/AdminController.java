package controller;

import dal.ScheduleDAO;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.LinkedHashMap;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import model.Schedule;
import model.Users;
import util.DBContext;

@WebServlet(name = "AdminController", urlPatterns = {"/admindashboard"})
public class AdminController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Users user = (Users) session.getAttribute("account");

        // Kiểm tra đăng nhập và quyền admin
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (!"admin".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        if (user.getEmailConfirmed() != 1) {
            session.setAttribute("error", "Please verify your email to access admin dashboard");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        request.setAttribute("adminUser", user);

        // ✅ --- Phần thống kê ---
        int totalMovies = 0;
        int activeMovies = 0;
        int totalTickets = 0;
        int totalUsers = 0;
        double totalRevenue = 0;
        int totalCinemas = 0;
        int activeCinemas = 0;

        // ✅ Doanh thu theo tháng
        Map<String, Double> revenueByMonth = new LinkedHashMap<>();

        try (Connection conn = new DBContext().getConnection()) {

            // Tổng số phim
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) AS total FROM Movie"); ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalMovies = rs.getInt("total");
                }
            }

            // Phim đang chiếu
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) AS active FROM Movie WHERE Status = N'Đang chiếu'"); ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    activeMovies = rs.getInt("active");
                }
            }

            // Tổng vé đã bán
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) AS total FROM Ticket"); ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalTickets = rs.getInt("total");
                }
            }

            // Tổng người dùng
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) AS total FROM Users"); ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalUsers = rs.getInt("total");
                }
            }

            // Tổng doanh thu (toàn bộ)
            try (PreparedStatement ps = conn.prepareStatement("SELECT SUM(Price) AS total FROM Ticket"); ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalRevenue = rs.getDouble("total");
                }
            }

            // Tổng rạp
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) AS total FROM Cinema"); ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalCinemas = rs.getInt("total");
                }
            }

            // Rạp đang hoạt động
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) AS active FROM Cinema WHERE Status = 1"); ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    activeCinemas = rs.getInt("active");
                }
            }

            // --- Lấy tất cả lịch chiếu để hiển thị bảng ---
            try {
                ScheduleDAO scheduleDAO = new ScheduleDAO();
                List<Schedule> recentSchedules = scheduleDAO.getRecentSchedules(5);
                request.setAttribute("recentSchedules", recentSchedules);
            } catch (Exception e) {
            }

// ✅ Doanh thu theo tháng (bảng Ticket)
            String sqlRevenueByMonth = """
    SELECT 
            FORMAT(OrderDate, 'yyyy-MM') AS Month,
            SUM(TotalMoney) AS TotalRevenue
        FROM [CinemaBooking_System].[dbo].[Orders]
        WHERE LTRIM(RTRIM(Status)) = 'PAID'
        GROUP BY FORMAT(OrderDate, 'yyyy-MM')
        ORDER BY Month;
""";

            try (PreparedStatement ps = conn.prepareStatement(sqlRevenueByMonth); ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    revenueByMonth.put(rs.getString("Month"), rs.getDouble("TotalRevenue"));
                }
                System.out.println("📊 Revenue by month loaded: " + revenueByMonth);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        // ✅ Gửi dữ liệu sang JSP
        request.setAttribute("totalMovies", totalMovies);
        request.setAttribute("activeMovies", activeMovies);
        request.setAttribute("totalTickets", totalTickets);
        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("totalRevenue", totalRevenue);
        request.setAttribute("totalCinemas", totalCinemas);
        request.setAttribute("activeCinemas", activeCinemas);
        request.setAttribute("revenueByMonth", revenueByMonth);

        // Forward sang dashboard.jsp
        request.getRequestDispatcher("/views/admin/dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
