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
import java.util.ArrayList;
import java.util.List;

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
        try {
            List<Voucher> vouchers = voucherDAO.getAllVouchers();
            request.setAttribute("vouchers", vouchers);
            
            HttpSession session = request.getSession();
            Users user = (Users) session.getAttribute("account");
            if (user != null) {
                String fullName = userProfileDAO.getFullNameByUserId(user.getId());
                request.setAttribute("adminFullName", fullName);
            }
            
            request.getRequestDispatcher("/views/admin/voucherManager.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/error.jsp");
        }
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    try {
        // Lấy danh sách phim để hiển thị trong dropdown
        List<VoucherDAO.MovieItem> movies = voucherDAO.getAllMovies();
        request.setAttribute("movies", movies);
        
        // Debug thông tin chi tiết
        System.out.println("=== DEBUG IN CONTROLLER ===");
        System.out.println("Number of movies loaded: " + (movies != null ? movies.size() : 0));
        
        if (movies != null && !movies.isEmpty()) {
            for (VoucherDAO.MovieItem movie : movies) {
                System.out.println("Movie in controller: " + movie.getId() + " - " + movie.getName() + " - " + movie.getCode());
            }
            
            // Kiểm tra EL expression
            System.out.println("Testing EL expression:");
            for (VoucherDAO.MovieItem movie : movies) {
                System.out.println("movie.id: " + movie.getId());
                System.out.println("movie.name: " + movie.getName());
                System.out.println("movie.code: " + movie.getCode());
            }
        } else {
            System.out.println("NO MOVIES FOUND! Check database connection and query.");
        }
        
        // Kiểm tra session và request attributes
        HttpSession session = request.getSession();
        Users user = (Users) session.getAttribute("account");
        if (user != null) {
            String fullName = userProfileDAO.getFullNameByUserId(user.getId());
            request.setAttribute("adminFullName", fullName);
            System.out.println("Admin: " + fullName);
        }
        
        request.getRequestDispatcher("/views/admin/voucherForm.jsp").forward(request, response);
    } catch (Exception e) {
        System.out.println("ERROR in showCreateForm: " + e.getMessage());
        e.printStackTrace();
        request.setAttribute("error", "Lỗi khi tải danh sách phim: " + e.getMessage());
        request.getRequestDispatcher("/views/admin/voucherForm.jsp").forward(request, response);
    }
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
            
            // Lấy danh sách phim được chọn
            String[] selectedMovieIds = request.getParameterValues("selectedMovies");
            List<Integer> movieIds = new ArrayList<>();
            if (selectedMovieIds != null) {
                for (String movieId : selectedMovieIds) {
                    try {
                        movieIds.add(Integer.parseInt(movieId));
                    } catch (NumberFormatException e) {
                        System.out.println("Invalid movie ID: " + movieId);
                    }
                }
            }
            
            // Kiểm tra code đã tồn tại chưa
            if (voucherDAO.isCodeExists(code)) {
                request.setAttribute("error", "Mã voucher đã tồn tại. Vui lòng chọn mã khác.");
                
                // Load lại danh sách phim
                List<VoucherDAO.MovieItem> movies = voucherDAO.getAllMovies();
                request.setAttribute("movies", movies);
                
                request.getRequestDispatcher("/views/admin/voucherForm.jsp").forward(request, response);
                return;
            }
            
            // Kiểm tra ngày hợp lệ
            if (endDate.before(startDate)) {
                request.setAttribute("error", "Ngày kết thúc phải sau ngày bắt đầu.");
                
                // Load lại danh sách phim
                List<VoucherDAO.MovieItem> movies = voucherDAO.getAllMovies();
                request.setAttribute("movies", movies);
                
                request.getRequestDispatcher("/views/admin/voucherForm.jsp").forward(request, response);
                return;
            }
            
            // Tạo voucher mới
            Voucher voucher = new Voucher(code, name, description, discountType, discountValue,
                                        minOrderAmount, maxDiscountAmount != null ? maxDiscountAmount : 0,
                                        quantity, startDate, endDate, user.getId());
            
            // Lưu vào database với danh sách phim
            if (voucherDAO.createVoucherWithMovies(voucher, movieIds)) {
                request.getSession().setAttribute("success", "Tạo voucher thành công!");
                response.sendRedirect(request.getContextPath() + "/admin/vouchers");
            } else {
                request.setAttribute("error", "Có lỗi xảy ra khi tạo voucher. Vui lòng thử lại.");
                
                // Load lại danh sách phim
                List<VoucherDAO.MovieItem> movies = voucherDAO.getAllMovies();
                request.setAttribute("movies", movies);
                
                request.getRequestDispatcher("/views/admin/voucherForm.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Dữ liệu không hợp lệ. Vui lòng kiểm tra lại: " + e.getMessage());
            
            // Load lại danh sách phim
            try {
                List<VoucherDAO.MovieItem> movies = voucherDAO.getAllMovies();
                request.setAttribute("movies", movies);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            
            request.getRequestDispatcher("/views/admin/voucherForm.jsp").forward(request, response);
        }
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Lấy ID từ URL
            String pathInfo = request.getPathInfo();
            int voucherId = Integer.parseInt(pathInfo.substring(1));
            
            // Lấy voucher từ database
            Voucher voucher = voucherDAO.getVoucherById(voucherId);
            
            if (voucher == null) {
                request.getSession().setAttribute("error", "Voucher không tồn tại.");
                response.sendRedirect(request.getContextPath() + "/admin/vouchers");
                return;
            }
            
            // Lấy danh sách phim đã chọn
            List<Integer> selectedMovieIds = voucherDAO.getMovieIdsByVoucherId(voucherId);
            request.setAttribute("selectedMovieIds", selectedMovieIds);
            
            // Lấy danh sách tất cả phim
            List<VoucherDAO.MovieItem> movies = voucherDAO.getAllMovies();
            request.setAttribute("movies", movies);
            
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
            request.getSession().setAttribute("error", "ID voucher không hợp lệ.");
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
                request.getSession().setAttribute("error", "Voucher không tồn tại.");
                response.sendRedirect(request.getContextPath() + "/admin/vouchers");
                return;
            }
            
            // Lấy danh sách phim áp dụng
            List<Integer> appliedMovieIds = voucherDAO.getMovieIdsByVoucherId(voucherId);
            List<VoucherDAO.MovieItem> appliedMovies = new ArrayList<>();
            for (Integer movieId : appliedMovieIds) {
                VoucherDAO.MovieItem movie = voucherDAO.getMovieById(movieId);
                if (movie != null) {
                    appliedMovies.add(movie);
                }
            }
            
            HttpSession session = request.getSession();
            Users user = (Users) session.getAttribute("account");
            if (user != null) {
                String fullName = userProfileDAO.getFullNameByUserId(user.getId());
                request.setAttribute("adminFullName", fullName);
            }
            
            request.setAttribute("voucher", voucher);
            request.setAttribute("appliedMovies", appliedMovies);
            request.setAttribute("voucherDAO", voucherDAO); // Thêm voucherDAO để sử dụng trong JSP
            request.getRequestDispatcher("/views/admin/voucherDetail.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "ID voucher không hợp lệ.");
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
            
            // Lấy danh sách phim được chọn
            String[] selectedMovieIds = request.getParameterValues("selectedMovies");
            List<Integer> movieIds = new ArrayList<>();
            if (selectedMovieIds != null) {
                for (String movieId : selectedMovieIds) {
                    try {
                        movieIds.add(Integer.parseInt(movieId));
                    } catch (NumberFormatException e) {
                        System.out.println("Invalid movie ID: " + movieId);
                    }
                }
            }
            
            // Chuyển đổi ngày tháng
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
            Timestamp startDate = new Timestamp(dateFormat.parse(request.getParameter("startDate")).getTime());
            Timestamp endDate = new Timestamp(dateFormat.parse(request.getParameter("endDate")).getTime());
            
            // Kiểm tra code đã tồn tại chưa (trừ voucher hiện tại)
            if (voucherDAO.isCodeExists(code, voucherId)) {
                request.setAttribute("error", "Mã voucher đã tồn tại. Vui lòng chọn mã khác.");
                
                // Load lại dữ liệu
                Voucher voucher = voucherDAO.getVoucherById(voucherId);
                List<VoucherDAO.MovieItem> movies = voucherDAO.getAllMovies();
                List<Integer> selectedMovieIdsList = voucherDAO.getMovieIdsByVoucherId(voucherId);
                
                request.setAttribute("voucher", voucher);
                request.setAttribute("movies", movies);
                request.setAttribute("selectedMovieIds", selectedMovieIdsList);
                
                request.getRequestDispatcher("/views/admin/voucherEditForm.jsp").forward(request, response);
                return;
            }
            
            // Kiểm tra ngày hợp lệ
            if (endDate.before(startDate)) {
                request.setAttribute("error", "Ngày kết thúc phải sau ngày bắt đầu.");
                
                // Load lại dữ liệu
                Voucher voucher = voucherDAO.getVoucherById(voucherId);
                List<VoucherDAO.MovieItem> movies = voucherDAO.getAllMovies();
                List<Integer> selectedMovieIdsList = voucherDAO.getMovieIdsByVoucherId(voucherId);
                
                request.setAttribute("voucher", voucher);
                request.setAttribute("movies", movies);
                request.setAttribute("selectedMovieIds", selectedMovieIdsList);
                
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
            
            // Cập nhật vào database với danh sách phim
            if (voucherDAO.updateVoucherWithMovies(voucher, movieIds)) {
                request.getSession().setAttribute("success", "Cập nhật voucher thành công!");
                response.sendRedirect(request.getContextPath() + "/admin/vouchers");
            } else {
                request.setAttribute("error", "Có lỗi xảy ra khi cập nhật voucher. Vui lòng thử lại.");
                
                // Load lại dữ liệu
                List<VoucherDAO.MovieItem> movies = voucherDAO.getAllMovies();
                request.setAttribute("movies", movies);
                request.setAttribute("selectedMovieIds", movieIds);
                request.setAttribute("voucher", voucher);
                
                request.getRequestDispatcher("/views/admin/voucherEditForm.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Dữ liệu không hợp lệ. Vui lòng kiểm tra lại: " + e.getMessage());
            
            try {
                // Load lại dữ liệu
                int voucherId = Integer.parseInt(request.getParameter("id"));
                Voucher voucher = voucherDAO.getVoucherById(voucherId);
                List<VoucherDAO.MovieItem> movies = voucherDAO.getAllMovies();
                List<Integer> selectedMovieIds = voucherDAO.getMovieIdsByVoucherId(voucherId);
                
                request.setAttribute("voucher", voucher);
                request.setAttribute("movies", movies);
                request.setAttribute("selectedMovieIds", selectedMovieIds);
                
                request.getRequestDispatcher("/views/admin/voucherEditForm.jsp").forward(request, response);
            } catch (Exception ex) {
                response.sendRedirect(request.getContextPath() + "/admin/vouchers");
            }
        }
    }
}