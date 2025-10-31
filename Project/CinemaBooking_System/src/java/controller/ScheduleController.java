package controller;

import dal.ScheduleDAO;
import dal.CinemaStaffDAO;
import model.Schedule;
import model.CinemaStaff;
import model.Users;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

@WebServlet(name = "ScheduleController", urlPatterns = {"/staff/schedules"})
public class ScheduleController extends HttpServlet {

    private ScheduleDAO scheduleDAO;
    private CinemaStaffDAO cinemaStaffDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        this.scheduleDAO = new ScheduleDAO();
        this.cinemaStaffDAO = new CinemaStaffDAO();
    }

    // ===== HANDLE GET REQUESTS =====
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        HttpSession session = request.getSession();
        Users user = (Users) session.getAttribute("account");

        if (user == null || !"staff".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            switch (action) {
                case "list":
                    showScheduleList(request, response, user);
                    break;
                case "add":
                    showAddForm(request, response, user);
                    break;
                case "edit":
                    showEditForm(request, response, user);
                    break;
                case "delete":
                    deleteSchedule(request, response, user);
                    break;
                default:
                    showScheduleList(request, response, user);
                    break;
            }
        } catch (Exception e) {
            throw new ServletException("Lỗi xử lý request: " + e.getMessage(), e);
        }
    }

    // ===== HANDLE POST REQUESTS =====
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        Users user = (Users) session.getAttribute("account");

        if (user == null || !"staff".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            switch (action) {
                case "create":
                    createSchedule(request, response, user);
                    break;
                case "update":
                    updateSchedule(request, response, user);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Action không hợp lệ");
            }
        } catch (Exception e) {
            throw new ServletException("Lỗi xử lý request: " + e.getMessage(), e);
        }
    }

    // ===== PRIVATE METHODS =====
    // SHOW SCHEDULE LIST
    private void showScheduleList(HttpServletRequest request, HttpServletResponse response, Users user)
            throws ServletException, IOException {

        // Lấy parameters phân trang
        int page = 1;
        int pageSize = 10; // Số item mỗi trang

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

        // Lấy tổng số records
        int totalRecords = scheduleDAO.getTotalSchedulesByStaff(user.getId());
        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);

        // Đảm bảo page hợp lệ
        if (page < 1) {
            page = 1;
        }
        if (page > totalPages && totalPages > 0) {
            page = totalPages;
        }

        // Lấy dữ liệu theo trang
        List<Schedule> schedules = scheduleDAO.getSchedulesByStaffWithPaging(user.getId(), page, pageSize);

        // Set attributes cho JSP
        request.setAttribute("schedules", schedules);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/views/staff/scheduleList.jsp");
        dispatcher.forward(request, response);
    }

    // SHOW ADD FORM
    private void showAddForm(HttpServletRequest request, HttpServletResponse response, Users user)
            throws ServletException, IOException {

        // Chỉ lấy phim đang chiếu
        List<model.Movie> activeMovies = scheduleDAO.getActiveMoviesForScheduling();
        // Chỉ lấy phòng thuộc rạp mà staff quản lý
        List<model.Room> staffRooms = scheduleDAO.getRoomsByStaff(user.getId());

        request.setAttribute("activeMovies", activeMovies);
        request.setAttribute("staffRooms", staffRooms);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/views/staff/scheduleForm.jsp");
        dispatcher.forward(request, response);
    }

    // SHOW EDIT FORM
    private void showEditForm(HttpServletRequest request, HttpServletResponse response, Users user)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu ID lịch chiếu");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            Schedule schedule = scheduleDAO.getScheduleById(id, user.getId());

            if (schedule == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy lịch chiếu");
                return;
            }

            // Kiểm tra xem có thể chỉnh sửa không
            if (!schedule.canBeEdited()) {
                request.setAttribute("error", "Lịch chiếu này không thể chỉnh sửa (đã quá gần giờ chiếu hoặc đã kết thúc)");
                showScheduleList(request, response, user);
                return;
            }

            List<model.Movie> activeMovies = scheduleDAO.getActiveMoviesForScheduling();
            List<model.Room> staffRooms = scheduleDAO.getRoomsByStaff(user.getId());

            request.setAttribute("schedule", schedule);
            request.setAttribute("activeMovies", activeMovies);
            request.setAttribute("staffRooms", staffRooms);

            RequestDispatcher dispatcher = request.getRequestDispatcher("/views/staff/scheduleForm.jsp");
            dispatcher.forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID không hợp lệ");
        }
    }

    // CREATE SCHEDULE
    // CREATE SCHEDULE - THÊM DEBUG CHI TIẾT
    private void createSchedule(HttpServletRequest request, HttpServletResponse response, Users user)
            throws ServletException, IOException {

        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");

            String name = request.getParameter("name");
            String startAtStr = request.getParameter("startAt");
            String movieIdStr = request.getParameter("movieId");
            String roomIdStr = request.getParameter("roomId");
            String priceStr = request.getParameter("price");

            System.out.println("=== DEBUG CREATE SCHEDULE ===");
            System.out.println("Raw parameters:");
            System.out.println("name: " + name);
            System.out.println("startAt: " + startAtStr);
            System.out.println("movieId: " + movieIdStr);
            System.out.println("roomId: " + roomIdStr);
            System.out.println("price: " + priceStr);
            System.out.println("staffId: " + user.getId());

            // VALIDATION CƠ BẢN
            if (name == null || name.trim().isEmpty()) {
                System.out.println("ERROR: Name is empty");
                request.setAttribute("error", "Tên lịch chiếu không được để trống");
                showAddForm(request, response, user);
                return;
            }

            if (startAtStr == null || startAtStr.trim().isEmpty()) {
                System.out.println("ERROR: StartAt is empty");
                request.setAttribute("error", "Thời gian bắt đầu không được để trống");
                showAddForm(request, response, user);
                return;
            }

            // PARSE THỜI GIAN
            Date startAt = sdf.parse(startAtStr);
            System.out.println("Parsed StartAt: " + startAt);

            // PARSE CÁC THAM SỐ SỐ
            int movieId, roomId;
            double price;

            try {
                movieId = Integer.parseInt(movieIdStr);
                roomId = Integer.parseInt(roomIdStr);
                price = Double.parseDouble(priceStr);
                System.out.println("Parsed numbers - movieId: " + movieId + ", roomId: " + roomId + ", price: " + price);
            } catch (NumberFormatException e) {
                System.out.println("ERROR: Number format exception: " + e.getMessage());
                request.setAttribute("error", "Dữ liệu số không hợp lệ");
                showAddForm(request, response, user);
                return;
            }

            // TÍNH THỜI GIAN KẾT THÚC
            int movieDuration = scheduleDAO.getMovieDuration(movieId);
            System.out.println("Movie Duration from DB: " + movieDuration);

            if (movieDuration <= 0) {
                System.out.println("ERROR: Movie duration is 0 or negative");
                request.setAttribute("error", "Không thể lấy thời lượng phim");
                showAddForm(request, response, user);
                return;
            }

            // Tính finishAt = startAt + movieDuration (phút)
            long finishAtMillis = startAt.getTime() + (movieDuration * 60 * 1000);
            Date finishAt = new Date(finishAtMillis);
            System.out.println("Calculated FinishAt: " + finishAt);

            // VALIDATION THỜI GIAN
            Schedule tempSchedule = new Schedule();
            tempSchedule.setStartAt(startAt);
            tempSchedule.setFinishAt(finishAt);

            if (!tempSchedule.isValidStartTime()) {
                System.out.println("ERROR: Invalid start time");
                request.setAttribute("error", "Thời gian bắt đầu phải sau thời điểm hiện tại ít nhất 30 phút");
                showAddForm(request, response, user);
                return;
            }

            // KIỂM TRA TRÙNG LỊCH
            System.out.println("Checking schedule conflict for room: " + roomId);
            boolean hasConflict = scheduleDAO.isScheduleConflict(roomId, startAt, finishAt, 0);
            System.out.println("Has conflict: " + hasConflict);

            if (hasConflict) {
                request.setAttribute("error", "Lịch chiếu bị trùng với lịch khác trong phòng này");
                showAddForm(request, response, user);
                return;
            }

            // TẠO SCHEDULE OBJECT
            Schedule schedule = new Schedule();
            schedule.setName(name.trim());
            schedule.setStartAt(startAt);
            schedule.setFinishAt(finishAt);
            schedule.setMovieId(movieId);
            schedule.setRoomId(roomId);
            schedule.setPrice(price);
            schedule.setStaffId(user.getId());

            System.out.println("Final schedule object created:");
            System.out.println("Name: " + schedule.getName());
            System.out.println("StartAt: " + schedule.getStartAt());
            System.out.println("FinishAt: " + schedule.getFinishAt());
            System.out.println("MovieId: " + schedule.getMovieId());
            System.out.println("RoomId: " + schedule.getRoomId());
            System.out.println("Price: " + schedule.getPrice());
            System.out.println("StaffId: " + schedule.getStaffId());

            // THÊM VÀO DATABASE
            System.out.println("Calling scheduleDAO.addSchedule()...");
            boolean success = scheduleDAO.addSchedule(schedule);
            System.out.println("Add schedule result: " + success);

            if (success) {
                System.out.println("SUCCESS: Schedule created successfully");
                response.sendRedirect(request.getContextPath() + "/staff/schedules?success=create");
            } else {
                System.out.println("ERROR: Failed to add schedule to database");
                request.setAttribute("error", "Lỗi khi tạo lịch chiếu");
                showAddForm(request, response, user);
            }

        } catch (java.text.ParseException e) {
            System.out.println("ERROR: ParseException: " + e.getMessage());
            request.setAttribute("error", "Định dạng thời gian không hợp lệ");
            showAddForm(request, response, user);
        } catch (Exception e) {
            System.out.println("ERROR: Exception: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            showAddForm(request, response, user);
        }
    }

    // UPDATE SCHEDULE
    private void updateSchedule(HttpServletRequest request, HttpServletResponse response, Users user)
            throws ServletException, IOException {

        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");

            int id = Integer.parseInt(request.getParameter("id"));
            String name = request.getParameter("name");
            String startAtStr = request.getParameter("startAt");
            int movieId = Integer.parseInt(request.getParameter("movieId"));
            int roomId = Integer.parseInt(request.getParameter("roomId"));
            double price = Double.parseDouble(request.getParameter("price"));
            String status = request.getParameter("status");

            // Lấy schedule hiện tại để kiểm tra
            Schedule existingSchedule = scheduleDAO.getScheduleById(id, user.getId());
            if (existingSchedule == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy lịch chiếu");
                return;
            }

            // Kiểm tra xem có thể chỉnh sửa không
            if (!existingSchedule.canBeEdited()) {
                request.setAttribute("error", "Lịch chiếu này không thể chỉnh sửa (đã quá gần giờ chiếu hoặc đã kết thúc)");
                showEditForm(request, response, user);
                return;
            }

            // VALIDATION CƠ BẢN
            if (name == null || name.trim().isEmpty()) {
                request.setAttribute("error", "Tên lịch chiếu không được để trống");
                showEditForm(request, response, user);
                return;
            }

            if (startAtStr == null || startAtStr.trim().isEmpty()) {
                request.setAttribute("error", "Thời gian bắt đầu không được để trống");
                showEditForm(request, response, user);
                return;
            }

            if (price <= 0) {
                request.setAttribute("error", "Giá vé phải lớn hơn 0");
                showEditForm(request, response, user);
                return;
            }

            // PARSE VÀ VALIDATE THỜI GIAN
            Date startAt = sdf.parse(startAtStr);

            // VALIDATE BUSINESS LOGIC
            // 1. Kiểm tra phim có đang chiếu không
            if (!scheduleDAO.isMovieActive(movieId)) {
                request.setAttribute("error", "Phim này không còn đang chiếu hoặc đã kết thúc");
                showEditForm(request, response, user);
                return;
            }

            // 2. Kiểm tra phòng có thuộc quyền quản lý của staff không
            if (!scheduleDAO.isRoomManagedByStaff(roomId, user.getId())) {
                request.setAttribute("error", "Bạn không có quyền cập nhật lịch chiếu cho phòng này");
                showEditForm(request, response, user);
                return;
            }

            // 3. Kiểm tra thời gian bắt đầu không được trong quá khứ
            Schedule updatedSchedule = new Schedule();
            updatedSchedule.setStartAt(startAt);
            if (!updatedSchedule.isValidStartTime()) {
                request.setAttribute("error", "Thời gian bắt đầu phải sau thời điểm hiện tại ít nhất 30 phút");
                showEditForm(request, response, user);
                return;
            }

            // 4. Tính thời gian kết thúc từ thời lượng phim
            int movieDuration = scheduleDAO.getMovieDuration(movieId);
            if (movieDuration <= 0) {
                request.setAttribute("error", "Không thể lấy thời lượng phim");
                showEditForm(request, response, user);
                return;
            }

            updatedSchedule.calculateEndTime(movieDuration);

            // 5. Kiểm tra thời gian kết thúc có hợp lệ không
            if (!updatedSchedule.isValidEndTime(movieDuration)) {
                request.setAttribute("error", "Thời gian kết thúc không khớp với thời lượng phim");
                showEditForm(request, response, user);
                return;
            }

            // 6. Kiểm tra trùng lịch chiếu trong phòng (trừ chính nó)
            if (scheduleDAO.isScheduleConflict(roomId, startAt, updatedSchedule.getFinishAt(), id)) {
                request.setAttribute("error", "Lịch chiếu bị trùng với lịch khác trong phòng này");
                showEditForm(request, response, user);
                return;
            }

            // CẬP NHẬT SCHEDULE
            existingSchedule.setName(name.trim());
            existingSchedule.setStartAt(startAt);
            existingSchedule.setFinishAt(updatedSchedule.getFinishAt());
            existingSchedule.setMovieId(movieId);
            existingSchedule.setRoomId(roomId);
            existingSchedule.setPrice(price);
            existingSchedule.setStatus(status != null ? status : Schedule.STATUS_ACTIVE);

            boolean success = scheduleDAO.updateSchedule(existingSchedule);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/staff/schedules?success=update");
            } else {
                request.setAttribute("error", "Lỗi khi cập nhật lịch chiếu");
                showEditForm(request, response, user);
            }

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Dữ liệu số không hợp lệ");
            showEditForm(request, response, user);
        } catch (java.text.ParseException e) {
            request.setAttribute("error", "Định dạng thời gian không hợp lệ");
            showEditForm(request, response, user);
        } catch (Exception e) {
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            showEditForm(request, response, user);
        }
    }

    // DELETE SCHEDULE
    private void deleteSchedule(HttpServletRequest request, HttpServletResponse response, Users user)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu ID");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);

            // Kiểm tra xem schedule có tồn tại và thuộc quyền quản lý không
            Schedule schedule = scheduleDAO.getScheduleById(id, user.getId());
            if (schedule == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy lịch chiếu");
                return;
            }

            // Kiểm tra xem có thể huỷ không
            if (!schedule.canBeCancelled()) {
                request.setAttribute("error", "Lịch chiếu này không thể huỷ (đã quá gần giờ chiếu hoặc đã kết thúc)");
                showScheduleList(request, response, user);
                return;
            }

            boolean success = scheduleDAO.deleteSchedule(id, user.getId());

            if (success) {
                response.sendRedirect(request.getContextPath() + "/staff/schedules?success=delete");
            } else {
                response.sendRedirect(request.getContextPath() + "/staff/schedules?error=delete");
            }

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID không hợp lệ");
        }
    }
}
