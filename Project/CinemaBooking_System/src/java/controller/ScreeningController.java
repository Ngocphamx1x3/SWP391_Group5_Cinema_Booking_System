package controller;

/**
 * ScreeningController - Quản lý các chức năng liên quan đến lịch chiếu phim
 * Note:
 * - Chỉ truy cập các DAO tại đây, không thao tác dữ liệu trực tiếp.
 * - Đảm bảo xác thực quyền truy cập cho "staff" và "admin" ở mọi request.
 * - Quy ước đặt tên theo chuẩn Java Coding Convention.
 * - Sử dụng tiếng Anh cho tên biến, tên hàm; tiếng Việt cho chú thích nếu cần giải thích rõ hơn cho nghiệp vụ.
 * - Các hàm xử lý nhiệm vụ rõ ràng, phân chia cho GET/POST tương ứng với từng action.
 * - Mọi lỗi phát sinh đều báo về view thông qua request attribute.
 * - operatingStatus tính tự động, không được sửa trực tiếp thông qua client.
 */

import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import dal.CinemaDAO;
import dal.MovieDAO;
import dal.RoomDAO;
import model.Cinema;
import model.Movie;
import model.Room;
import model.Users;
import dal.ScheduleDAO;
import model.Schedule;

@WebServlet(name = "ScreeningController", urlPatterns = {"/screeningManager"})
public class ScreeningController extends HttpServlet {

    private final MovieDAO movieDAO = new MovieDAO();
    private final CinemaDAO cinemaDAO = new CinemaDAO();
    private final RoomDAO roomDAO = new RoomDAO();
    private final ScheduleDAO scheduleDAO = new ScheduleDAO();

    /**
     * Hàm chuẩn hóa chuỗi trạng thái do người dùng nhập về đúng giá trị hệ thống
     * @param status String trạng thái nhập vào
     * @return String trạng thái đúng ("active", "cancelled", "inactive")
     */
    private String normalizeStatus(String status) {
        if (status == null) {
            return Schedule.STATUS_ACTIVE;
        }
        switch (status.trim().toLowerCase()) {
            case "active":
            case "1":
            case "true":
                return Schedule.STATUS_ACTIVE;
            case "cancelled":
            case "canceled":
            case "0":
                return Schedule.STATUS_CANCELLED;
            case "inactive":
            case "2":
                return Schedule.STATUS_INACTIVE;
            default:
                return Schedule.STATUS_ACTIVE;
        }
    }

    /**
     * Hàm tính toán trạng thái vận hành (operatingStatus) dựa vào thời gian bắt đầu và kết thúc
     * @param startAt   Thời điểm bắt đầu
     * @param finishAt  Thời điểm kết thúc
     * @return 0: chờ chiếu, 1: đang chiếu, 2: đã chiếu
     */
    private int calculateOperatingStatus(Date startAt, Date finishAt) {
        Date now = new Date();
        if (now.before(startAt)) {
            return 0; // chờ chiếu
        }
        if (now.after(finishAt)) {
            return 2; // đã chiếu
        }
        return 1; // đang chiếu
    }

    /**
     * Hàm validate dữ liệu đầu vào cho việc thêm/sửa lịch chiếu
     * Bỏ qua operatingStatus (không cho người dùng nhập)
     * @return null nếu hợp lệ, ngược lại trả về thông báo lỗi
     */
    private String validateScheduleInput(String movieIdStr, String theaterIdStr, String roomIdStr, String startAtStr, String status, String priceStr) {
        if (movieIdStr == null || movieIdStr.trim().isEmpty()
                || theaterIdStr == null || theaterIdStr.trim().isEmpty()
                || roomIdStr == null || roomIdStr.trim().isEmpty()
                || startAtStr == null || startAtStr.trim().isEmpty()
                || status == null || status.trim().isEmpty()
                || priceStr == null || priceStr.trim().isEmpty()) {
            return "Vui lòng điền đầy đủ thông tin";
        }
        try {
            Integer.parseInt(movieIdStr);
            Integer.parseInt(theaterIdStr);
            Integer.parseInt(roomIdStr);
            Double.parseDouble(priceStr);
        } catch (NumberFormatException e) {
            return "Dữ liệu số không hợp lệ";
        }
        return null;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Users user = (Users) session.getAttribute("account");

        // Kiểm tra đăng nhập
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role;
        try {
            role = user.getRole();
        } catch (Exception ex) {
            role = null;
        }

        if (role == null || (!"staff".equalsIgnoreCase(role) && !"admin".equalsIgnoreCase(role))) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "";
        }
        try {
            switch (action) {
                case "edit":
                    handleEditGet(request, response);
                    break;
                default:
                    handleListGet(request, response);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            handleListGet(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Users user = (Users) session.getAttribute("account");

        // Kiểm tra đăng nhập
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (!"staff".equalsIgnoreCase(user.getRole()) && !"admin".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = "";
        }
        try {
            switch (action) {
                case "add":
                    handleAddPost(request, response);
                    break;
                case "edit":
                    handleEditPost(request, response);
                    break;
                case "delete":
                    handleDeletePost(request, response);
                    break;
                default:
                    handleListGet(request, response);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            handleListGet(request, response);
        }
    }

    /**
     * Lấy danh sách lịch chiếu (có filter nếu có)
     */
    private void handleListGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String filterDate = request.getParameter("filterDate");
        String filterMovie = request.getParameter("filterMovie");
        String filterRoom = request.getParameter("filterRoom");
        String filterStatus = request.getParameter("filterStatus");
        // operatingStatus filter luôn là String khi lấy từ request, cần chuyển về int khi thực sự cần so sánh
        String filterOperatingStatusStr = request.getParameter("filterOperatingStatus");

        List<Movie> movieList = movieDAO.getAllMovies();
        List<Cinema> theaterList = cinemaDAO.getActiveCinemas();
        List<Room> roomList = roomDAO.getAllRooms();
        List<Movie> upcomingMovies = movieDAO.getUpcomingMovies();

        // Chỉ truyền các filter string cho getAllSchedules, tự động tính lại operatingStatus từng lịch chiếu trong list
        List<Schedule> scheduleList;
        if (filterDate != null || filterMovie != null || filterRoom != null || filterStatus != null) {
            scheduleList = scheduleDAO.getAllSchedules(
                    filterDate, filterMovie, filterRoom, filterStatus);
        } else {
            scheduleList = scheduleDAO.getAllSchedules(
                    "", "", "", ""
            );
        }

        // Cập nhật operatingStatus thực tế cho mỗi lịch chiếu
        if (scheduleList != null) {
            for (Schedule schedule : scheduleList) {
                schedule.setOperatingStatus(calculateOperatingStatus(schedule.getStartAt(), schedule.getFinishAt()));
            }
        }

        request.setAttribute("movieList", movieList);
        request.setAttribute("theaterList", theaterList);
        request.setAttribute("roomList", roomList);
        request.setAttribute("upcomingMovies", upcomingMovies);
        request.setAttribute("scheduleList", scheduleList);

        // filterOperatingStatus giữ nguyên string (nếu cần lọc ở view), KHÔNG xử lý sang String trong model
        request.setAttribute("filterOperatingStatus", filterOperatingStatusStr);

        request.getRequestDispatcher("/views/staff/screeningManager.jsp").forward(request, response);
    }

    /**
     * Hiển thị dữ liệu lịch chiếu lên form edit, mode chỉ xem
     */
    private void handleEditGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String scheduleIdStr = request.getParameter("scheduleId");
        if (scheduleIdStr == null || scheduleIdStr.trim().isEmpty()) {
            request.setAttribute("error", "ID lịch chiếu không hợp lệ");
            handleListGet(request, response);
            return;
        }

        try {
            int scheduleId = Integer.parseInt(scheduleIdStr);
            Schedule editSchedule = scheduleDAO.getScheduleById(scheduleId);
            List<Movie> movieList = movieDAO.getAllMovies();
            List<Cinema> theaterList = cinemaDAO.getActiveCinemas();
            List<Room> roomList = roomDAO.getAllRooms();
            if (editSchedule == null) {
                request.setAttribute("error", "Không tìm thấy lịch chiếu");
                handleListGet(request, response);
                return;
            }
            // Cập nhật lại operatingStatus thực tế
            editSchedule.setOperatingStatus(calculateOperatingStatus(editSchedule.getStartAt(), editSchedule.getFinishAt()));

            request.setAttribute("editSchedule", editSchedule);
            request.setAttribute("movieList", movieList);
            request.setAttribute("theaterList", theaterList);
            request.setAttribute("roomList", roomList);
            request.setAttribute("viewMode", true);

            request.getRequestDispatcher("/views/staff/screeningManager.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            request.setAttribute("error", "ID lịch chiếu không hợp lệ");
            handleListGet(request, response);
        }
    }

    /**
     * Xử lý thêm mới lịch chiếu
     */
    private void handleAddPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Lấy tham số từ form
        String movieIdStr = request.getParameter("movieId");
        String theaterIdStr = request.getParameter("theaterId");
        String roomIdStr = request.getParameter("roomId");
        String startAtStr = request.getParameter("startAt");
        String statusParam = request.getParameter("status");
        String priceStr = request.getParameter("price");

        String errMsg = validateScheduleInput(movieIdStr, theaterIdStr, roomIdStr, startAtStr, statusParam, priceStr);
        if (errMsg != null) {
            request.setAttribute("error", errMsg);
            handleListGet(request, response);
            return;
        }

        try {
            int movieId = Integer.parseInt(movieIdStr);
            int roomId = Integer.parseInt(roomIdStr);
            double price = Double.parseDouble(priceStr);

            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
            Date startAt = sdf.parse(startAtStr);

            // Lấy thông tin phim, tính thời gian kết thúc dựa vào duration
            Movie movie = movieDAO.getMovieById(movieId);
            if (movie == null) {
                request.setAttribute("error", "Không tìm thấy phim");
                handleListGet(request, response);
                return;
            }
            long durationMs = movie.getMovieDuration() * 60 * 1000L;
            Date finishAt = new Date(startAt.getTime() + durationMs);

            // Kiểm tra trùng thời gian phòng chiếu
            if (scheduleDAO.hasTimeOverlap(roomId, startAt, finishAt, 0)) {
                request.setAttribute("error", "Phòng chiếu đã có lịch chiếu trong khoảng thời gian này");
                handleListGet(request, response);
                return;
            }

            // Xây dựng đối tượng schedule
            Schedule schedule = new Schedule();
            schedule.setMovieId(movieId);
            schedule.setRoomId(roomId);
            schedule.setStartAt(startAt);
            schedule.setFinishAt(finishAt);
            schedule.setPrice(price);
            schedule.setStatus(normalizeStatus(statusParam));
            // operatingStatus tự động tính
            schedule.setOperatingStatus(calculateOperatingStatus(startAt, finishAt));

            if (scheduleDAO.addSchedule(schedule)) {
                request.setAttribute("success", "Thêm lịch chiếu thành công");
            } else {
                request.setAttribute("error", "Không thể thêm lịch chiếu");
            }

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Dữ liệu không hợp lệ.");
        } catch (ParseException e) {
            request.setAttribute("error", "Định dạng ngày giờ không hợp lệ");
        }

        handleListGet(request, response);
    }

    /**
     * Xử lý cập nhật lịch chiếu
     */
    private void handleEditPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String scheduleIdStr = request.getParameter("scheduleId");
        String roomIdStr = request.getParameter("editRoomId");
        String startAtStr = request.getParameter("editStartAt");
        String priceStr = request.getParameter("editPrice");
        String statusParam = request.getParameter("editStatus");

        // Khi sửa, movieId + theaterId không đổi nhưng vẫn cần truyền dummy cho hàm validate
        String errMsg = null;
        if (scheduleIdStr == null || scheduleIdStr.trim().isEmpty()) {
            errMsg = "Vui lòng điền đầy đủ thông tin";
        }
        if (errMsg == null) {
            errMsg = validateScheduleInput("1", "1", roomIdStr, startAtStr, statusParam, priceStr);
        }
        if (errMsg != null) {
            request.setAttribute("error", errMsg);
            handleListGet(request, response);
            return;
        }

        try {
            int scheduleId = Integer.parseInt(scheduleIdStr);
            int roomId = Integer.parseInt(roomIdStr);
            double price = Double.parseDouble(priceStr);

            // Lấy lịch chiếu hiện tại
            Schedule existingSchedule = scheduleDAO.getScheduleById(scheduleId);
            if (existingSchedule == null) {
                request.setAttribute("error", "Không tìm thấy lịch chiếu");
                handleListGet(request, response);
                return;
            }

            // Chỉ cho phép sửa khi operatingStatus khác 2 (đã chiếu)
            if (existingSchedule.getOperatingStatus() == 2) {
                request.setAttribute("error", "Không thể chỉnh sửa lịch chiếu đã chiếu");
                handleListGet(request, response);
                return;
            }

            if (!existingSchedule.canBeEdited()) {
                request.setAttribute("error", "Không thể chỉnh sửa lịch chiếu đã qua hoặc đã hủy");
                handleListGet(request, response);
                return;
            }

            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
            Date startAt = sdf.parse(startAtStr);

            // Lấy lại thông tin phim để tính thời lượng phim
            Movie movie = movieDAO.getMovieById(existingSchedule.getMovieId());
            if (movie == null) {
                request.setAttribute("error", "Không tìm thấy phim cho lịch chiếu này");
                handleListGet(request, response);
                return;
            }
            long durationMs = movie.getMovieDuration() * 60 * 1000L;
            Date finishAt = new Date(startAt.getTime() + durationMs);

            // Kiểm tra trùng thời gian (trừ lịch hiện tại)
            if (scheduleDAO.hasTimeOverlap(roomId, startAt, finishAt, scheduleId)) {
                request.setAttribute("error", "Phòng chiếu đã có lịch chiếu khác trong khoảng thời gian này");
                handleListGet(request, response);
                return;
            }

            // Cập nhật dữ liệu schedule
            existingSchedule.setRoomId(roomId);
            existingSchedule.setStartAt(startAt);
            existingSchedule.setFinishAt(finishAt);
            existingSchedule.setPrice(price);
            existingSchedule.setStatus(normalizeStatus(statusParam));
            existingSchedule.setOperatingStatus(calculateOperatingStatus(startAt, finishAt));

            if (scheduleDAO.updateSchedule(existingSchedule)) {
                request.setAttribute("success", "Cập nhật lịch chiếu thành công");
            } else {
                request.setAttribute("error", "Không thể cập nhật lịch chiếu");
            }

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Dữ liệu không hợp lệ");
        } catch (ParseException e) {
            request.setAttribute("error", "Định dạng ngày giờ không hợp lệ");
        }

        handleListGet(request, response);
    }

    /**
     * Xử lý hủy (xóa mềm) lịch chiếu
     */
    private void handleDeletePost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String scheduleIdStr = request.getParameter("scheduleId");
        if (scheduleIdStr == null || scheduleIdStr.trim().isEmpty()) {
            request.setAttribute("error", "ID lịch chiếu không hợp lệ");
            handleListGet(request, response);
            return;
        }

        try {
            int scheduleId = Integer.parseInt(scheduleIdStr);

            Schedule existingSchedule = scheduleDAO.getScheduleById(scheduleId);
            if (existingSchedule == null) {
                request.setAttribute("error", "Không tìm thấy lịch chiếu");
                handleListGet(request, response);
                return;
            }

            // Kiểm tra trạng thái vận hành
            if (existingSchedule.getOperatingStatus() == 2) {
                request.setAttribute("error", "Không thể hủy lịch chiếu đã chiếu (operatingStatus=2)");
                handleListGet(request, response);
                return;
            }

            // Kiểm tra có thể cancel không (model Schedule)
            if (!existingSchedule.canBeCancelled()) {
                request.setAttribute("error", "Không thể hủy lịch chiếu đã có vé bán hoặc đã qua");
                handleListGet(request, response);
                return;
            }

            // Thực hiện soft-delete (set status Cancelled)
            if (scheduleDAO.deleteSchedule(scheduleId)) {
                request.setAttribute("success", "Hủy lịch chiếu thành công");
            } else {
                request.setAttribute("error", "Không thể hủy lịch chiếu");
            }

        } catch (NumberFormatException e) {
            request.setAttribute("error", "ID lịch chiếu không hợp lệ");
        }

        handleListGet(request, response);
    }
}
