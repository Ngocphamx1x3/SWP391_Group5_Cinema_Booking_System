package controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import dal.SeatDesignDAO;
import dal.SeatTypeDAO;
import dal.RoomDAO;
import dal.CinemaStaffDAO;
import model.Seat;
import model.SeatType;
import model.Room;
import model.CinemaStaff;
import model.Users;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.*;

@WebServlet(name = "SeatDesignController", urlPatterns = {"/staff/seat-design", "/admin/seat-design"})
public class SeatDesignController extends HttpServlet {

    private SeatDesignDAO seatDesignDAO;
    private SeatTypeDAO seatTypeDAO;
    private RoomDAO roomDAO;
    private CinemaStaffDAO cinemaStaffDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        this.seatDesignDAO = new SeatDesignDAO();
        this.seatTypeDAO = new SeatTypeDAO();
        this.roomDAO = new RoomDAO();
        this.cinemaStaffDAO = new CinemaStaffDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        Users user = (Users) session.getAttribute("account");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            if (action == null) {
                showSeatDesigner(request, response, user);
            } else {
                switch (action) {
                    case "design":
                        showSeatDesigner(request, response, user);
                        break;
                    case "preview":
                        previewSeatDesign(request, response, user);
                        break;
                    case "generate-default":
                        generateDefaultSeats(request, response, user);
                        break;
                    default:
                        showSeatDesigner(request, response, user);
                        break;
                }
            }
        } catch (Exception e) {
            throw new ServletException("Lỗi xử lý request: " + e.getMessage(), e);
        }
    }

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
                case "save-design":
                    saveSeatDesign(request, response, user);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Action không hợp lệ");
            }
        } catch (Exception e) {
            throw new ServletException("Lỗi xử lý request: " + e.getMessage(), e);
        }
    }

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

    private void showRoomSelection(HttpServletRequest request, HttpServletResponse response, Users user)
            throws ServletException, IOException {

        int cinemaId = getCinemaIdForUser(user);
        List<Room> rooms;

        if (cinemaId == -1) {
            // Admin có thể xem tất cả phòng
            rooms = roomDAO.getAllRooms();
        } else {
            // Staff chỉ xem phòng của rạp mình quản lý
            rooms = roomDAO.getRoomsByCinemaId(cinemaId);
        }

        request.setAttribute("rooms", rooms);

        String viewPath = "admin".equalsIgnoreCase(user.getRole())
                ? "/views/admin/roomSelection.jsp"
                : "/views/staff/roomSelection.jsp";

        RequestDispatcher dispatcher = request.getRequestDispatcher(viewPath);
        dispatcher.forward(request, response);
    }

    private void showSeatDesigner(HttpServletRequest request, HttpServletResponse response, Users user)
            throws ServletException, IOException {

        String roomIdStr = request.getParameter("roomId");

        // Nếu thiếu roomId, chuyển hướng đến trang chọn phòng
        if (roomIdStr == null || roomIdStr.isEmpty()) {
            showRoomSelection(request, response, user);
            return;
        }

        try {
            int roomId = Integer.parseInt(roomIdStr);

            // Lấy thông tin layout phòng
            Map<String, Object> roomLayout = seatDesignDAO.getRoomLayout(roomId);
            if (roomLayout.isEmpty()) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy phòng");
                return;
            }

            // Kiểm tra quyền truy cập
            int userCinemaId = getCinemaIdForUser(user);
            if (userCinemaId != -1 && (int) roomLayout.get("cinemaId") != userCinemaId) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập phòng này");
                return;
            }

            // Lấy danh sách ghế hiện tại
            List<Seat> seats = seatDesignDAO.getSeatsByRoomId(roomId);

            // Lấy danh sách loại ghế (chỉ lấy các loại ghế đang hoạt động)
            List<SeatType> seatTypes = seatTypeDAO.getActiveSeatTypes();

            request.setAttribute("roomId", roomId);
            request.setAttribute("roomLayout", roomLayout);
            request.setAttribute("seats", seats);
            request.setAttribute("seatTypes", seatTypes);

            String viewPath = "admin".equalsIgnoreCase(user.getRole())
                    ? "/views/admin/seatDesigner.jsp"
                    : "/views/staff/seatDesigner.jsp";

            RequestDispatcher dispatcher = request.getRequestDispatcher(viewPath);
            dispatcher.forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "roomId không hợp lệ");
        }
    }

    private void generateDefaultSeats(HttpServletRequest request, HttpServletResponse response, Users user)
            throws ServletException, IOException {

        try {
            int roomId = Integer.parseInt(request.getParameter("roomId"));

            // Kiểm tra quyền truy cập
            Room room = roomDAO.getRoomById(roomId);
            if (room == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy phòng");
                return;
            }

            int userCinemaId = getCinemaIdForUser(user);
            if (userCinemaId != -1 && room.getCinemaId() != userCinemaId) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập phòng này");
                return;
            }

            boolean success = seatDesignDAO.createDefaultSeats(roomId, room.getSeatRows(), room.getSeatColumns());

            if (success) {
                response.sendRedirect(request.getContextPath()
                        + ("admin".equalsIgnoreCase(user.getRole()) ? "/admin/seat-design" : "/staff/seat-design")
                        + "?roomId=" + roomId + "&success=generate");
            } else {
                response.sendRedirect(request.getContextPath()
                        + ("admin".equalsIgnoreCase(user.getRole()) ? "/admin/seat-design" : "/staff/seat-design")
                        + "?roomId=" + roomId + "&error=generate");
            }

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "roomId không hợp lệ");
        } catch (Exception e) {
            throw new ServletException("Lỗi tạo ghế mặc định: " + e.getMessage(), e);
        }
    }

    private void previewSeatDesign(HttpServletRequest request, HttpServletResponse response, Users user)
            throws ServletException, IOException {
        // Hiển thị preview cho khách hàng
        showSeatDesigner(request, response, user);
    }

    private void saveSeatDesign(HttpServletRequest request, HttpServletResponse response, Users user)
            throws ServletException, IOException {

        System.out.println("🎯 ===== SAVE SEAT DESIGN STARTED =====");
    System.out.println("👤 User: " + user.getUsername());
    System.out.println("🕒 Time: " + new java.util.Date());

        try {
            // Đọc dữ liệu JSON từ request
            StringBuilder jsonBuffer = new StringBuilder();
            String line;
            while ((line = request.getReader().readLine()) != null) {
                jsonBuffer.append(line);
            }
            String jsonData = jsonBuffer.toString();

            System.out.println("📥 Received JSON data: " + jsonData);

            ObjectMapper mapper = new ObjectMapper();
            JsonNode rootNode = mapper.readTree(jsonData);

            int roomId = rootNode.get("roomId").asInt();
            JsonNode seatsNode = rootNode.get("seats");

            System.out.println("🛏️ Room ID: " + roomId);
            System.out.println("💺 Number of seats: " + seatsNode.size());

            // Kiểm tra quyền truy cập
            Room room = roomDAO.getRoomById(roomId);
            if (room == null) {
                System.out.println("❌ Room not found: " + roomId);
                sendJsonResponse(response, false, "Không tìm thấy phòng");
                return;
            }

            int userCinemaId = getCinemaIdForUser(user);
            if (userCinemaId != -1 && room.getCinemaId() != userCinemaId) {
                System.out.println("❌ Permission denied");
                sendJsonResponse(response, false, "Bạn không có quyền truy cập phòng này");
                return;
            }

            // Parse seats từ JSON - DEBUG TỪNG FIELD
            List<Seat> seats = new ArrayList<>();
            for (JsonNode seatNode : seatsNode) {
                System.out.println("🔍 DEBUG Seat node: " + seatNode.toString());

                // DEBUG từng field
                System.out.println("   📋 Available fields in seat node:");
                Iterator<String> fieldNames = seatNode.fieldNames();
                while (fieldNames.hasNext()) {
                    String fieldName = fieldNames.next();
                    System.out.println("      - " + fieldName + ": " + seatNode.get(fieldName));
                }

                Seat seat = new Seat();

                // Xử lý từng field với kiểm tra null
                if (seatNode.has("id") && !seatNode.get("id").isNull()) {
                    seat.setId(seatNode.get("id").asInt());
                    System.out.println("   ✅ id: " + seat.getId());
                }

                // Kiểm tra từng field trước khi lấy giá trị
                if (!seatNode.has("code")) {
                    System.out.println("   ❌ MISSING FIELD: code");
                    continue; // Bỏ qua seat này nếu thiếu field bắt buộc
                }
                seat.setCode(seatNode.get("code").asText());
                System.out.println("   ✅ code: " + seat.getCode());

                if (!seatNode.has("typeId")) {
                    System.out.println("   ❌ MISSING FIELD: typeId");
                    continue;
                }
                seat.setSeatTypeId(seatNode.get("typeId").asInt());
                System.out.println("   ✅ typeId: " + seat.getSeatTypeId());

                if (!seatNode.has("x")) {
                    System.out.println("   ❌ MISSING FIELD: x");
                    continue;
                }
                seat.setPositionX(seatNode.get("x").asInt());
                System.out.println("   ✅ x: " + seat.getPositionX());

                if (!seatNode.has("y")) {
                    System.out.println("   ❌ MISSING FIELD: y");
                    continue;
                }
                seat.setPositionY(seatNode.get("y").asInt());
                System.out.println("   ✅ y: " + seat.getPositionY());

                if (!seatNode.has("width")) {
                    System.out.println("   ❌ MISSING FIELD: width");
                    continue;
                }
                seat.setWidthUnits(seatNode.get("width").asInt());
                System.out.println("   ✅ width: " + seat.getWidthUnits());

                if (!seatNode.has("color")) {
                    System.out.println("   ❌ MISSING FIELD: color");
                    continue;
                }
                seat.setCustomColor(seatNode.get("color").asText());
                System.out.println("   ✅ color: " + seat.getCustomColor());

                // Các field mặc định
                seat.setHeightUnits(1);
                seat.setRoomId(roomId);
                seat.setStatus(true);
                seat.setAvailable(true);
                seat.setDraggable(true);
                seat.setDescription(seat.getCode() + " seat");
                seat.setLine(getRowLetter(seat.getPositionY()));
                seat.setNumber(seat.getPositionX() + 1);
                seat.setRowCode(getRowLetter(seat.getPositionY()));
                seat.setColumnNumber(seat.getPositionX() + 1);
                seat.setPosition(seat.getPositionX() + "," + seat.getPositionY());

                seats.add(seat);
                System.out.println("   ✅ Added seat: " + seat.getCode());
            }

            System.out.println("💾 Saving " + seats.size() + " seats to database...");

            if (seats.isEmpty()) {
                System.out.println("❌ No valid seats to save!");
                sendJsonResponse(response, false, "Không có ghế hợp lệ để lưu");
                return;
            }

            // Lưu thiết kế
            boolean success = seatDesignDAO.saveSeatDesign(roomId, seats);

            if (success) {
                System.out.println("✅ Save successful!");
                sendJsonResponse(response, true, "Lưu thiết kế ghế thành công!");
            } else {
                System.out.println("❌ Save failed in DAO!");
                sendJsonResponse(response, false, "Lỗi khi lưu thiết kế ghế");
            }

        } catch (Exception e) {
            System.err.println("💥 ERROR in saveSeatDesign: " + e.getMessage());
            e.printStackTrace();
            sendJsonResponse(response, false, "Lỗi hệ thống: " + e.getMessage());
        }
    }

// HELPER METHOD ĐỂ GỬI JSON RESPONSE
    private void sendJsonResponse(HttpServletResponse response, boolean success, String message)
            throws IOException {
        Map<String, Object> responseData = new HashMap<>();
        responseData.put("success", success);
        responseData.put("message", message);
        sendJsonResponse(response, responseData);
    }

    private String getRowLetter(int y) {
        String[] rowLetters = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O"};
        return y < rowLetters.length ? rowLetters[y] : "R" + (y + 1);
    }

    private String getSeatTypeName(int typeId) {
        // Bạn có thể lấy từ database hoặc hardcode
        switch (typeId) {
            case 1:
                return "Standard";
            case 2:
                return "VIP";
            case 3:
                return "Couple";
            case 4:
                return "Disabled";
            default:
                return "Standard";
        }
    }

    private void sendJsonResponse(HttpServletResponse response, Map<String, Object> responseData)
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        ObjectMapper mapper = new ObjectMapper();
        String jsonResponse = mapper.writeValueAsString(responseData);
        response.getWriter().write(jsonResponse);
    }

    private List<Seat> parseSeatsFromJson(String seatsData, int roomId) {
        // Implement JSON parsing logic here
        // Sử dụng thư viện như Jackson hoặc Gson
        // Tạm thời trả về empty list
        return new ArrayList<>();
    }
}
