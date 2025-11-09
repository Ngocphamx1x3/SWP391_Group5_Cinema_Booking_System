package controller;

import dal.FoodItemDAO;
import model.FoodItem;
import model.Users;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.File;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "FoodItemController", urlPatterns = {"/staff/food-items"})
@MultipartConfig(
    maxFileSize = 1024 * 1024 * 5, // 5MB
    maxRequestSize = 1024 * 1024 * 10 // 10MB
)
public class FoodItemController extends HttpServlet {

    private FoodItemDAO foodItemDAO;

    @Override
    public void init() throws ServletException {
        super.init();
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
                    showFoodItemList(request, response, user);
                    break;
                case "add":
                    showAddForm(request, response, user);
                    break;
                case "edit":
                    showEditForm(request, response, user);
                    break;
                case "delete":
                    deleteFoodItem(request, response, user);
                    break;
                case "toggle":
                    toggleFoodItemStatus(request, response, user);
                    break;
                default:
                    showFoodItemList(request, response, user);
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
                    createFoodItem(request, response, user);
                    break;
                case "update":
                    updateFoodItem(request, response, user);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Action không hợp lệ");
            }
        } catch (Exception e) {
            throw new ServletException("Lỗi xử lý request: " + e.getMessage(), e);
        }
    }

    // ===== PRIVATE METHODS =====

    // SHOW FOOD ITEM LIST
    private void showFoodItemList(HttpServletRequest request, HttpServletResponse response, Users user)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");
        String type = request.getParameter("type");
        List<FoodItem> foodItems;

        // Nếu có search keyword hoặc filter
        if ((keyword != null && !keyword.trim().isEmpty()) || (type != null && !type.trim().isEmpty())) {
            foodItems = foodItemDAO.searchAndFilterFoodItems(keyword, type);
            
            if (keyword != null && !keyword.trim().isEmpty()) {
                request.setAttribute("searchKeyword", keyword.trim());
            }
            if (type != null && !type.trim().isEmpty()) {
                request.setAttribute("selectedType", type.trim());
            }
        } else {
            // Không có search, hiển thị tất cả
            foodItems = foodItemDAO.getAllFoodItems();
        }

        request.setAttribute("foodItems", foodItems);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/views/staff/foodItemList.jsp");
        dispatcher.forward(request, response);
    }

    // SHOW ADD FORM
    private void showAddForm(HttpServletRequest request, HttpServletResponse response, Users user)
            throws ServletException, IOException {

        RequestDispatcher dispatcher = request.getRequestDispatcher("/views/staff/foodItemForm.jsp");
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
            FoodItem item = foodItemDAO.getFoodItemById(id);

            if (item == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy món lẻ");
                return;
            }

            request.setAttribute("foodItem", item);

            RequestDispatcher dispatcher = request.getRequestDispatcher("/views/staff/foodItemForm.jsp");
            dispatcher.forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID không hợp lệ");
        }
    }

    // CREATE FOOD ITEM
    private void createFoodItem(HttpServletRequest request, HttpServletResponse response, Users user)
            throws ServletException, IOException {

        try {
            String name = request.getParameter("name");
            String type = request.getParameter("type");
            String priceStr = request.getParameter("price");
            String description = request.getParameter("description");
            String statusStr = request.getParameter("status");
            
            // Validation
            if (name == null || name.trim().isEmpty()) {
                request.setAttribute("error", "Tên món không được để trống");
                showAddForm(request, response, user);
                return;
            }

            if (type == null || type.trim().isEmpty()) {
                request.setAttribute("error", "Vui lòng chọn loại món");
                showAddForm(request, response, user);
                return;
            }

            double price;
            try {
                price = Double.parseDouble(priceStr);
                if (price < 0) {
                    throw new NumberFormatException();
                }
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Giá phải là số hợp lệ và lớn hơn hoặc bằng 0");
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
                    FoodItem previousItem = new FoodItem();
                    previousItem.setName(name != null ? name.trim() : "");
                    previousItem.setType(type != null ? type.trim() : "");
                    previousItem.setPrice(price);
                    previousItem.setDescription(description != null ? description.trim() : null);
                    previousItem.setStatus(status);
                    request.setAttribute("previousData", previousItem);
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

            // Tạo FoodItem object
            FoodItem item = new FoodItem();
            item.setName(name.trim());
            item.setType(type.trim());
            item.setPrice(price);
            item.setImage(imageFileName);
            item.setDescription(description != null ? description.trim() : null);
            item.setStatus(status);

            boolean success = foodItemDAO.addFoodItem(item);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/staff/food-items?success=create");
            } else {
                request.setAttribute("error", "Lỗi khi thêm món lẻ");
                // Lưu lại dữ liệu đã nhập
                request.setAttribute("previousData", item);
                showAddForm(request, response, user);
            }

        } catch (Exception e) {
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            showAddForm(request, response, user);
        }
    }

    // UPDATE FOOD ITEM
    private void updateFoodItem(HttpServletRequest request, HttpServletResponse response, Users user)
            throws ServletException, IOException {

        try {
            String idStr = request.getParameter("id");
            if (idStr == null || idStr.isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu ID");
                return;
            }

            int id = Integer.parseInt(idStr);
            FoodItem existingItem = foodItemDAO.getFoodItemById(id);

            if (existingItem == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy món lẻ");
                return;
            }

            String name = request.getParameter("name");
            String type = request.getParameter("type");
            String priceStr = request.getParameter("price");
            String description = request.getParameter("description");
            String statusStr = request.getParameter("status");

            // Validation
            if (name == null || name.trim().isEmpty()) {
                request.setAttribute("error", "Tên món không được để trống");
                request.setAttribute("foodItem", existingItem);
                showEditForm(request, response, user);
                return;
            }

            if (type == null || type.trim().isEmpty()) {
                request.setAttribute("error", "Vui lòng chọn loại món");
                request.setAttribute("foodItem", existingItem);
                showEditForm(request, response, user);
                return;
            }

            double price;
            try {
                price = Double.parseDouble(priceStr);
                if (price < 0) {
                    throw new NumberFormatException();
                }
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Giá phải là số hợp lệ và lớn hơn hoặc bằng 0");
                request.setAttribute("foodItem", existingItem);
                showEditForm(request, response, user);
                return;
            }

            boolean status = "on".equals(statusStr);

            // Xử lý hình ảnh: servlet đã có @MultipartConfig nên có thể xử lý trực tiếp
            String imageFileName = null;
            try {
                Part imagePart = request.getPart("imageFile");
                if (imagePart != null && imagePart.getSize() > 0) {
                    imageFileName = handleImageUpload(request);
                    if (imageFileName != null) {
                        // Xóa file cũ nếu có (có path injection protection)
                        if (existingItem.getImage() != null && !existingItem.getImage().isEmpty()) {
                            deleteOldImage(request, existingItem.getImage());
                        }
                    }
                }
            } catch (Exception e) {
                // Nếu lỗi validation file, báo lỗi và hiển thị lại form
                if (e instanceof ServletException && e.getMessage().contains("Chỉ cho phép")) {
                    request.setAttribute("error", e.getMessage());
                    existingItem.setName(name != null ? name.trim() : existingItem.getName());
                    existingItem.setType(type != null ? type.trim() : existingItem.getType());
                    existingItem.setPrice(price);
                    existingItem.setDescription(description != null ? description.trim() : existingItem.getDescription());
                    existingItem.setStatus(status);
                    request.setAttribute("foodItem", existingItem);
                    showEditForm(request, response, user);
                    return;
                }
                // Không có file upload hoặc lỗi khác, tiếp tục xử lý
            }
            
            // Nếu không có file upload, lấy từ text input
            if (imageFileName == null) {
                String imageParam = request.getParameter("image");
                if (imageParam != null && !imageParam.trim().isEmpty()) {
                    imageFileName = imageParam.trim();
                } else {
                    // Nếu không nhập gì, giữ nguyên hình ảnh cũ
                    imageFileName = existingItem.getImage();
                }
            }

            // Cập nhật FoodItem
            existingItem.setName(name.trim());
            existingItem.setType(type.trim());
            existingItem.setPrice(price);
            existingItem.setImage(imageFileName);
            existingItem.setDescription(description != null ? description.trim() : null);
            existingItem.setStatus(status);

            boolean success = foodItemDAO.updateFoodItem(existingItem);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/staff/food-items?success=update");
            } else {
                request.setAttribute("error", "Lỗi khi cập nhật món lẻ");
                request.setAttribute("foodItem", existingItem);
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

    // DELETE FOOD ITEM
    private void deleteFoodItem(HttpServletRequest request, HttpServletResponse response, Users user)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu ID");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);

            boolean success = foodItemDAO.deleteFoodItem(id);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/staff/food-items?success=delete");
            } else {
                response.sendRedirect(request.getContextPath() + "/staff/food-items?error=Xóa món thất bại");
            }

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID không hợp lệ");
        }
    }

    // TOGGLE FOOD ITEM STATUS
    private void toggleFoodItemStatus(HttpServletRequest request, HttpServletResponse response, Users user)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu ID");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);

            boolean success = foodItemDAO.toggleFoodItemStatus(id);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/staff/food-items?success=toggle");
            } else {
                response.sendRedirect(request.getContextPath() + "/staff/food-items?error=Cập nhật trạng thái thất bại");
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

        // Tạo thư mục upload nếu chưa tồn tại (phân chia thư mục item)
        String uploadPath = getServletContext().getRealPath("/assets/user/img/item");
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
        
        String fileName = "fooditem_" + System.currentTimeMillis() + "_" + 
                         (int)(Math.random() * 10000) + fileExtension;

        // Lưu file
        String filePath = uploadPath + File.separator + fileName;
        imagePart.write(filePath);

        // Trả về đường dẫn tương đối từ web root
        return "item/" + fileName;
    }

    private void deleteOldImage(HttpServletRequest request, String imageFileName) {
        try {
            // Xử lý đường dẫn (có thể là "item/filename.jpg", "combo/filename.jpg" hoặc chỉ "filename.jpg")
            String relativePath = imageFileName;
            if (!relativePath.startsWith("combo/") && !relativePath.startsWith("item/")) {
                // Nếu là file cũ (chưa có prefix), xóa từ thư mục item
                relativePath = "item/" + relativePath;
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
            // Log error nhưng không throw để không ảnh hưởng đến quá trình update
            System.err.println("Lỗi khi xóa file hình ảnh cũ: " + e.getMessage());
        }
    }

    private String getFileExtension(String fileName) {
        if (fileName == null || fileName.lastIndexOf(".") == -1) {
            return null;
        }
        return fileName.substring(fileName.lastIndexOf("."));
    }
}

