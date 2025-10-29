package controller;

import dal.RoomDAO;
import dal.CinemaStaffDAO;
import model.Room;
import model.CinemaStaff;
import model.Users;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "RoomController", urlPatterns = {"/staff/rooms", "/admin/rooms"})
public class RoomController extends HttpServlet {

    private RoomDAO roomDAO;
    private CinemaStaffDAO cinemaStaffDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        this.roomDAO = new RoomDAO();
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

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            switch (action) {
                case "list":
                    showRoomList(request, response, user);
                    break;
                case "add":
                    showAddForm(request, response, user);
                    break;
                case "edit":
                    showEditForm(request, response, user);
                    break;
                case "delete":
                    deleteRoom(request, response, user);
                    break;
                case "search":
                    searchRooms(request, response, user);
                    break;
                case "by-screen-type":
                    getRoomsByScreenType(request, response, user);
                    break;
                default:
                    showRoomList(request, response, user);
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

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            switch (action) {
                case "create":
                    createRoom(request, response, user);
                    break;
                case "update":
                    updateRoom(request, response, user);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Action không hợp lệ");
            }
        } catch (Exception e) {
            throw new ServletException("Lỗi xử lý request: " + e.getMessage(), e);
        }
    }

    // ===== PRIVATE METHODS =====
    // GET CINEMA ID FOR USER
    private int getCinemaIdForUser(Users user) {
        if ("admin".equalsIgnoreCase(user.getRole())) {
            // Admin có thể xem tất cả, trả về -1 để chỉ định không filter
            return -1;
        } else if ("staff".equalsIgnoreCase(user.getRole())) {
            // Staff chỉ có thể xem phòng của rạp mình quản lý
            List<CinemaStaff> assignments = cinemaStaffDAO.getAssignmentsByStaffId(user.getId());
            if (!assignments.isEmpty()) {
                return assignments.get(0).getCinemaId();
            }
        }
        return -1;
    }

    // SHOW ROOM LIST
    private void showRoomList(HttpServletRequest request, HttpServletResponse response, Users user)
            throws ServletException, IOException {

        int cinemaId = getCinemaIdForUser(user);
        List<Room> rooms;

        String searchKeyword = request.getParameter("keyword");
        String screenType = request.getParameter("type");

        // Nếu có search keyword hoặc filter
        if ((searchKeyword != null && !searchKeyword.trim().isEmpty())
                || (screenType != null && !screenType.trim().isEmpty())) {

            if (cinemaId == -1) {
                // Admin search - cần implement searchAll trong DAO
                rooms = roomDAO.getAllRooms(); // Tạm thời
            } else {
                if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
                    rooms = roomDAO.searchRooms(searchKeyword.trim(), cinemaId);
                } else if (screenType != null && !screenType.trim().isEmpty()) {
                    rooms = roomDAO.getRoomsByScreenType(screenType.trim(), cinemaId);
                } else {
                    rooms = roomDAO.getRoomsByCinemaId(cinemaId);
                }
            }

            if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
                request.setAttribute("searchKeyword", searchKeyword.trim());
            }
            if (screenType != null && !screenType.trim().isEmpty()) {
                request.setAttribute("selectedScreenType", screenType.trim());
            }

        } else {
            // Không có search, hiển thị tất cả
            if (cinemaId == -1) {
                rooms = roomDAO.getAllRooms();
            } else {
                rooms = roomDAO.getRoomsByCinemaId(cinemaId);
            }
        }

        request.setAttribute("rooms", rooms);
        request.setAttribute("userRole", user.getRole());

        String viewPath = "admin".equalsIgnoreCase(user.getRole())
                ? "/views/admin/roomList.jsp"
                : "/views/staff/roomList.jsp";

        RequestDispatcher dispatcher = request.getRequestDispatcher(viewPath);
        dispatcher.forward(request, response);
    }

    // SHOW ADD FORM
    private void showAddForm(HttpServletRequest request, HttpServletResponse response, Users user)
            throws ServletException, IOException {

        int cinemaId = getCinemaIdForUser(user);
        if (cinemaId == -1) {
            // Admin cần chọn rạp
            request.setAttribute("isAdmin", true);
        } else {
            request.setAttribute("cinemaId", cinemaId);
        }

        String viewPath = "admin".equalsIgnoreCase(user.getRole())
                ? "/views/admin/roomForm.jsp"
                : "/views/staff/roomForm.jsp";

        RequestDispatcher dispatcher = request.getRequestDispatcher(viewPath);
        dispatcher.forward(request, response);
    }

    // SHOW EDIT FORM
    private void showEditForm(HttpServletRequest request, HttpServletResponse response, Users user)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu ID");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            Room room = roomDAO.getRoomById(id);

            if (room == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy phòng chiếu");
                return;
            }

            // Kiểm tra quyền truy cập
            int userCinemaId = getCinemaIdForUser(user);
            if (userCinemaId != -1 && room.getCinemaId() != userCinemaId) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập phòng này");
                return;
            }

            request.setAttribute("room", room);
            String viewPath = "admin".equalsIgnoreCase(user.getRole())
                    ? "/views/admin/roomForm.jsp"
                    : "/views/staff/roomForm.jsp";

            RequestDispatcher dispatcher = request.getRequestDispatcher(viewPath);
            dispatcher.forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID không hợp lệ");
        }
    }

    // SEARCH ROOMS
    private void searchRooms(HttpServletRequest request, HttpServletResponse response, Users user)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");
        String screenType = request.getParameter("type");
        int cinemaId = getCinemaIdForUser(user);
        List<Room> rooms;

        if ((keyword != null && !keyword.trim().isEmpty())
                || (screenType != null && !screenType.trim().isEmpty())) {

            if (cinemaId == -1) {
                // Admin search
                rooms = roomDAO.getAllRooms(); // Tạm thời
            } else {
                if (keyword != null && !keyword.trim().isEmpty()) {
                    rooms = roomDAO.searchRooms(keyword.trim(), cinemaId);
                } else if (screenType != null && !screenType.trim().isEmpty()) {
                    rooms = roomDAO.getRoomsByScreenType(screenType.trim(), cinemaId);
                } else {
                    rooms = roomDAO.getRoomsByCinemaId(cinemaId);
                }
            }

            if (keyword != null && !keyword.trim().isEmpty()) {
                request.setAttribute("searchKeyword", keyword.trim());
            }
            if (screenType != null && !screenType.trim().isEmpty()) {
                request.setAttribute("selectedScreenType", screenType.trim());
            }

        } else {
            if (cinemaId == -1) {
                rooms = roomDAO.getAllRooms();
            } else {
                rooms = roomDAO.getRoomsByCinemaId(cinemaId);
            }
        }

        request.setAttribute("rooms", rooms);
        request.setAttribute("userRole", user.getRole());

        String viewPath = "admin".equalsIgnoreCase(user.getRole())
                ? "/views/admin/roomList.jsp"
                : "/views/staff/roomList.jsp";

        RequestDispatcher dispatcher = request.getRequestDispatcher(viewPath);
        dispatcher.forward(request, response);
    }

    // GET ROOMS BY SCREEN TYPE
    private void getRoomsByScreenType(HttpServletRequest request, HttpServletResponse response, Users user)
            throws ServletException, IOException {

        String screenType = request.getParameter("type");
        int cinemaId = getCinemaIdForUser(user);
        List<Room> rooms;

        if (screenType != null && !screenType.trim().isEmpty()) {
            if (cinemaId == -1) {
                rooms = roomDAO.getAllRooms(); // Admin cần filter riêng
            } else {
                rooms = roomDAO.getRoomsByScreenType(screenType.trim(), cinemaId);
            }
            request.setAttribute("selectedScreenType", screenType.trim());
        } else {
            if (cinemaId == -1) {
                rooms = roomDAO.getAllRooms();
            } else {
                rooms = roomDAO.getRoomsByCinemaId(cinemaId);
            }
        }

        request.setAttribute("rooms", rooms);
        request.setAttribute("userRole", user.getRole());

        String viewPath = "admin".equalsIgnoreCase(user.getRole())
                ? "/views/admin/roomList.jsp"
                : "/views/staff/roomList.jsp";

        RequestDispatcher dispatcher = request.getRequestDispatcher(viewPath);
        dispatcher.forward(request, response);
    }

    // CREATE ROOM
    private void createRoom(HttpServletRequest request, HttpServletResponse response, Users user)
            throws ServletException, IOException {

        try {
            int cinemaId;
            if ("admin".equalsIgnoreCase(user.getRole())) {
                cinemaId = Integer.parseInt(request.getParameter("cinemaId"));
            } else {
                cinemaId = getCinemaIdForUser(user);
            }

            String code = request.getParameter("code");
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            int capacity = Integer.parseInt(request.getParameter("capacity"));
            int seatRows = Integer.parseInt(request.getParameter("seatRows"));
            int seatColumns = Integer.parseInt(request.getParameter("seatColumns"));
            String screenType = request.getParameter("screenType");
            String soundSystem = request.getParameter("soundSystem");
            boolean status = "on".equals(request.getParameter("status"));

            // VALIDATION
            if (code == null || code.trim().isEmpty()) {
                request.setAttribute("error", "Mã phòng không được để trống");
                showAddForm(request, response, user);
                return;
            }

            if (name == null || name.trim().isEmpty()) {
                request.setAttribute("error", "Tên phòng không được để trống");
                showAddForm(request, response, user);
                return;
            }

            if (roomDAO.isCodeExists(code, cinemaId)) {
                request.setAttribute("error", "Mã phòng '" + code + "' đã tồn tại trong rạp này");
                showAddForm(request, response, user);
                return;
            }

            if (seatRows <= 0 || seatRows > 20) {
                request.setAttribute("error", "Số hàng ghế phải từ 1-20");
                showAddForm(request, response, user);
                return;
            }

            if (seatColumns <= 0 || seatColumns > 25) {
                request.setAttribute("error", "Số cột ghế phải từ 1-25");
                showAddForm(request, response, user);
                return;
            }

            if (capacity <= 0) {
                request.setAttribute("error", "Sức chứa phải lớn hơn 0");
                showAddForm(request, response, user);
                return;
            }

            // VALIDATION QUAN TRỌNG: Capacity không vượt quá số hàng × số cột
            int maxCapacity = seatRows * seatColumns;
            if (capacity > maxCapacity) {
                request.setAttribute("error", 
                    "Sức chứa (" + capacity + ") không thể vượt quá " + 
                    maxCapacity + " (số hàng × số cột)");
                showAddForm(request, response, user);
                return;
            }

            // Tạo room object
            Room room = new Room(cinemaId, code, name, description, capacity,
                    seatRows, seatColumns, screenType, soundSystem, status);

            boolean success = roomDAO.addRoom(room);

            if (success) {
                String redirectPath = "admin".equalsIgnoreCase(user.getRole())
                        ? "/admin/rooms?success=create"
                        : "/staff/rooms?success=create";
                response.sendRedirect(request.getContextPath() + redirectPath);
            } else {
                request.setAttribute("error", "Lỗi khi tạo phòng chiếu");
                showAddForm(request, response, user);
            }

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Dữ liệu số không hợp lệ");
            showAddForm(request, response, user);
        } catch (Exception e) {
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            showAddForm(request, response, user);
        }
    }

    // UPDATE ROOM
    private void updateRoom(HttpServletRequest request, HttpServletResponse response, Users user)
            throws ServletException, IOException {

        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String code = request.getParameter("code");
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            int capacity = Integer.parseInt(request.getParameter("capacity"));
            int seatRows = Integer.parseInt(request.getParameter("seatRows"));
            int seatColumns = Integer.parseInt(request.getParameter("seatColumns"));
            String screenType = request.getParameter("screenType");
            String soundSystem = request.getParameter("soundSystem");
            boolean status = "on".equals(request.getParameter("status"));

            // Lấy thông tin room hiện tại để lấy cinemaId
            Room existingRoom = roomDAO.getRoomById(id);
            if (existingRoom == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy phòng chiếu");
                return;
            }

            // Kiểm tra quyền truy cập
            int userCinemaId = getCinemaIdForUser(user);
            if (userCinemaId != -1 && existingRoom.getCinemaId() != userCinemaId) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền cập nhật phòng này");
                return;
            }

            // VALIDATION
            if (code == null || code.trim().isEmpty()) {
                request.setAttribute("error", "Mã phòng không được để trống");
                showEditForm(request, response, user);
                return;
            }

            if (name == null || name.trim().isEmpty()) {
                request.setAttribute("error", "Tên phòng không được để trống");
                showEditForm(request, response, user);
                return;
            }

            if (roomDAO.isCodeExists(code, existingRoom.getCinemaId(), id)) {
                request.setAttribute("error", "Mã phòng '" + code + "' đã tồn tại trong rạp này");
                showEditForm(request, response, user);
                return;
            }

            if (seatRows <= 0 || seatRows > 20) {
                request.setAttribute("error", "Số hàng ghế phải từ 1-20");
                showEditForm(request, response, user);
                return;
            }

            if (seatColumns <= 0 || seatColumns > 25) {
                request.setAttribute("error", "Số cột ghế phải từ 1-25");
                showEditForm(request, response, user);
                return;
            }

            if (capacity <= 0) {
                request.setAttribute("error", "Sức chứa phải lớn hơn 0");
                showEditForm(request, response, user);
                return;
            }

            // VALIDATION QUAN TRỌNG: Capacity không vượt quá số hàng × số cột
            int maxCapacity = seatRows * seatColumns;
            if (capacity > maxCapacity) {
                request.setAttribute("error", 
                    "Sức chứa (" + capacity + ") không thể vượt quá " + 
                    maxCapacity + " (số hàng × số cột)");
                showEditForm(request, response, user);
                return;
            }

            // Cập nhật room
            existingRoom.setCode(code);
            existingRoom.setName(name);
            existingRoom.setDescription(description);
            existingRoom.setCapacity(capacity);
            existingRoom.setSeatRows(seatRows);
            existingRoom.setSeatColumns(seatColumns);
            existingRoom.setScreenType(screenType);
            existingRoom.setSoundSystem(soundSystem);
            existingRoom.setStatus(status);

            boolean success = roomDAO.updateRoom(existingRoom);

            if (success) {
                String redirectPath = "admin".equalsIgnoreCase(user.getRole())
                        ? "/admin/rooms?success=update"
                        : "/staff/rooms?success=update";
                response.sendRedirect(request.getContextPath() + redirectPath);
            } else {
                request.setAttribute("error", "Lỗi khi cập nhật phòng chiếu");
                showEditForm(request, response, user);
            }

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Dữ liệu số không hợp lệ");
            showEditForm(request, response, user);
        } catch (Exception e) {
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            showEditForm(request, response, user);
        }
    }

    // DELETE ROOM
    private void deleteRoom(HttpServletRequest request, HttpServletResponse response, Users user)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu ID");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);

            // Kiểm tra quyền truy cập
            Room room = roomDAO.getRoomById(id);
            if (room != null) {
                int userCinemaId = getCinemaIdForUser(user);
                if (userCinemaId != -1 && room.getCinemaId() != userCinemaId) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền xóa phòng này");
                    return;
                }
            }

            boolean success = roomDAO.deleteRoom(id);

            if (success) {
                String redirectPath = "admin".equalsIgnoreCase(user.getRole())
                        ? "/admin/rooms?success=delete"
                        : "/staff/rooms?success=delete";
                response.sendRedirect(request.getContextPath() + redirectPath);
            } else {
                String redirectPath = "admin".equalsIgnoreCase(user.getRole())
                        ? "/admin/rooms?error=delete"
                        : "/staff/rooms?error=delete";
                response.sendRedirect(request.getContextPath() + redirectPath);
            }

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID không hợp lệ");
        }
    }
}