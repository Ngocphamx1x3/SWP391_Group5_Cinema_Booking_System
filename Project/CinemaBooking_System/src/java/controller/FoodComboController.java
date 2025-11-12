package controller;

import dal.FoodComboDAO;
import dal.FoodItemDAO;
import model.FoodCombo;
import model.FoodItem;
import model.ComboItem;
import model.Users;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "FoodComboController", urlPatterns = {"/staff/food-combos"})
@MultipartConfig(
    maxFileSize = 1024 * 1024 * 5, // 5MB
    maxRequestSize = 1024 * 1024 * 10 // 10MB
)
public class FoodComboController extends HttpServlet {

    private FoodComboDAO foodComboDAO;
    private FoodItemDAO foodItemDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        this.foodComboDAO = new FoodComboDAO();
        this.foodItemDAO = new FoodItemDAO();
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

        // Kiểm tra quyền truy cập (staff hoặc admin)
        if (!"staff".equalsIgnoreCase(user.getRole()) && !"admin".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        try {
            switch (action) {
                case "list":
                    showFoodComboList(request, response, user);
                    break;
                case "add":
                    showAddForm(request, response, user);
                    break;
                case "edit":
                    showEditForm(request, response, user);
                    break;
                case "detail":
                    showDetail(request, response, user);
                    break;
                case "delete":
                    deleteFoodCombo(request, response, user);
                    break;
                case "toggle":
                    toggleFoodComboStatus(request, response, user);
                    break;
                default:
                    showFoodComboList(request, response, user);
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

        // Kiểm tra quyền truy cập
        if (!"staff".equalsIgnoreCase(user.getRole()) && !"admin".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        try {
            switch (action) {
                case "create":
                    createFoodCombo(request, response, user);
                    break;
                case "update":
                    updateFoodCombo(request, response, user);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Action không hợp lệ");
            }
        } catch (Exception e) {
            throw new ServletException("Lỗi xử lý request: " + e.getMessage(), e);
        }
    }

    // ===== PRIVATE METHODS =====

    // SHOW FOOD COMBO LIST
    private void showFoodComboList(HttpServletRequest request, HttpServletResponse response, Users user)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");
        List<FoodCombo> foodCombos;

        // Nếu có search keyword
        if (keyword != null && !keyword.trim().isEmpty()) {
            foodCombos = foodComboDAO.searchFoodCombos(keyword);
            request.setAttribute("searchKeyword", keyword.trim());
        } else {
            // Không có search, hiển thị tất cả
            foodCombos = foodComboDAO.getAllFoodCombos();
        }

        request.setAttribute("foodCombos", foodCombos);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/views/staff/foodComboList.jsp");
        dispatcher.forward(request, response);
    }

    // SHOW ADD FORM
    private void showAddForm(HttpServletRequest request, HttpServletResponse response, Users user)
            throws ServletException, IOException {

        // Load all active food items for selection
        List<FoodItem> foodItems = foodItemDAO.getActiveFoodItems();
        request.setAttribute("foodItems", foodItems);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/views/staff/foodComboForm.jsp");
        dispatcher.forward(request, response);
    }

    // SHOW EDIT FORM
    private void showEditForm(HttpServletRequest request, HttpServletResponse response, Users user)
            throws ServletException, IOException {

        // Check if foodCombo is already in request (from error handling)
        FoodCombo combo = (FoodCombo) request.getAttribute("foodCombo");
        
        // If not, get ID from parameter and load from database
        if (combo == null) {
            String idStr = request.getParameter("id");
            if (idStr == null || idStr.isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu ID");
                return;
            }

            try {
                int id = Integer.parseInt(idStr);
                combo = foodComboDAO.getFoodComboById(id);

                if (combo == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy combo");
                    return;
                }
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID không hợp lệ");
                return;
            }
        }

        // Always load fresh food items list for selection
        List<FoodItem> foodItems = foodItemDAO.getActiveFoodItems();
        request.setAttribute("foodItems", foodItems);
        request.setAttribute("foodCombo", combo);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/views/staff/foodComboForm.jsp");
        dispatcher.forward(request, response);
    }

    // SHOW DETAIL
    private void showDetail(HttpServletRequest request, HttpServletResponse response, Users user)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu ID");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            FoodCombo combo = foodComboDAO.getFoodComboById(id);

            if (combo == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy combo");
                return;
            }

            request.setAttribute("foodCombo", combo);

            RequestDispatcher dispatcher = request.getRequestDispatcher("/views/staff/foodComboDetail.jsp");
            dispatcher.forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID không hợp lệ");
        }
    }

    // CREATE FOOD COMBO
    private void createFoodCombo(HttpServletRequest request, HttpServletResponse response, Users user)
            throws ServletException, IOException {

        try {
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            String priceStr = request.getParameter("price");
            String statusStr = request.getParameter("status");
            
            // Validation
            if (name == null || name.trim().isEmpty()) {
                request.setAttribute("error", "Tên combo không được để trống");
                showAddForm(request, response, user);
                return;
            }

            double price;
            try {
                price = Double.parseDouble(priceStr);
                if (price <= 0) {
                    throw new NumberFormatException();
                }
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Giá phải là số hợp lệ và lớn hơn 0. Vui lòng chọn ít nhất một món và kiểm tra lại giảm giá.");
                showAddForm(request, response, user);
                return;
            }

            boolean status = "on".equals(statusStr);

            // Xử lý hình ảnh: servlet đã có @MultipartConfig nên có thể xử lý trực tiếp
            String imageFileName = null;
            try {
                Part imagePart = request.getPart("imageFile");
                if (imagePart != null && imagePart.getSize() > 0) {
                    imageFileName = handleImageUpload(request);
                }
            } catch (Exception e) {
                // Nếu lỗi validation file, báo lỗi và hiển thị lại form
                if (e instanceof ServletException && e.getMessage().contains("Chỉ cho phép")) {
                    request.setAttribute("error", e.getMessage());
                    // Lưu lại dữ liệu đã nhập
                    FoodCombo previousCombo = new FoodCombo();
                    previousCombo.setName(name != null ? name.trim() : "");
                    previousCombo.setDescription(description != null ? description.trim() : null);
                    previousCombo.setPrice(price);
                    request.setAttribute("previousData", previousCombo);
                    showAddForm(request, response, user);
                    return;
                }
                // Không có file upload hoặc lỗi khác, tiếp tục xử lý
            }
            
            // Nếu không có file upload, lấy từ text input
            if (imageFileName == null) {
                String imageParam = request.getParameter("image");
                if (imageParam != null && !imageParam.trim().isEmpty()) {
                    imageFileName = imageParam.trim();
                }
            }

            // Parse combo items trước để validate
            List<ComboItem> items = parseComboItems(request, 0); // 0 vì chưa có comboID
            
            // Validate: combo phải có ít nhất một món
            if (items.isEmpty()) {
                request.setAttribute("error", "Combo phải có ít nhất một món!");
                // Lưu lại dữ liệu đã nhập
                FoodCombo previousCombo = new FoodCombo();
                previousCombo.setName(name != null ? name.trim() : "");
                previousCombo.setDescription(description != null ? description.trim() : null);
                previousCombo.setPrice(price);
                previousCombo.setStatus(status);
                previousCombo.setImage(imageFileName);
                request.setAttribute("previousData", previousCombo);
                showAddForm(request, response, user);
                return;
            }

            // Tạo FoodCombo object
            FoodCombo combo = new FoodCombo();
            combo.setName(name.trim());
            combo.setDescription(description != null ? description.trim() : null);
            combo.setPrice(price);
            combo.setImage(imageFileName);
            combo.setCreatedBy(user.getId());
            combo.setStatus(status);

            // Save combo and get generated ID
            int comboID = foodComboDAO.addFoodCombo(combo);
            
            if (comboID > 0) {
                // Set comboID cho các items và save
                for (ComboItem item : items) {
                    item.setComboID(comboID);
                }
                foodComboDAO.addComboItems(comboID, items);

                response.sendRedirect(request.getContextPath() + "/staff/food-combos?success=create");
            } else {
                request.setAttribute("error", "Lỗi khi tạo combo");
                // Lưu lại dữ liệu đã nhập
                request.setAttribute("previousData", combo);
                showAddForm(request, response, user);
            }

        } catch (Exception e) {
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            showAddForm(request, response, user);
        }
    }

    // UPDATE FOOD COMBO
    private void updateFoodCombo(HttpServletRequest request, HttpServletResponse response, Users user)
            throws ServletException, IOException {

        try {
            String idStr = request.getParameter("id");
            if (idStr == null || idStr.isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu ID");
                return;
            }

            int id = Integer.parseInt(idStr);
            FoodCombo existingCombo = foodComboDAO.getFoodComboById(id);

            if (existingCombo == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy combo");
                return;
            }

            String name = request.getParameter("name");
            String description = request.getParameter("description");
            String priceStr = request.getParameter("price");
            String statusStr = request.getParameter("status");

            // Validation
            if (name == null || name.trim().isEmpty()) {
                request.setAttribute("error", "Tên combo không được để trống");
                request.setAttribute("foodCombo", existingCombo);
                showEditForm(request, response, user);
                return;
            }

            double price;
            try {
                price = Double.parseDouble(priceStr);
                if (price <= 0) {
                    throw new NumberFormatException();
                }
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Giá phải là số hợp lệ và lớn hơn 0. Vui lòng chọn ít nhất một món và kiểm tra lại giảm giá.");
                request.setAttribute("foodCombo", existingCombo);
                showEditForm(request, response, user);
                return;
            }

            boolean status = "on".equals(statusStr);

            // Parse combo items trước để validate
            List<ComboItem> items = parseComboItems(request, id);
            
            // Validate: combo phải có ít nhất một món
            if (items.isEmpty()) {
                request.setAttribute("error", "Combo phải có ít nhất một món!");
                // Cập nhật thông tin từ form vào existingCombo để hiển thị lại
                existingCombo.setName(name != null ? name.trim() : existingCombo.getName());
                existingCombo.setDescription(description != null ? description.trim() : existingCombo.getDescription());
                existingCombo.setPrice(price);
                existingCombo.setStatus(status);
                request.setAttribute("foodCombo", existingCombo);
                showEditForm(request, response, user);
                return;
            }

            // Xử lý hình ảnh: servlet đã có @MultipartConfig nên có thể xử lý trực tiếp
            String imageFileName = null;
            try {
                Part imagePart = request.getPart("imageFile");
                if (imagePart != null && imagePart.getSize() > 0) {
                    imageFileName = handleImageUpload(request);
                    if (imageFileName != null) {
                        // Xóa file cũ nếu có (có path injection protection)
                        if (existingCombo.getImage() != null && !existingCombo.getImage().isEmpty()) {
                            deleteOldImage(request, existingCombo.getImage());
                        }
                    }
                }
            } catch (Exception e) {
                // Nếu lỗi validation file, báo lỗi và hiển thị lại form
                if (e instanceof ServletException && e.getMessage().contains("Chỉ cho phép")) {
                    request.setAttribute("error", e.getMessage());
                    existingCombo.setName(name != null ? name.trim() : existingCombo.getName());
                    existingCombo.setDescription(description != null ? description.trim() : existingCombo.getDescription());
                    existingCombo.setPrice(price);
                    existingCombo.setStatus(status);
                    request.setAttribute("foodCombo", existingCombo);
                    showEditForm(request, response, user);
                    return;
                }
                // Không có file upload hoặc lỗi khác, tiếp tục xử lý
            }
            
            // Nếu không có file upload, lấy từ text input hoặc giữ nguyên ảnh cũ
            if (imageFileName == null) {
                String imageParam = request.getParameter("image");
                if (imageParam != null && !imageParam.trim().isEmpty()) {
                    imageFileName = imageParam.trim();
                } else {
                    imageFileName = existingCombo.getImage();
                }
            }

            // Cập nhật FoodCombo
            existingCombo.setName(name.trim());
            existingCombo.setDescription(description != null ? description.trim() : null);
            existingCombo.setPrice(price);
            existingCombo.setImage(imageFileName);
            existingCombo.setUpdatedBy(user.getId());
            existingCombo.setStatus(status);

            boolean success = foodComboDAO.updateFoodCombo(existingCombo);

            if (success) {
                // Update combo items (delete old, insert new)
                foodComboDAO.updateComboItems(id, items);

                response.sendRedirect(request.getContextPath() + "/staff/food-combos?success=update");
            } else {
                request.setAttribute("error", "Lỗi khi cập nhật combo");
                request.setAttribute("foodCombo", existingCombo);
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

    // DELETE FOOD COMBO
    private void deleteFoodCombo(HttpServletRequest request, HttpServletResponse response, Users user)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu ID");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);

            boolean success = foodComboDAO.deleteFoodCombo(id);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/staff/food-combos?success=delete");
            } else {
                response.sendRedirect(request.getContextPath() + "/staff/food-combos?error=Xóa combo thất bại");
            }

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID không hợp lệ");
        }
    }

    // TOGGLE FOOD COMBO STATUS
    private void toggleFoodComboStatus(HttpServletRequest request, HttpServletResponse response, Users user)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu ID");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);

            boolean success = foodComboDAO.toggleFoodComboStatus(id);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/staff/food-combos?success=toggle");
            } else {
                response.sendRedirect(request.getContextPath() + "/staff/food-combos?error=Cập nhật trạng thái thất bại");
            }

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID không hợp lệ");
        }
    }

    // ===== HELPER METHODS FOR FILE UPLOAD =====
    
    private String handleImageUpload(HttpServletRequest request) throws IOException, ServletException {
        Part imagePart = request.getPart("imageFile");
        
        if (imagePart == null || imagePart.getSize() == 0) {
            return null;
        }

        // Kiểm tra loại file
        String contentType = imagePart.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new ServletException("Chỉ được phép tải lên file ảnh (JPG, PNG, GIF, etc.)");
        }

        // Tạo thư mục upload nếu chưa tồn tại (phân chia thư mục combo)
        String uploadPath = getServletContext().getRealPath("/assets/user/img/combo");
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        // Tạo tên file duy nhất
        String submittedFileName = imagePart.getSubmittedFileName();
        String fileExtension = getFileExtension(submittedFileName);
        
        // Kiểm tra extension hợp lệ để tránh upload file độc
        if (fileExtension == null || !fileExtension.toLowerCase().matches("\\.(jpg|jpeg|png|gif)$")) {
            throw new ServletException("Chỉ cho phép upload file ảnh (.jpg, .jpeg, .png, .gif)");
        }
        
        String fileName = "foodcombo_" + System.currentTimeMillis() + "_" + 
                         (int)(Math.random() * 10000) + fileExtension;

        // Lưu file
        String filePath = uploadPath + File.separator + fileName;
        imagePart.write(filePath);

        // Trả về đường dẫn tương đối từ web root
        return "combo/" + fileName;
    }

    private void deleteOldImage(HttpServletRequest request, String imageFileName) {
        try {
            // Xử lý đường dẫn (có thể là "combo/filename.jpg" hoặc chỉ "filename.jpg")
            String relativePath = imageFileName;
            if (!relativePath.startsWith("combo/") && !relativePath.startsWith("item/")) {
                // Nếu là file cũ (chưa có prefix), xóa từ thư mục combo
                relativePath = "combo/" + relativePath;
            }
            
            String uploadBasePath = getServletContext().getRealPath("/assets/user/img");
            File uploadDir = new File(uploadBasePath);
            File oldFile = new File(uploadBasePath + File.separator + relativePath.replace("/", File.separator));
            
            // Kiểm tra path injection: đảm bảo file nằm trong thư mục upload
            if (oldFile.exists() && oldFile.isFile()) {
                String canonicalOldPath = oldFile.getCanonicalPath();
                String canonicalUploadPath = uploadDir.getCanonicalPath();
                
                if (canonicalOldPath.startsWith(canonicalUploadPath)) {
                    oldFile.delete();
                } else {
                    System.err.println("Lỗi bảo mật: Đường dẫn file nằm ngoài thư mục upload: " + canonicalOldPath);
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi xóa file hình ảnh cũ: " + e.getMessage());
        }
    }

    private String getFileExtension(String fileName) {
        if (fileName == null || fileName.lastIndexOf(".") == -1) {
            return null;
        }
        return fileName.substring(fileName.lastIndexOf("."));
    }

    // ===== HELPER METHOD FOR PARSING COMBO ITEMS =====
    
    private List<ComboItem> parseComboItems(HttpServletRequest request, int comboID) {
        List<ComboItem> items = new ArrayList<>();
        
        // Get all item IDs and quantities from request
        String[] itemIds = request.getParameterValues("itemIds");
        String[] quantities = request.getParameterValues("quantities");
        
        if (itemIds != null && quantities != null && itemIds.length == quantities.length) {
            for (int i = 0; i < itemIds.length; i++) {
                try {
                    int itemID = Integer.parseInt(itemIds[i]);
                    int quantity = Integer.parseInt(quantities[i]);
                    
                    if (quantity > 0) { // Only add items with quantity > 0
                        ComboItem item = new ComboItem(comboID, itemID, quantity);
                        items.add(item);
                    }
                } catch (NumberFormatException e) {
                    // Skip invalid entries
                }
            }
        }
        
        return items;
    }
    
    // Helper method để lấy upload path cho combo images
    private String getComboImageUploadPath() {
        return getServletContext().getRealPath("/assets/user/img/combo");
    }
}

