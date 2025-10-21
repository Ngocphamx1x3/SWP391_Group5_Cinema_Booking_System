package controller;

import dal.StaffDAO;
import dal.CinemaDAO;
import dal.CinemaStaffDAO;
import model.Staff;
import model.Cinema;
import model.CinemaStaff;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "ManageStaffController", urlPatterns = {"/admin/staff"})
public class ManageStaffController extends HttpServlet {

    private StaffDAO staffDAO;
    private CinemaDAO cinemaDAO;
    private CinemaStaffDAO cinemaStaffDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            this.staffDAO = new StaffDAO();
            this.cinemaDAO = new CinemaDAO();
            this.cinemaStaffDAO = new CinemaStaffDAO();
            System.out.println("✅ ManageStaffController initialized successfully");
        } catch (Exception e) {
            System.err.println("❌ Error initializing ManageStaffController: " + e.getMessage());
            e.printStackTrace();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("=== 🚀 ManageStaffController doGet START ===");
        System.out.println("📝 Request URL: " + request.getRequestURL());
        System.out.println("🔍 Query String: " + request.getQueryString());
        
        String action = request.getParameter("action");
        if (action == null) action = "list";
        
        System.out.println("🎯 Action: " + action);
        
        try {
            switch (action) {
                case "list":
                    showStaffList(request, response);
                    break;
                case "add":
                    showAddForm(request, response);
                    break;
                case "edit":
                    showEditForm(request, response);
                    break;
                case "view":
                    showViewForm(request, response);
                    break;
                case "toggle-status":
                    toggleStaffStatus(request, response);
                    break;
                case "delete":
                    deleteStaff(request, response);
                    break;
                case "assign-cinema":
                    showAssignCinemaForm(request, response);
                    break;
                default:
                    showStaffList(request, response);
                    break;
            }
        } catch (Exception e) {
            System.err.println("❌ Error in doGet: " + e.getMessage());
            e.printStackTrace();
            throw new ServletException("Lỗi xử lý request: " + e.getMessage(), e);
        }
        
        System.out.println("=== ✅ ManageStaffController doGet END ===\n");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("=== 🚀 ManageStaffController doPost START ===");
        System.out.println("📝 Request URL: " + request.getRequestURL());
        
        String action = request.getParameter("action");
        System.out.println("🎯 Action: " + action);
        
        try {
            switch (action) {
                case "create":
                    createStaff(request, response);
                    break;
                case "update":
                    updateStaff(request, response);
                    break;
                case "assign-cinema":
                    assignCinemaToStaff(request, response);
                    break;
                case "update-assignment":
                    updateStaffAssignment(request, response);
                    break;
                default:
                    System.err.println("❌ Invalid action: " + action);
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Action không hợp lệ");
            }
        } catch (Exception e) {
            System.err.println("❌ Error in doPost: " + e.getMessage());
            e.printStackTrace();
            throw new ServletException("Lỗi xử lý request: " + e.getMessage(), e);
        }
        
        System.out.println("=== ✅ ManageStaffController doPost END ===\n");
    }

    // ===== PRIVATE METHODS =====

    private void showStaffList(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    
    String searchKeyword = request.getParameter("search");
    List<Staff> staffList;
    
    if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
        staffList = staffDAO.searchStaff(searchKeyword.trim());
        request.setAttribute("searchKeyword", searchKeyword.trim());
    } else {
        staffList = staffDAO.getAllStaffWithAssignments();
    }
    
    // DEBUG
    System.out.println("=== 🚀 DEBUG: Staff List Data ===");
    System.out.println("Total staff: " + staffList.size());
    
    request.setAttribute("staffList", staffList);
    
    RequestDispatcher dispatcher = request.getRequestDispatcher("/views/admin/staffManager.jsp");
    dispatcher.forward(request, response);
}

    // SHOW ADD FORM
    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("=== ➕ showAddForm START ===");
        RequestDispatcher dispatcher = request.getRequestDispatcher("/views/admin/staffForm.jsp");
        dispatcher.forward(request, response);
        System.out.println("=== ✅ showAddForm END ===\n");
    }

    // SHOW VIEW FORM
    private void showViewForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("=== 👁️ showViewForm START ===");
        
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu ID");
            return;
        }
        
        try {
            int id = Integer.parseInt(idStr);
            Staff staff = staffDAO.getStaffById(id);
            
            if (staff == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy nhân viên");
                return;
            }
            
            request.setAttribute("staff", staff);
            request.setAttribute("viewMode", true);
            RequestDispatcher dispatcher = request.getRequestDispatcher("/views/admin/staffForm.jsp");
            dispatcher.forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID không hợp lệ");
        }
        
        System.out.println("=== ✅ showViewForm END ===\n");
    }

    // SHOW EDIT FORM
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("=== ✏️ showEditForm START ===");
        
        String idStr = request.getParameter("id");
        System.out.println("🆔 Staff ID to edit: " + idStr);
        
        if (idStr == null || idStr.isEmpty()) {
            System.err.println("❌ Missing ID parameter");
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu ID");
            return;
        }
        
        try {
            int id = Integer.parseInt(idStr);
            System.out.println("🔍 Looking for staff with ID: " + id);
            
            Staff staff = staffDAO.getStaffById(id);
            
            if (staff == null) {
                System.err.println("❌ Staff not found with ID: " + id);
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy nhân viên");
                return;
            }
            
            System.out.println("✅ Found staff: " + staff.getUsername());
            request.setAttribute("staff", staff);
            
            RequestDispatcher dispatcher = request.getRequestDispatcher("/views/admin/staffForm.jsp");
            dispatcher.forward(request, response);
            
        } catch (NumberFormatException e) {
            System.err.println("❌ Invalid ID format: " + idStr);
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID không hợp lệ");
        } catch (Exception e) {
            System.err.println("❌ Error in showEditForm: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
        
        System.out.println("=== ✅ showEditForm END ===\n");
    }
    
    // CREATE STAFF
    private void createStaff(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("=== 🆕 createStaff START ===");
        
        try {
            String email = request.getParameter("email");
            String phoneNumber = request.getParameter("phoneNumber");
            String username = request.getParameter("username");
            String role = request.getParameter("role");
            boolean status = "on".equals(request.getParameter("status"));
            
            System.out.println("📝 Creating staff: " + email + " - " + username);
            
            // Validation
            if (email == null || email.trim().isEmpty()) {
                request.setAttribute("error", "Email không được để trống");
                showAddForm(request, response);
                return;
            }
            
            if (username == null || username.trim().isEmpty()) {
                request.setAttribute("error", "Tên đăng nhập không được để trống");
                showAddForm(request, response);
                return;
            }
            
            if (staffDAO.isEmailExists(email)) {
                request.setAttribute("error", "Email '" + email + "' đã tồn tại");
                showAddForm(request, response);
                return;
            }
            
            // Create staff object
            Staff staff = new Staff(email, phoneNumber, username, role, status);
            boolean success = staffDAO.addStaff(staff);
            
            if (success) {
                System.out.println("✅ Staff created successfully");
                response.sendRedirect(request.getContextPath() + "/admin/staff?success=create");
            } else {
                request.setAttribute("error", "Lỗi khi tạo nhân viên");
                showAddForm(request, response);
            }
            
        } catch (Exception e) {
            System.err.println("❌ Error in createStaff: " + e.getMessage());
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            showAddForm(request, response);
        }
        
        System.out.println("=== ✅ createStaff END ===\n");
    }

    // UPDATE STAFF
    private void updateStaff(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("=== ✏️ updateStaff START ===");
        
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String email = request.getParameter("email");
            String phoneNumber = request.getParameter("phoneNumber");
            String username = request.getParameter("username");
            String role = request.getParameter("role");
            boolean status = "on".equals(request.getParameter("status"));
            
            System.out.println("📝 Updating staff ID: " + id);
            
            // Validation
            if (email == null || email.trim().isEmpty()) {
                request.setAttribute("error", "Email không được để trống");
                showEditForm(request, response);
                return;
            }
            
            if (username == null || username.trim().isEmpty()) {
                request.setAttribute("error", "Tên đăng nhập không được để trống");
                showEditForm(request, response);
                return;
            }
            
            if (staffDAO.isEmailExists(email, id)) {
                request.setAttribute("error", "Email '" + email + "' đã tồn tại");
                showEditForm(request, response);
                return;
            }
            
            // Get existing staff and update
            Staff existingStaff = staffDAO.getStaffById(id);
            if (existingStaff == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy nhân viên");
                return;
            }
            
            existingStaff.setEmail(email);
            existingStaff.setPhoneNumber(phoneNumber);
            existingStaff.setUsername(username);
            existingStaff.setRole(role);
            existingStaff.setStatus(status);
            
            boolean success = staffDAO.updateStaff(existingStaff);
            
            if (success) {
                System.out.println("✅ Staff updated successfully");
                response.sendRedirect(request.getContextPath() + "/admin/staff?success=update");
            } else {
                request.setAttribute("error", "Lỗi khi cập nhật nhân viên");
                showEditForm(request, response);
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Dữ liệu số không hợp lệ");
            showEditForm(request, response);
        } catch (Exception e) {
            System.err.println("❌ Error in updateStaff: " + e.getMessage());
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            showEditForm(request, response);
        }
        
        System.out.println("=== ✅ updateStaff END ===\n");
    }

    // DELETE STAFF
    private void deleteStaff(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("=== 🗑️ deleteStaff START ===");
        
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu ID");
            return;
        }
        
        try {
            int id = Integer.parseInt(idStr);
            System.out.println("🗑️ Deleting staff ID: " + id);
            
            boolean success = staffDAO.deleteStaff(id);
            
            if (success) {
                System.out.println("✅ Staff deleted successfully");
                response.sendRedirect(request.getContextPath() + "/admin/staff?success=delete");
            } else {
                System.err.println("❌ Failed to delete staff");
                response.sendRedirect(request.getContextPath() + "/admin/staff?error=delete");
            }
            
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID không hợp lệ");
        }
        
        System.out.println("=== ✅ deleteStaff END ===\n");
    }
    
    private void toggleStaffStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("=== 🔄 toggleStaffStatus START ===");
        
        String idStr = request.getParameter("id");
        String statusStr = request.getParameter("status");
        
        System.out.println("🆔 Staff ID: " + idStr);
        System.out.println("📊 New Status: " + statusStr);
        
        if (idStr == null || idStr.isEmpty() || statusStr == null || statusStr.isEmpty()) {
            System.err.println("❌ Missing parameters");
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu thông tin");
            return;
        }
        
        try {
            int id = Integer.parseInt(idStr);
            boolean newStatus = "true".equals(statusStr);
            
            System.out.println("🔄 Updating staff " + id + " to status: " + newStatus);
            
            boolean success = staffDAO.updateStaffStatus(id, newStatus);
            
            if (success) {
                System.out.println("✅ Status updated successfully");
                response.sendRedirect(request.getContextPath() + "/admin/staff?success=status");
            } else {
                System.err.println("❌ Failed to update status");
                response.sendRedirect(request.getContextPath() + "/admin/staff?error=status");
            }
            
        } catch (NumberFormatException e) {
            System.err.println("❌ Invalid ID format: " + idStr);
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID không hợp lệ");
        } catch (Exception e) {
            System.err.println("❌ Error in toggleStaffStatus: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
        
        System.out.println("=== ✅ toggleStaffStatus END ===\n");
    }
    
    private void showAssignCinemaForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("=== 🏢 showAssignCinemaForm START ===");
        
        String staffIdStr = request.getParameter("staffId");
        System.out.println("👤 Staff ID to assign: " + staffIdStr);
        
        if (staffIdStr == null || staffIdStr.isEmpty()) {
            System.err.println("❌ Missing staffId parameter");
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu ID nhân viên");
            return;
        }
        
        try {
            int staffId = Integer.parseInt(staffIdStr);
            System.out.println("🔍 Getting staff details for ID: " + staffId);
            
            Staff staff = staffDAO.getStaffById(staffId);
            
            if (staff == null) {
                System.err.println("❌ Staff not found with ID: " + staffId);
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy nhân viên");
                return;
            }
            
            System.out.println("✅ Found staff: " + staff.getUsername());
            
            // Lấy danh sách rạp có sẵn
            System.out.println("🎬 Getting available cinemas");
            List<Cinema> availableCinemas = cinemaDAO.getActiveCinemas();
            System.out.println("📊 Available cinemas: " + availableCinemas.size());
            
            // Lấy assignment hiện tại nếu có
            CinemaStaff currentAssignment = null;
            if (staff.hasCinemaAssignment()) {
                System.out.println("🔍 Getting current assignment for staff");
                List<CinemaStaff> assignments = cinemaStaffDAO.getAssignmentsByCinemaId(staff.getCurrentCinemaId());
                for (CinemaStaff assignment : assignments) {
                    if (assignment.getStaffId() == staffId && assignment.isStatus()) {
                        currentAssignment = assignment;
                        System.out.println("✅ Found current assignment");
                        break;
                    }
                }
            } else {
                System.out.println("ℹ️  Staff has no current cinema assignment");
            }
            
            request.setAttribute("staff", staff);
            request.setAttribute("availableCinemas", availableCinemas);
            request.setAttribute("currentAssignment", currentAssignment);
            
            System.out.println("📤 Forwarding to assignCinemaForm.jsp");
            RequestDispatcher dispatcher = request.getRequestDispatcher("/views/admin/assignCinemaForm.jsp");
            dispatcher.forward(request, response);
            
        } catch (NumberFormatException e) {
            System.err.println("❌ Invalid staffId format: " + staffIdStr);
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID không hợp lệ");
        } catch (Exception e) {
            System.err.println("❌ Error in showAssignCinemaForm: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
        
        System.out.println("=== ✅ showAssignCinemaForm END ===\n");
    }
    
    private void assignCinemaToStaff(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("=== ➕ assignCinemaToStaff START ===");
        
        try {
            int staffId = Integer.parseInt(request.getParameter("staffId"));
            int cinemaId = Integer.parseInt(request.getParameter("cinemaId"));
            String roleInCinema = request.getParameter("roleInCinema");
            boolean status = "on".equals(request.getParameter("status"));
            
            System.out.println("👤 Staff ID: " + staffId);
            System.out.println("🎬 Cinema ID: " + cinemaId);
            System.out.println("💼 Role: " + roleInCinema);
            System.out.println("📊 Status: " + status);
            
            // Kiểm tra xem staff đã được assign đến rạp này chưa
            System.out.println("🔍 Checking if staff is already assigned to cinema");
            boolean alreadyAssigned = cinemaStaffDAO.isStaffAssignedToCinema(staffId, cinemaId);
            
            if (alreadyAssigned) {
                System.err.println("❌ Staff already assigned to this cinema");
                request.setAttribute("error", "Nhân viên này đã được phân công đến rạp chiếu này");
                showAssignCinemaForm(request, response);
                return;
            }
            
            System.out.println("✅ Staff not assigned, creating new assignment");
            
            // Tạo assignment
            CinemaStaff assignment = new CinemaStaff(cinemaId, staffId, roleInCinema, status);
            boolean success = cinemaStaffDAO.addCinemaStaffAssignment(assignment);
            
            if (success) {
                System.out.println("✅ Assignment created successfully");
                response.sendRedirect(request.getContextPath() + "/admin/staff?success=assign");
            } else {
                System.err.println("❌ Failed to create assignment");
                request.setAttribute("error", "Lỗi khi phân công rạp chiếu");
                showAssignCinemaForm(request, response);
            }
            
        } catch (NumberFormatException e) {
            System.err.println("❌ Invalid number format in parameters");
            request.setAttribute("error", "Dữ liệu số không hợp lệ");
            showAssignCinemaForm(request, response);
        } catch (Exception e) {
            System.err.println("❌ Error in assignCinemaToStaff: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            showAssignCinemaForm(request, response);
        }
        
        System.out.println("=== ✅ assignCinemaToStaff END ===\n");
    }

    private void updateStaffAssignment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("=== 🔄 updateStaffAssignment START ===");
        
        try {
            int assignmentId = Integer.parseInt(request.getParameter("assignmentId"));
            String roleInCinema = request.getParameter("roleInCinema");
            boolean status = "on".equals(request.getParameter("status"));
            
            System.out.println("📝 Assignment ID: " + assignmentId);
            System.out.println("💼 New Role: " + roleInCinema);
            System.out.println("📊 New Status: " + status);
            
            CinemaStaff existingAssignment = cinemaStaffDAO.getAssignmentById(assignmentId);
            if (existingAssignment == null) {
                System.err.println("❌ Assignment not found with ID: " + assignmentId);
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy phân công");
                return;
            }
            
            System.out.println("✅ Found assignment, updating...");
            
            existingAssignment.setRoleInCinema(roleInCinema);
            existingAssignment.setStatus(status);
            
            boolean success = cinemaStaffDAO.updateCinemaStaffAssignment(existingAssignment);
            
            if (success) {
                System.out.println("✅ Assignment updated successfully");
                response.sendRedirect(request.getContextPath() + "/admin/staff?success=update-assignment");
            } else {
                System.err.println("❌ Failed to update assignment");
                request.setAttribute("error", "Lỗi khi cập nhật phân công");
                showAssignCinemaForm(request, response);
            }
            
        } catch (NumberFormatException e) {
            System.err.println("❌ Invalid number format in parameters");
            request.setAttribute("error", "Dữ liệu số không hợp lệ");
            showAssignCinemaForm(request, response);
        } catch (Exception e) {
            System.err.println("❌ Error in updateStaffAssignment: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            showAssignCinemaForm(request, response);
        }
        
        System.out.println("=== ✅ updateStaffAssignment END ===\n");
    }
}