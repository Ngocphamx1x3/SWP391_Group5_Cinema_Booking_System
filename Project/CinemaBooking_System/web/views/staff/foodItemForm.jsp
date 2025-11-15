<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.FoodItem"%>
<%
    FoodItem item = (FoodItem) request.getAttribute("foodItem");
    boolean isEdit = item != null;
    String error = (String) request.getAttribute("error");
    
    // Set active page for sidebar highlighting
    request.setAttribute("activePage", "food-items");
    request.setAttribute("pageTitle", isEdit ? "Chỉnh sửa Món Lẻ" : "Thêm Món Lẻ Mới");
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title><%= isEdit ? "Chỉnh sửa" : "Thêm mới" %> Món Lẻ | Cinema Booking</title>
        <jsp:include page="../layout/StaffStyles.jsp"/>
        <style>
            /* ===== Form-specific styles ===== */

            /* ===== Form Container ===== */
            .form-container {
                background: #ffffff; 
                border: 1px solid #e2e8f0; 
                border-radius: 20px;
                padding: 40px;
                max-width: 800px;
                margin: 0 auto;
                box-shadow: 0 10px 20px rgba(0, 0, 0, 0.05); 
            }

            .form-header {
                text-align: center;
                margin-bottom: 40px;
            }

            .form-header h2 {
                font-size: 24px;
                font-weight: 700;
                color: #1a202c; 
                margin-bottom: 10px;
            }

            .form-header p {
                color: #6b7280;
                font-size: 14px;
            }

            /* ===== Form Styles ===== */
            .form-group {
                margin-bottom: 25px;
            }

            .form-group label {
                display: block;
                color: #4a5568;
                font-size: 13px;
                font-weight: 600;
                margin-bottom: 8px;
                text-transform: uppercase;
                letter-spacing: 1px;
            }

            .form-group input,
            .form-group select,
            .form-group textarea {
                width: 100%;
                background: #ffffff; 
                border: 1px solid #ced4da; 
                border-radius: 12px;
                padding: 14px 16px;
                color: #2d3748; 
                font-size: 14px;
                outline: none;
                transition: all 0.3s ease;
                font-family: 'Inter', sans-serif;
            }

            .form-group input:focus,
            .form-group select:focus,
            .form-group textarea:focus {
                border-color: #007bff; 
                box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.25); 
            }

            .form-group textarea {
                resize: vertical;
                min-height: 100px;
            }
            
            .form-group select option {
                color: #333;
                background-color: #fff;
            }

            .form-row {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 20px;
            }

            .checkbox-group {
                display: flex;
                align-items: center;
                gap: 10px;
                margin-top: 10px;
            }

            .checkbox-group input[type="checkbox"] {
                width: 18px;
                height: 18px;
                accent-color: #007bff; 
            }

            .checkbox-group label {
                margin-bottom: 0;
                text-transform: none;
                letter-spacing: normal;
                font-size: 14px;
                color: #2d3748;
            }

            .price-input-wrapper {
                position: relative;
            }

            .price-input-wrapper::before {
                content: "đ";
                position: absolute;
                right: 16px;
                top: 50%;
                transform: translateY(-50%);
                color: #6b7280;
                font-weight: 600;
                pointer-events: none;
            }

            .price-input-wrapper input {
                padding-right: 40px;
            }

            .image-preview-container {
                margin-top: 10px;
                display: flex;
                align-items: center;
                gap: 15px;
            }

            .image-preview {
                width: 100px;
                height: 100px;
                object-fit: cover;
                border-radius: 12px;
                border: 2px solid #e2e8f0;
            }

            .no-image-placeholder {
                width: 100px;
                height: 100px;
                background: #f8f9fa;
                border: 2px dashed #ced4da;
                border-radius: 12px;
                display: flex;
                align-items: center;
                justify-content: center;
                color: #6b7280;
                font-size: 12px;
                text-align: center;
            }

            /* ===== Form Actions ===== */
            .form-actions {
                display: flex;
                gap: 15px;
                margin-top: 40px;
                padding-top: 30px;
                border-top: 1px solid #e2e8f0; 
            }

            .btn {
                flex: 1;
                padding: 14px 28px;
                border: none;
                border-radius: 12px;
                font-size: 14px;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.3s ease;
                text-decoration: none;
                text-align: center;
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 8px;
            }

            .btn-primary {
                background: linear-gradient(135deg, #00d4ff 0%, #0099ff 100%);
                color: white;
            }

            .btn-primary:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 25px rgba(0, 123, 255, 0.3); 
            }

            .btn-secondary {
                background: #6c757d; 
                color: #ffffff; 
                border: 1px solid #6c757d;
            }

            .btn-secondary:hover {
                background: #5a6268; 
                transform: translateY(-2px);
            }

            /* ===== Alert Messages ===== */
            .alert {
                padding: 15px 20px;
                border-radius: 12px;
                margin-bottom: 25px;
                font-weight: 600;
            }

            .alert-error {
                background: rgba(239, 68, 68, 0.2);
                color: #ef4444;
                border: 1px solid rgba(239, 68, 68, 0.3);
            }

            /* ===== Required Field ===== */
            .required::after {
                content: " *";
                color: #ef4444;
            }

            /* ===== Input Error ===== */
            .input-error {
                border-color: #ef4444 !important;
                box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.25) !important;
            }

            .error-message {
                color: #ef4444;
                font-size: 12px;
                margin-top: 5px;
                font-weight: 600;
            }

            /* ===== Responsive ===== */
            @media (max-width: 768px) {
                .form-row {
                    grid-template-columns: 1fr;
                }
            }
        </style>
    </head>
    <body>

        <jsp:include page="../layout/StaffSidebar.jsp"/>
        <jsp:include page="../layout/StaffHeader.jsp"/>

        <div class="content">
            <div class="form-container">
                <div class="form-header">
                    <h2><%= isEdit ? "Chỉnh sửa Thông Tin Món Lẻ" : "Thêm Món Lẻ Mới" %></h2>
                    <p><%= isEdit ? "Cập nhật thông tin món lẻ hiện có" : "Điền đầy đủ thông tin để thêm món lẻ mới" %></p>
                </div>

                <% if (error != null) { %>
                <div class="alert alert-error">
                    <%= error %>
                </div>
                <% } %>

                <form action="${pageContext.request.contextPath}/staff/food-items" method="post" id="foodItemForm" enctype="multipart/form-data">
                    <% if (isEdit) { %>
                    <input type="hidden" name="id" value="<%= item.getItemID() %>">
                    <% } %>
                    <input type="hidden" name="action" value="<%= isEdit ? "update" : "create" %>">

                    <div class="form-row">
                        <div class="form-group">
                            <label for="name" class="required">Tên món</label>
                            <input type="text" id="name" name="name" 
                                   value="<%= isEdit ? item.getName() : "" %>" 
                                   placeholder="VD: Bỏng ngô Caramel, Coca Cola, Snack khoai tây"
                                   required>
                        </div>

                        <div class="form-group">
                            <label for="type" class="required">Loại món</label>
                            <select id="type" name="type" required>
                                <option value="">-- Chọn loại món --</option>
                                <option value="Popcorn" <%= isEdit && "Popcorn".equalsIgnoreCase(item.getType()) ? "selected" : "" %>>Bắp rang</option>
                                <option value="Drink" <%= isEdit && "Drink".equalsIgnoreCase(item.getType()) ? "selected" : "" %>>Nước uống</option>
                                <option value="Snack" <%= isEdit && "Snack".equalsIgnoreCase(item.getType()) ? "selected" : "" %>>Đồ ăn vặt</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="price" class="required">Giá (VNĐ)</label>
                        <div class="price-input-wrapper">
                            <input type="number" id="price" name="price" 
                                   value="<%= isEdit ? (int)item.getPrice() : "" %>" 
                                   min="0" 
                                   step="1000"
                                   placeholder="VD: 35000"
                                   required>
                        </div>
                        <small style="color: #6b7280; font-size: 12px;">Nhập giá theo VNĐ (ví dụ: 35000)</small>
                    </div>

                    <div class="form-group">
                        <label for="image">Tên file hình ảnh</label>
                        <input type="text" id="image" name="image" 
                               value="<%= isEdit && item.getImage() != null ? item.getImage() : "" %>" 
                               placeholder="VD: popcorn-caramel.jpg, coca-cola.jpg">
                        <small style="color: #6b7280; font-size: 12px;">Nhập tên file hình ảnh (file phải đã được upload vào thư mục assets)</small>
                        <div class="image-preview-container" id="imagePreviewContainer" style="display: none;"
                             data-existing-image="<%= isEdit && item != null && item.getImage() != null && !item.getImage().isEmpty() ? item.getImage() : "" %>">
                            <img src="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7" 
                                 alt="Preview" 
                                 class="image-preview"
                                 id="imagePreview"
                                 style="display: none;">
                            <div class="no-image-placeholder" id="noImagePlaceholder" style="display: none;">
                                Không có hình ảnh
                            </div>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="description">Mô tả</label>
                        <textarea id="description" name="description" 
                                  placeholder="Mô tả chi tiết về món, hương vị, đặc điểm..."><%= isEdit && item.getDescription() != null ? item.getDescription() : "" %></textarea>
                    </div>

                    <div class="form-group">
                        <label>Trạng thái</label>
                        <div class="checkbox-group">
                            <input type="checkbox" id="status" name="status" 
                                   <%= isEdit ? (item.getStatus() ? "checked" : "") : "checked" %>>
                            <label for="status">Còn bán (Hiển thị cho khách hàng)</label>
                        </div>
                        <small style="color: #6b7280; font-size: 12px;">Bỏ chọn để ẩn món (ngừng bán)</small>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">
                            <%= isEdit ? "Cập nhật" : "Thêm mới" %>
                        </button>
                        <a href="${pageContext.request.contextPath}/staff/food-items" class="btn btn-secondary">
                            Quay lại
                        </a>
                    </div>
                </form>
            </div>
        </div>

        <jsp:include page="../layout/StaffFooter.jsp"/>

        <script>
            // Format price input
            document.getElementById('price').addEventListener('input', function() {
                let value = parseInt(this.value);
                if (isNaN(value) || value < 0) {
                    this.value = '';
                }
            });

            // Track if image error has been handled to prevent infinite loops
            let imageErrorHandled = false;

            // Handle image error - only once per image load
            function handleImageError(img) {
                if (imageErrorHandled) return;
                
                imageErrorHandled = true;
                img.style.display = 'none';
                const placeholder = document.getElementById('noImagePlaceholder');
                const container = document.getElementById('imagePreviewContainer');
                
                if (placeholder) {
                    placeholder.style.display = 'flex';
                }
                if (container) {
                    container.style.display = 'flex';
                }
                
                // Prevent further error triggers by setting a valid transparent image
                img.onerror = null;
                img.src = 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7';
            }

            // Initialize preview if there's an existing image
            document.addEventListener('DOMContentLoaded', function() {
                const imageInput = document.getElementById('image');
                const preview = document.getElementById('imagePreview');
                const placeholder = document.getElementById('noImagePlaceholder');
                const container = document.getElementById('imagePreviewContainer');
                
                if (!imageInput || !preview || !container) return;
                
                // Load existing image if available (from data attribute)
                const existingImage = container.getAttribute('data-existing-image');
                if (existingImage && existingImage.trim() !== '') {
                    container.style.display = 'flex';
                    preview.style.display = 'block';
                    placeholder.style.display = 'none';
                    preview.src = '${pageContext.request.contextPath}/assets/user/img/' + existingImage;
                    preview.onerror = function() {
                        handleImageError(this);
                    };
                    imageErrorHandled = false;
                }
            });

            // Image preview update when typing
            document.getElementById('image').addEventListener('input', function() {
                const imageName = this.value.trim();
                const preview = document.getElementById('imagePreview');
                const placeholder = document.getElementById('noImagePlaceholder');
                const container = document.getElementById('imagePreviewContainer');
                
                if (!preview || !container) return;
                
                // Reset error flag for new image
                imageErrorHandled = false;
                
                if (imageName) {
                    // Show container and preview
                    container.style.display = 'flex';
                    preview.style.display = 'block';
                    placeholder.style.display = 'none';
                    
                    // Set image source
                    const imageUrl = '${pageContext.request.contextPath}/assets/user/img/' + imageName;
                    preview.src = imageUrl;
                    
                    // Attach error handler
                    preview.onerror = function() {
                        handleImageError(this);
                    };
                } else {
                    // Hide everything when input is empty
                    container.style.display = 'none';
                    preview.style.display = 'none';
                    placeholder.style.display = 'none';
                    // Set a placeholder transparent image to avoid errors
                    preview.src = 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7';
                }
            });

            // Form validation
            document.getElementById('foodItemForm').addEventListener('submit', function (e) {
                const name = document.getElementById('name').value.trim();
                const type = document.getElementById('type').value;
                const price = parseFloat(document.getElementById('price').value);
                
                let errors = [];

                // Validate tên món
                if (!name) {
                    errors.push("Tên món không được để trống");
                }

                // Validate loại món
                if (!type) {
                    errors.push("Vui lòng chọn loại món");
                }

                // Validate giá
                if (isNaN(price) || price < 0) {
                    errors.push("Giá phải là số hợp lệ và lớn hơn hoặc bằng 0");
                }

                // Hiển thị lỗi nếu có
                if (errors.length > 0) {
                    e.preventDefault();
                    alert("Lỗi:\n• " + errors.join("\n• "));
                    return false;
                }
            });
        </script>

    </body>
</html>

