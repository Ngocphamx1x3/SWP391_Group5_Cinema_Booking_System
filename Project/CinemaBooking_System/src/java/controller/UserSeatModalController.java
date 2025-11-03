package controller;

import dal.SeatDesignDAO;
import dal.ScheduleDAO;
import dal.OrderDAO;
import dal.TicketDAO;
import model.Seat;
import model.Schedule;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.*;

@WebServlet(name = "UserSeatModalController", urlPatterns = {"/user-seat-modal"})
public class UserSeatModalController extends HttpServlet {

    private SeatDesignDAO seatDesignDAO;
    private ScheduleDAO scheduleDAO;
    private OrderDAO orderDAO;
    private TicketDAO ticketDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        this.seatDesignDAO = new SeatDesignDAO();
        this.scheduleDAO   = new ScheduleDAO();
        this.orderDAO      = new OrderDAO();
        this.ticketDAO     = new TicketDAO();
        System.out.println("🎬 UserSeatModalController initialized");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        System.out.println("🔍 UserSeatModalController - Session check:");
        System.out.println("   Session exists: " + (session != null));
        if (session != null) {
            System.out.println("   Session ID: " + session.getId());
            System.out.println("   Account in session: " + (session.getAttribute("account") != null));
            if (session.getAttribute("account") != null) {
                model.Users user = (model.Users) session.getAttribute("account");
                System.out.println("   User ID: " + user.getId());
                System.out.println("   User Email: " + user.getEmail());
            }
        }
        System.out.println("   Cookies: " + java.util.Arrays.toString(req.getCookies()));
        
        if (session == null || session.getAttribute("account") == null) {
            System.out.println("❌ Session invalid - redirecting to login");
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String scheduleIdStr = req.getParameter("scheduleId");
        if (scheduleIdStr == null || scheduleIdStr.isBlank()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu scheduleId");
            return;
        }

        final int scheduleId;
        try { scheduleId = Integer.parseInt(scheduleIdStr); }
        catch (NumberFormatException e) { resp.sendError(400, "scheduleId không hợp lệ"); return; }

        try {
            // 1) Dọn đơn PENDING đã hết hạn để ghế HOLD quá hạn mở lại
            try {
                orderDAO.cancelExpiredPending();     // UPDATE Orders ... ExpiredAt < GETDATE() → CANCELLED
                ticketDAO.cleanupHoldOfCancelled();  // DELETE Ticket HOLD của đơn CANCELLED
            } catch (Exception ignore) { /* không chặn UI nếu job dọn rác lỗi */ }

            // 2) Lấy thông tin schedule
            Schedule schedule = getScheduleForUser(scheduleId, req);
            if (schedule == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy lịch chiếu");
                return;
            }

            // 3) Ghế của đúng room trong lịch này
            List<Seat> seats = seatDesignDAO.getSeatsByRoomId(schedule.getRoomId());

            // 4) GHẾ BẬN CHỈ THEO scheduleId ĐANG XEM
            //   (CONFIRMED) hoặc (HOLD + PENDING + chưa hết hạn)
            List<Integer> occupiedIds = seatDesignDAO.getOccupiedSeatIds(scheduleId);
            Set<Integer> occupiedSet  = new HashSet<>(occupiedIds);

            // 5) Đẩy ra view
            req.setAttribute("schedule",        schedule);
            req.setAttribute("seats",           seats);
            req.setAttribute("roomLayout",      seatDesignDAO.getRoomLayout(schedule.getRoomId()));
            req.setAttribute("basePrice",       schedule.getPrice());
            req.setAttribute("occupiedSeatIds", occupiedSet);

            req.getRequestDispatcher("/views/users/seatModalContent.jsp").forward(req, resp);

        } catch (Exception ex) {
            ex.printStackTrace();
            throw new ServletException("Lỗi khi tải modal chọn ghế", ex);
        }
    }

    /** Lấy schedule + metadata; chấp nhận cả ACTIVE và N'Đang hoạt động' */
    private Schedule getScheduleForUser(int scheduleId, HttpServletRequest request) {
        String sql =
            "SELECT s.*, m.Name AS movie_name, r.Name AS room_name, c.Name AS cinema_name, " +
            "       m.Image AS movie_image, m.MovieDuration, r.SeatRows, r.SeatColumns " +
            "FROM   Schedule s " +
            "JOIN   Movie   m ON s.MovieId = m.Id " +
            "JOIN   Room    r ON s.RoomId  = r.Id " +
            "JOIN   Cinema  c ON r.CinemaId= c.Id " +
            "WHERE  s.Id = ? AND s.Status IN ('ACTIVE', N'Đang hoạt động')";

        try (java.sql.Connection conn = new util.DBContext().getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, scheduleId);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;

                Schedule s = new Schedule();
                s.setId(rs.getInt("Id"));
                s.setCode(rs.getString("Code"));
                s.setName(rs.getString("Name"));
                java.sql.Timestamp st = rs.getTimestamp("StartAt");
                java.sql.Timestamp ft = rs.getTimestamp("FinishAt");
                if (st != null) s.setStartAt(new java.util.Date(st.getTime()));
                if (ft != null) s.setFinishAt(new java.util.Date(ft.getTime()));
                s.setPrice(rs.getDouble("Price"));
                s.setStatus(rs.getString("Status"));
                s.setMovieId(rs.getInt("MovieId"));
                s.setRoomId(rs.getInt("RoomId"));
                s.setStaffId(rs.getInt("Staff_id"));
                s.setMovieName(rs.getString("movie_name"));
                s.setRoomName(rs.getString("room_name"));
                s.setCinemaName(rs.getString("cinema_name"));

                // push size & image to request for JSP
                request.setAttribute("roomRows",     rs.getInt("SeatRows"));
                request.setAttribute("roomColumns",  rs.getInt("SeatColumns"));
                request.setAttribute("movieImage",   rs.getString("movie_image"));
                request.setAttribute("movieDuration",rs.getInt("MovieDuration"));

                return s;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        doGet(req, resp);
    }
}
