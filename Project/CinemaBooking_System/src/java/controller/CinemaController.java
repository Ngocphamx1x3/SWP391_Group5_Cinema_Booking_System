package controller;

import dal.CinemaDAO;
import dal.CinemaStaffDAO;
import dal.UserDAO;
import model.Cinema;
import model.CinemaStaff;
import model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "CinemaController", urlPatterns = {"/admin/cinemas"})
public class CinemaController extends HttpServlet {

    private CinemaDAO cinemaDAO;
    private CinemaStaffDAO cinemaStaffDAO;
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        this.cinemaDAO = new CinemaDAO();
        this.cinemaStaffDAO = new CinemaStaffDAO();
        this.userDAO = new UserDAO();
    }

    // ===== HANDLE GET REQUESTS =====
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        if (action == null) action = "list";
        
        try {
            switch (action) {
                case "list":
                    showCinemaList(request, response);
                    break;
                case "add":
                    showAddForm(request, response);
                    break;
                case "edit":
                    showEditForm(request, response);
                    break;
                case "delete":
                    deleteCinema(request, response);
                    break;
                case "manage-staff":
                    showManageStaffForm(request, response);
                    break;
                case "assign-staff":
                    showAssignStaffForm(request, response);
                    break;
                case "edit-assignment":
                    showEditAssignmentForm(request, response);
                    break;
                case "remove-staff":
                    removeStaffAssignment(request, response);
                    break;
                default:
                    showCinemaList(request, response);
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
        
        try {
            switch (action) {
                case "create":
                    createCinema(request, response);
                    break;
                case "update":
                    updateCinema(request, response);
                    break;
                case "assign-staff":
                    assignStaffToCinema(request, response);
                    break;
                case "update-assignment":
                    updateStaffAssignment(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Action không hợp lệ");
            }
        } catch (Exception e) {
            throw new ServletException("Lỗi xử lý request: " + e.getMessage(), e);
        }
    }

    // ===== PRIVATE METHODS =====

    // SHOW CINEMA LIST
    private void showCinemaList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String searchKeyword = request.getParameter("search");
        List<Cinema> cinemas;
        
        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            cinemas = cinemaDAO.searchCinemas(searchKeyword.trim());
            request.setAttribute("searchKeyword", searchKeyword.trim());
        } else {
            cinemas = cinemaDAO.getAllCinemas();
        }
        
        request.setAttribute("cinemas", cinemas);
        RequestDispatcher dispatcher = request.getRequestDispatcher("/views/admin/cinemaList.jsp");
        dispatcher.forward(request, response);
    }
    
    // SHOW ADD FORM
    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        RequestDispatcher dispatcher = request.getRequestDispatcher("/views/admin/cinemaForm.jsp");
        dispatcher.forward(request, response);
    }
    
    // SHOW EDIT FORM
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu ID");
            return;
        }
        
        try {
            int id = Integer.parseInt(idStr);
            Cinema cinema = cinemaDAO.getCinemaById(id);
            
            if (cinema == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy rạp chiếu");
                return;
            }
            
            request.setAttribute("cinema", cinema);
            RequestDispatcher dispatcher = request.getRequestDispatcher("/views/admin/cinemaForm.jsp");
            dispatcher.forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID không hợp lệ");
        }
    }
    
    // SHOW MANAGE STAFF FORM
    private void showManageStaffForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu ID rạp chiếu");
            return;
        }
        
        try {
            int cinemaId = Integer.parseInt(idStr);
            Cinema cinema = cinemaDAO.getCinemaById(cinemaId);
            
            if (cinema == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy rạp chiếu");
                return;
            }
            
            // Lấy danh sách staff đang làm việc tại rạp này
            List<CinemaStaff> staffAssignments = cinemaStaffDAO.getAssignmentsByCinemaId(cinemaId);
            
            request.setAttribute("cinema", cinema);
            request.setAttribute("staffAssignments", staffAssignments);
            RequestDispatcher dispatcher = request.getRequestDispatcher("/views/admin/cinemaStaffManagement.jsp");
            dispatcher.forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID không hợp lệ");
        }
    }
    
    // SHOW ASSIGN STAFF FORM
    private void showAssignStaffForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String cinemaIdStr = request.getParameter("cinemaId");
        if (cinemaIdStr == null || cinemaIdStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu ID rạp chiếu");
            return;
        }
        
        try {
            int cinemaId = Integer.parseInt(cinemaIdStr);
            Cinema cinema = cinemaDAO.getCinemaById(cinemaId);
            
            if (cinema == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy rạp chiếu");
                return;
            }
            
            // Lấy danh sách staff có sẵn (chưa được assign hoặc đang inactive)
            List<User> availableStaff = userDAO.getActiveStaff();
            
            request.setAttribute("cinema", cinema);
            request.setAttribute("availableStaff", availableStaff);
            RequestDispatcher dispatcher = request.getRequestDispatcher("/views/admin/assignStaffForm.jsp");
            dispatcher.forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID không hợp lệ");
        }
    }
    
    // SHOW EDIT ASSIGNMENT FORM
    private void showEditAssignmentForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String assignmentIdStr = request.getParameter("assignmentId");
        if (assignmentIdStr == null || assignmentIdStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu ID phân công");
            return;
        }
        
        try {
            int assignmentId = Integer.parseInt(assignmentIdStr);
            CinemaStaff assignment = cinemaStaffDAO.getAssignmentById(assignmentId);
            
            if (assignment == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy phân công");
                return;
            }
            
            request.setAttribute("assignment", assignment);
            RequestDispatcher dispatcher = request.getRequestDispatcher("/views/admin/editStaffAssignment.jsp");
            dispatcher.forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID không hợp lệ");
        }
    }
    
    // CREATE CINEMA
    private void createCinema(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            String code = request.getParameter("code");
            String name = request.getParameter("name");
            String address = request.getParameter("address");
            String description = request.getParameter("description");
            int capacity = Integer.parseInt(request.getParameter("capacity"));
            boolean status = "on".equals(request.getParameter("status"));
            String phone = request.getParameter("phone");
            int totalRooms = Integer.parseInt(request.getParameter("totalRooms"));
            String operatingHours = request.getParameter("operatingHours");
            
            // Validation
            if (code == null || code.trim().isEmpty()) {
                request.setAttribute("error", "Mã rạp không được để trống");
                showAddForm(request, response);
                return;
            }
            
            if (name == null || name.trim().isEmpty()) {
                request.setAttribute("error", "Tên rạp không được để trống");
                showAddForm(request, response);
                return;
            }
            
            if (cinemaDAO.isCodeExists(code)) {
                request.setAttribute("error", "Mã rạp '" + code + "' đã tồn tại");
                showAddForm(request, response);
                return;
            }
            
            // Tạo cinema object
            Cinema cinema = new Cinema(code, name, address, description, capacity, status, phone, totalRooms, operatingHours);
            
            boolean success = cinemaDAO.addCinema(cinema);
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/cinemas?success=create");
            } else {
                request.setAttribute("error", "Lỗi khi tạo rạp chiếu");
                showAddForm(request, response);
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Dữ liệu số không hợp lệ");
            showAddForm(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            showAddForm(request, response);
        }
    }
    
    // UPDATE CINEMA
    private void updateCinema(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String code = request.getParameter("code");
            String name = request.getParameter("name");
            String address = request.getParameter("address");
            String description = request.getParameter("description");
            int capacity = Integer.parseInt(request.getParameter("capacity"));
            boolean status = "on".equals(request.getParameter("status"));
            String phone = request.getParameter("phone");
            int totalRooms = Integer.parseInt(request.getParameter("totalRooms"));
            String operatingHours = request.getParameter("operatingHours");
            
            // Validation
            if (code == null || code.trim().isEmpty()) {
                request.setAttribute("error", "Mã rạp không được để trống");
                showEditForm(request, response);
                return;
            }
            
            if (name == null || name.trim().isEmpty()) {
                request.setAttribute("error", "Tên rạp không được để trống");
                showEditForm(request, response);
                return;
            }
            
            // Check if code exists (excluding current record)
            if (cinemaDAO.isCodeExists(code, id)) {
                request.setAttribute("error", "Mã rạp '" + code + "' đã tồn tại");
                showEditForm(request, response);
                return;
            }
            
            // Update cinema
            Cinema existingCinema = cinemaDAO.getCinemaById(id);
            if (existingCinema == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy rạp chiếu");
                return;
            }
            
            existingCinema.setCode(code);
            existingCinema.setName(name);
            existingCinema.setAddress(address);
            existingCinema.setDescription(description);
            existingCinema.setCapacity(capacity);
            existingCinema.setStatus(status);
            existingCinema.setPhone(phone);
            existingCinema.setTotalRooms(totalRooms);
            existingCinema.setOperatingHours(operatingHours);
            
            boolean success = cinemaDAO.updateCinema(existingCinema);
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/cinemas?success=update");
            } else {
                request.setAttribute("error", "Lỗi khi cập nhật rạp chiếu");
                showEditForm(request, response);
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Dữ liệu số không hợp lệ");
            showEditForm(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            showEditForm(request, response);
        }
    }
    
    // ASSIGN STAFF TO CINEMA
    private void assignStaffToCinema(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            int cinemaId = Integer.parseInt(request.getParameter("cinemaId"));
            int staffId = Integer.parseInt(request.getParameter("staffId"));
            String roleInCinema = request.getParameter("roleInCinema");
            boolean status = "on".equals(request.getParameter("status"));
            
            // Kiểm tra xem staff đã được assign đến rạp này chưa
            if (cinemaStaffDAO.isStaffAssignedToCinema(staffId, cinemaId)) {
                request.setAttribute("error", "Nhân viên này đã được phân công đến rạp chiếu");
                showAssignStaffForm(request, response);
                return;
            }
            
            // Tạo assignment
            CinemaStaff assignment = new CinemaStaff(cinemaId, staffId, roleInCinema, status);
            boolean success = cinemaStaffDAO.addCinemaStaffAssignment(assignment);
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/cinemas?action=manage-staff&id=" + cinemaId + "&success=assign");
            } else {
                request.setAttribute("error", "Lỗi khi phân công nhân viên");
                showAssignStaffForm(request, response);
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Dữ liệu số không hợp lệ");
            showAssignStaffForm(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            showAssignStaffForm(request, response);
        }
    }
    
    // UPDATE STAFF ASSIGNMENT
    private void updateStaffAssignment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            int assignmentId = Integer.parseInt(request.getParameter("assignmentId"));
            String roleInCinema = request.getParameter("roleInCinema");
            boolean status = "on".equals(request.getParameter("status"));
            
            CinemaStaff existingAssignment = cinemaStaffDAO.getAssignmentById(assignmentId);
            if (existingAssignment == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy phân công");
                return;
            }
            
            existingAssignment.setRoleInCinema(roleInCinema);
            existingAssignment.setStatus(status);
            
            boolean success = cinemaStaffDAO.updateCinemaStaffAssignment(existingAssignment);
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/cinemas?action=manage-staff&id=" + existingAssignment.getCinemaId() + "&success=update-assignment");
            } else {
                request.setAttribute("error", "Lỗi khi cập nhật phân công");
                showEditAssignmentForm(request, response);
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Dữ liệu số không hợp lệ");
            showEditAssignmentForm(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            showEditAssignmentForm(request, response);
        }
    }
    
    // DELETE CINEMA
    private void deleteCinema(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu ID");
            return;
        }
        
        try {
            int id = Integer.parseInt(idStr);
            boolean success = cinemaDAO.deleteCinema(id);
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/cinemas?success=delete");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/cinemas?error=delete");
            }
            
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID không hợp lệ");
        }
    }
    
    // REMOVE STAFF ASSIGNMENT
    private void removeStaffAssignment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String assignmentIdStr = request.getParameter("assignmentId");
        String cinemaIdStr = request.getParameter("cinemaId");
        
        if (assignmentIdStr == null || assignmentIdStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu ID phân công");
            return;
        }
        
        try {
            int assignmentId = Integer.parseInt(assignmentIdStr);
            boolean success = cinemaStaffDAO.deleteCinemaStaffAssignment(assignmentId);
            
            if (success) {
                if (cinemaIdStr != null && !cinemaIdStr.isEmpty()) {
                    response.sendRedirect(request.getContextPath() + "/admin/cinemas?action=manage-staff&id=" + cinemaIdStr + "&success=remove-staff");
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/cinemas?success=remove-staff");
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/cinemas?error=remove-staff");
            }
            
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID không hợp lệ");
        }
    }
}