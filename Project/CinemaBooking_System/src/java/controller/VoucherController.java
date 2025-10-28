/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
// controller/VoucherController.java
package controller;

import dal.VoucherDAO;
import model.Voucher;
import model.Users;
import java.io.IOException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import dal.UserProfileDAO;

@WebServlet(name = "VoucherController", urlPatterns = {
    "/admin/vouchers", 
    "/admin/vouchers/create", 
    "/admin/vouchers/detail/*",
    "/admin/vouchers/edit/*",
    "/admin/vouchers/update"
})
public class VoucherController extends HttpServlet {

    private VoucherDAO voucherDAO;
    private UserProfileDAO userProfileDAO; 
    @Override
    public void init() {
        voucherDAO = new VoucherDAO();
        userProfileDAO = new UserProfileDAO();
    }
    
    
   @Override
protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    
    HttpSession session = request.getSession();
    Users user = (Users) session.getAttribute("account");
    
    // Kiểm tra đăng nhập và quyền admin
    if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    String path = request.getServletPath();
    String pathInfo = request.getPathInfo();
    
    if (path.equals("/admin/vouchers")) {
        if (pathInfo == null) {
            showVoucherManager(request, response);
        }
    } else if (path.equals("/admin/vouchers/create")) {
        showCreateForm(request, response);
    } else if (path.equals("/admin/vouchers/detail") && pathInfo != null) {
        showVoucherDetail(request, response);
    } else if (path.equals("/admin/vouchers/edit") && pathInfo != null) {
        showEditForm(request, response);
    }
}

    @Override
protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    
    HttpSession session = request.getSession();
    Users user = (Users) session.getAttribute("account");
    
    if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    String path = request.getServletPath();
    
    if ("/admin/vouchers/create".equals(path)) {
        createVoucher(request, response, user);
    } else if ("/admin/vouchers/update".equals(path)) {
        updateVoucher(request, response, user);
    }
}

    private void showVoucherManager(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Lấy danh sách voucher để hiển thị
        request.setAttribute("vouchers", voucherDAO.getAllVouchers());
        
        // Lấy fullName từ UserProfile
        HttpSession session = request.getSession();
        Users user = (Users) session.getAttribute("account");
        if (user != null) {
            String fullName = userProfileDAO.getFullNameByUserId(user.getId());
            request.setAttribute("adminFullName", fullName);
        }
        
        request.getRequestDispatcher("/views/admin/voucherManager.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Lấy fullName từ UserProfile
        HttpSession session = request.getSession();
        Users user = (Users) session.getAttribute("account");
        if (user != null) {
            String fullName = userProfileDAO.getFullNameByUserId(user.getId());
            request.setAttribute("adminFullName", fullName);
        }
        
        request.getRequestDispatcher("/views/admin/voucherForm.jsp").forward(request, response);
    }
    
    

    private void createVoucher(HttpServletRequest request, HttpServletResponse response, Users user)
            throws ServletException, IOException {
        
        try {
            // Lấy dữ liệu từ form
            String code = request.getParameter("code");
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            int discountType = Integer.parseInt(request.getParameter("discountType"));
            double discountValue = Double.parseDouble(request.getParameter("discountValue"));
            double minOrderAmount = Double.parseDouble(request.getParameter("minOrderAmount"));
            
            // MaxDiscountAmount có thể null
            Double maxDiscountAmount = null;
            String maxDiscountAmountStr = request.getParameter("maxDiscountAmount");
            if (maxDiscountAmountStr != null && !maxDiscountAmountStr.trim().isEmpty()) {
                maxDiscountAmount = Double.parseDouble(maxDiscountAmountStr);
            }
            
            int quantity = Integer.parseInt(request.getParameter("quantity"));
            
            // Chuyển đổi ngày tháng
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
            Timestamp startDate = new Timestamp(dateFormat.parse(request.getParameter("startDate")).getTime());
            Timestamp endDate = new Timestamp(dateFormat.parse(request.getParameter("endDate")).getTime());
            
            // Kiểm tra code đã tồn tại chưa
            if (voucherDAO.isCodeExists(code)) {
                request.setAttribute("error", "Mã voucher đã tồn tại. Vui lòng chọn mã khác.");
                request.getRequestDispatcher("/views/admin/voucherForm.jsp").forward(request, response);
                return;
            }
            
            // Kiểm tra ngày hợp lệ
            if (endDate.before(startDate)) {
                request.setAttribute("error", "Ngày kết thúc phải sau ngày bắt đầu.");
                request.getRequestDispatcher("/views/admin/voucherForm.jsp").forward(request, response);
                return;
            }
            
            // Tạo voucher mới
            Voucher voucher = new Voucher(code, name, description, discountType, discountValue,
                                        minOrderAmount, maxDiscountAmount != null ? maxDiscountAmount : 0,
                                        quantity, startDate, endDate, user.getId());
            
            // Lưu vào database
            if (voucherDAO.createVoucher(voucher)) {
                request.setAttribute("success", "Tạo voucher thành công!");
                response.sendRedirect(request.getContextPath() + "/admin/vouchers");
            } else {
                request.setAttribute("error", "Có lỗi xảy ra khi tạo voucher. Vui lòng thử lại.");
                request.getRequestDispatcher("/views/admin/voucherForm.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.");
            request.getRequestDispatcher("/views/admin/voucherForm.jsp").forward(request, response);
        }
    }
    
     private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Lấy ID từ URL
             String pathInfo = request.getPathInfo();
        int voucherId = Integer.parseInt(pathInfo.substring(1)); // /edit/123 -> 123
            
            // Lấy voucher từ database
            Voucher voucher = voucherDAO.getVoucherById(voucherId);
            
            if (voucher == null) {
                request.setAttribute("error", "Voucher không tồn tại.");
                response.sendRedirect(request.getContextPath() + "/admin/vouchers");
                return;
            }
            
            // Lấy fullName từ UserProfile
            HttpSession session = request.getSession();
            Users user = (Users) session.getAttribute("account");
            if (user != null) {
                String fullName = userProfileDAO.getFullNameByUserId(user.getId());
                request.setAttribute("adminFullName", fullName);
            }
            
            request.setAttribute("voucher", voucher);
            request.getRequestDispatcher("/views/admin/voucherEditForm.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "ID voucher không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/admin/vouchers");
        }
    }

    private void showVoucherDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Lấy ID từ URL
             String pathInfo = request.getPathInfo();
        int voucherId = Integer.parseInt(pathInfo.substring(1));
            
            // Lấy voucher từ database
            Voucher voucher = voucherDAO.getVoucherById(voucherId);
            
            if (voucher == null) {
                request.setAttribute("error", "Voucher không tồn tại.");
                response.sendRedirect(request.getContextPath() + "/admin/vouchers");
                return;
            }
            
            // Lấy fullName từ UserProfile
            HttpSession session = request.getSession();
            Users user = (Users) session.getAttribute("account");
            if (user != null) {
                String fullName = userProfileDAO.getFullNameByUserId(user.getId());
                request.setAttribute("adminFullName", fullName);
            }
            
            request.setAttribute("voucher", voucher);
            request.getRequestDispatcher("/views/admin/voucherDetail.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "ID voucher không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/admin/vouchers");
        }
    }

    private void updateVoucher(HttpServletRequest request, HttpServletResponse response, Users user)
            throws ServletException, IOException {
        
        try {
            // Lấy dữ liệu từ form
            int voucherId = Integer.parseInt(request.getParameter("id"));
            String code = request.getParameter("code");
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            int discountType = Integer.parseInt(request.getParameter("discountType"));
            double discountValue = Double.parseDouble(request.getParameter("discountValue"));
            double minOrderAmount = Double.parseDouble(request.getParameter("minOrderAmount"));
            
            // MaxDiscountAmount có thể null
            Double maxDiscountAmount = null;
            String maxDiscountAmountStr = request.getParameter("maxDiscountAmount");
            if (maxDiscountAmountStr != null && !maxDiscountAmountStr.trim().isEmpty()) {
                maxDiscountAmount = Double.parseDouble(maxDiscountAmountStr);
            }
            
            int quantity = Integer.parseInt(request.getParameter("quantity"));
            boolean isActive = request.getParameter("isActive") != null;
            
            // Chuyển đổi ngày tháng
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
            Timestamp startDate = new Timestamp(dateFormat.parse(request.getParameter("startDate")).getTime());
            Timestamp endDate = new Timestamp(dateFormat.parse(request.getParameter("endDate")).getTime());
            
            // Kiểm tra code đã tồn tại chưa (trừ voucher hiện tại)
            if (voucherDAO.isCodeExists(code, voucherId)) {
                request.setAttribute("error", "Mã voucher đã tồn tại. Vui lòng chọn mã khác.");
                
                // Lấy lại thông tin voucher để hiển thị form
                Voucher voucher = voucherDAO.getVoucherById(voucherId);
                request.setAttribute("voucher", voucher);
                request.getRequestDispatcher("/views/admin/voucherEditForm.jsp").forward(request, response);
                return;
            }
            
            // Kiểm tra ngày hợp lệ
            if (endDate.before(startDate)) {
                request.setAttribute("error", "Ngày kết thúc phải sau ngày bắt đầu.");
                
                // Lấy lại thông tin voucher để hiển thị form
                Voucher voucher = voucherDAO.getVoucherById(voucherId);
                request.setAttribute("voucher", voucher);
                request.getRequestDispatcher("/views/admin/voucherEditForm.jsp").forward(request, response);
                return;
            }
            
            // Tạo voucher object để cập nhật
            Voucher voucher = new Voucher();
            voucher.setId(voucherId);
            voucher.setCode(code);
            voucher.setName(name);
            voucher.setDescription(description);
            voucher.setDiscountType(discountType);
            voucher.setDiscountValue(discountValue);
            voucher.setMinOrderAmount(minOrderAmount);
            voucher.setMaxDiscountAmount(maxDiscountAmount != null ? maxDiscountAmount : 0);
            voucher.setQuantity(quantity);
            voucher.setStartDate(startDate);
            voucher.setEndDate(endDate);
            voucher.setIsActive(isActive);
            voucher.setUpdatedBy(user.getId());
            
            // Cập nhật vào database
            if (voucherDAO.updateVoucher(voucher)) {
                request.setAttribute("success", "Cập nhật voucher thành công!");
                response.sendRedirect(request.getContextPath() + "/admin/vouchers");
            } else {
                request.setAttribute("error", "Có lỗi xảy ra khi cập nhật voucher. Vui lòng thử lại.");
                
                // Lấy lại thông tin voucher để hiển thị form
                request.setAttribute("voucher", voucher);
                request.getRequestDispatcher("/views/admin/voucherEditForm.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.");
            
            try {
                // Lấy lại thông tin voucher để hiển thị form
                int voucherId = Integer.parseInt(request.getParameter("id"));
                Voucher voucher = voucherDAO.getVoucherById(voucherId);
                request.setAttribute("voucher", voucher);
                request.getRequestDispatcher("/views/admin/voucherEditForm.jsp").forward(request, response);
            } catch (Exception ex) {
                response.sendRedirect(request.getContextPath() + "/admin/vouchers");
            }
        }
    }
    
    
}
