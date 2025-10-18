package controller;

import dal.SeatTypeDAO;
import model.SeatType;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "SeatTypeController", urlPatterns = {"/admin/seat-types"})
public class SeatTypeController extends HttpServlet {

    private SeatTypeDAO seatTypeDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        this.seatTypeDAO = new SeatTypeDAO();
    }

    // ===== HANDLE GET REQUESTS =====
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if (action == null) {
            action = "list"; // Default action
        }

        try {
            switch (action) {
                case "list":
                    showSeatTypeList(request, response);
                    break;
                case "add":
                    showAddForm(request, response);
                    break;
                case "edit":
                    showEditForm(request, response);
                    break;
                case "delete":
                    deleteSeatType(request, response);
                    break;
                default:
                    showSeatTypeList(request, response);
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
            if ("create".equals(action)) {
                createSeatType(request, response);
            } else if ("update".equals(action)) {
                updateSeatType(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Action không hợp lệ");
            }
        } catch (Exception e) {
            throw new ServletException("Lỗi xử lý request: " + e.getMessage(), e);
        }
    }

    // ===== PRIVATE METHODS =====
    // SHOW SEAT TYPE LIST
    private void showSeatTypeList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String searchKeyword = request.getParameter("search");
        List<SeatType> seatTypes;

        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            // Nếu có từ khóa tìm kiếm
            seatTypes = seatTypeDAO.searchSeatTypes(searchKeyword.trim());
            request.setAttribute("searchKeyword", searchKeyword.trim());
        } else {
            // Nếu không có từ khóa, lấy tất cả
            seatTypes = seatTypeDAO.getAllSeatTypes();
        }

        request.setAttribute("seatTypes", seatTypes);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/views/admin/seatTypeList.jsp");
        dispatcher.forward(request, response);
    }

    // SHOW ADD FORM
    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        RequestDispatcher dispatcher = request.getRequestDispatcher("/views/admin/seatTypeForm.jsp");
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
            SeatType seatType = seatTypeDAO.getSeatTypeById(id);

            if (seatType == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy loại ghế");
                return;
            }

            request.setAttribute("seatType", seatType);
            RequestDispatcher dispatcher = request.getRequestDispatcher("/views/admin/seatTypeForm.jsp");
            dispatcher.forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID không hợp lệ");
        }
    }

    // CREATE NEW SEAT TYPE
    private void createSeatType(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String code = request.getParameter("code");
            String name = request.getParameter("name");
            double surcharge = Double.parseDouble(request.getParameter("surcharge"));
            String color = request.getParameter("color");
            String description = request.getParameter("description");
            boolean status = "on".equals(request.getParameter("status"));

            // Validation
            if (code == null || code.trim().isEmpty()) {
                request.setAttribute("error", "Mã loại ghế không được để trống");
                showAddForm(request, response);
                return;
            }

            if (name == null || name.trim().isEmpty()) {
                request.setAttribute("error", "Tên loại ghế không được để trống");
                showAddForm(request, response);
                return;
            }

            // Check if code exists
            if (seatTypeDAO.isCodeExists(code)) {
                request.setAttribute("error", "Mã loại ghế '" + code + "' đã tồn tại");
                showAddForm(request, response);
                return;
            }

            // Create seat type
            SeatType seatType = new SeatType(code, name, surcharge, color, description, status);
            boolean success = seatTypeDAO.addSeatType(seatType);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/seat-types?success=create");
            } else {
                request.setAttribute("error", "Lỗi khi tạo loại ghế");
                showAddForm(request, response);
            }

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Phụ phí phải là số hợp lệ");
            showAddForm(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            showAddForm(request, response);
        }
    }

    // UPDATE SEAT TYPE
    private void updateSeatType(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String code = request.getParameter("code");
            String name = request.getParameter("name");
            double surcharge = Double.parseDouble(request.getParameter("surcharge"));
            String color = request.getParameter("color");
            String description = request.getParameter("description");
            boolean status = "on".equals(request.getParameter("status"));

            // Validation
            if (code == null || code.trim().isEmpty()) {
                request.setAttribute("error", "Mã loại ghế không được để trống");
                showEditForm(request, response);
                return;
            }

            if (name == null || name.trim().isEmpty()) {
                request.setAttribute("error", "Tên loại ghế không được để trống");
                showEditForm(request, response);
                return;
            }

            // Check if code exists (excluding current record)
            if (seatTypeDAO.isCodeExists(code, id)) {
                request.setAttribute("error", "Mã loại ghế '" + code + "' đã tồn tại");
                showEditForm(request, response);
                return;
            }

            // Update seat type
            SeatType existingSeatType = seatTypeDAO.getSeatTypeById(id);
            if (existingSeatType == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy loại ghế");
                return;
            }

            existingSeatType.setCode(code);
            existingSeatType.setName(name);
            existingSeatType.setSurcharge(surcharge);
            existingSeatType.setColor(color);
            existingSeatType.setDescription(description);
            existingSeatType.setStatus(status);

            boolean success = seatTypeDAO.updateSeatType(existingSeatType);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/seat-types?success=update");
            } else {
                request.setAttribute("error", "Lỗi khi cập nhật loại ghế");
                showEditForm(request, response);
            }

        } catch (NumberFormatException e) {
            request.setAttribute("error", "ID hoặc phụ phí không hợp lệ");
            showEditForm(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            showEditForm(request, response);
        }
    }

    // DELETE SEAT TYPE
    private void deleteSeatType(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu ID");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            boolean success = seatTypeDAO.deleteSeatType(id);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/seat-types?success=delete");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/seat-types?error=delete");
            }

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID không hợp lệ");
        }
    }
}
