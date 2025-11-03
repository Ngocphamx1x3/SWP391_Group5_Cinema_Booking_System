<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.FoodCombo, model.FoodItem, model.ComboItem, java.util.List"%>
<%
    FoodCombo combo = (FoodCombo) request.getAttribute("foodCombo");
    List<FoodItem> foodItems = (List<FoodItem>) request.getAttribute("foodItems");
    boolean isEdit = combo != null;
    String error = (String) request.getAttribute("error");
    
    // Calculate initial discount for edit mode
    double initialDiscount = 0;
    if (isEdit && combo != null) {
        double totalOriginal = 0;
        if (combo.getItems() != null && !combo.getItems().isEmpty()) {
            for (ComboItem ci : combo.getItems()) {
                if (ci.getFoodItem() != null) {
                    totalOriginal += ci.getFoodItem().getPrice() * ci.getQuantity();
                }
            }
        }
        initialDiscount = Math.max(0, totalOriginal - combo.getPrice());
    }
    
    // Set active page for sidebar highlighting
    request.setAttribute("activePage", "food-combos");
    request.setAttribute("pageTitle", isEdit ? "✏️ Chỉnh sửa Combo" : "➕ Thêm Combo Mới");
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title><%= isEdit ? "Chỉnh sửa" : "Thêm mới" %> Combo | Cinema Booking</title>
        <jsp:include page="../layout/StaffStyles.jsp"/>
        <style>
            .form-container {
                background: #ffffff;
                border: 1px solid #e2e8f0;
                border-radius: 20px;
                padding: 40px;
                max-width: 900px;
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
            .form-group textarea:focus {
                border-color: #007bff;
                box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.25);
            }

            .form-group textarea {
                resize: vertical;
                min-height: 100px;
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

            .items-selection {
                border: 1px solid #e2e8f0;
                border-radius: 12px;
                padding: 20px;
                background: #f8f9fa;
            }

            .items-list {
                max-height: 400px;
                overflow-y: auto;
                margin-top: 15px;
            }

            .item-row {
                display: flex;
                align-items: center;
                gap: 15px;
                padding: 12px;
                background: white;
                border-radius: 8px;
                margin-bottom: 10px;
                border: 1px solid #e2e8f0;
            }

            .item-checkbox {
                width: 20px;
                height: 20px;
            }

            .item-info {
                flex: 1;
                display: flex;
                align-items: center;
                gap: 15px;
            }

            .item-image {
                width: 50px;
                height: 50px;
                object-fit: cover;
                border-radius: 8px;
                border: 1px solid #e2e8f0;
            }

            .item-details {
                flex: 1;
            }

            .item-name {
                font-weight: 600;
                color: #1a202c;
                margin-bottom: 4px;
            }

            .item-meta {
                font-size: 12px;
                color: #6b7280;
            }

            .item-price {
                font-weight: 600;
                color: #10b981;
                min-width: 100px;
                text-align: right;
            }

            .quantity-input {
                width: 80px;
                padding: 8px;
                border: 1px solid #ced4da;
                border-radius: 8px;
                text-align: center;
            }

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
            }

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

            .required::after {
                content: " *";
                color: #ef4444;
            }

            .total-summary {
                background: #e3f2fd;
                padding: 15px;
                border-radius: 12px;
                margin-top: 15px;
                font-weight: 600;
            }
        </style>
    </head>
    <body>

        <jsp:include page="../layout/StaffSidebar.jsp"/>
        <jsp:include page="../layout/StaffHeader.jsp"/>

        <div class="content">
            <div class="form-container">
                <div class="form-header">
                    <h2><%= isEdit ? "Chỉnh sửa Combo" : "Thêm Combo Mới" %></h2>
                    <p><%= isEdit ? "Cập nhật thông tin combo hiện có" : "Điền đầy đủ thông tin để thêm combo mới" %></p>
                </div>

                <% if (error != null) { %>
                <div class="alert alert-error">
                    ❌ <%= error %>
                </div>
                <% } %>

                <form action="${pageContext.request.contextPath}/staff/food-combos" method="post" id="foodComboForm" enctype="multipart/form-data">
                    <% if (isEdit) { %>
                    <input type="hidden" name="id" value="<%= combo.getComboID() %>">
                    <% } %>
                    <input type="hidden" name="action" value="<%= isEdit ? "update" : "create" %>">

                    <div class="form-group">
                        <label for="name" class="required">Tên combo</label>
                        <input type="text" id="name" name="name" 
                               value="<%= isEdit ? combo.getName() : "" %>" 
                               placeholder="VD: Combo Couple, Combo Gia đình"
                               required>
                    </div>

                    <div class="form-group">
                        <label for="description">Mô tả</label>
                        <textarea id="description" name="description" 
                                  placeholder="Mô tả chi tiết về combo..."><%= isEdit && combo.getDescription() != null ? combo.getDescription() : "" %></textarea>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="totalOriginalPrice">Tổng giá gốc (VNĐ)</label>
                            <input type="text" id="totalOriginalPrice" 
                                   value="0 đ" 
                                   readonly
                                   style="background: #f8f9fa; cursor: not-allowed;">
                            <small style="color: #6b7280; font-size: 12px;">Tổng giá trị tất cả món đã chọn</small>
                        </div>

                        <div class="form-group">
                            <label for="discount">Giảm giá (VNĐ)</label>
                            <input type="number" id="discount" name="discount" 
                                   value="<%= isEdit ? (int)initialDiscount : "0" %>"
                                   min="0" 
                                   step="1000"
                                   placeholder="VD: 10000">
                            <small style="color: #6b7280; font-size: 12px;">Nhập số tiền giảm (0 nếu không giảm)</small>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="price" class="required">Giá combo cuối cùng (VNĐ)</label>
                        <input type="number" id="price" name="price" 
                               value="<%= isEdit ? (int)combo.getPrice() : "0" %>" 
                               min="0" 
                               step="1000"
                               readonly
                               required
                               style="background: #e3f2fd; font-weight: 700; font-size: 16px; cursor: not-allowed;">
                        <small style="color: #6b7280; font-size: 12px;">
                            ⚠️ Giá này sẽ tự động tính = Tổng giá gốc - Giảm giá
                        </small>
                    </div>

                    <div class="form-group">
                        <label for="image">Tên file hình ảnh</label>
                        <input type="text" id="image" name="image" 
                               value="<%= isEdit && combo.getImage() != null ? combo.getImage() : "" %>" 
                               placeholder="VD: combo-couple.jpg">
                        <small style="color: #6b7280; font-size: 12px;">Nhập tên file hình ảnh</small>
                    </div>

                    <div class="form-group">
                        <label>Chọn món trong combo</label>
                        <div class="items-selection">
                            <small style="color: #6b7280; font-size: 12px; display: block; margin-bottom: 10px;">
                                ✅ Chọn các món và nhập số lượng cho mỗi món
                            </small>
                            <div class="items-list" id="itemsList">
                                <% if (foodItems != null && !foodItems.isEmpty()) { 
                                    for (FoodItem item : foodItems) { 
                                        // Check if item is in combo (for edit mode)
                                        boolean isSelected = false;
                                        int quantity = 1;
                                        if (isEdit && combo.getItems() != null) {
                                            for (ComboItem ci : combo.getItems()) {
                                                if (ci.getItemID() == item.getItemID()) {
                                                    isSelected = true;
                                                    quantity = ci.getQuantity();
                                                    break;
                                                }
                                            }
                                        }
                                %>
                                <div class="item-row">
                                    <input type="checkbox" 
                                           class="item-checkbox" 
                                           name="itemIds" 
                                           value="<%= item.getItemID() %>"
                                           <%= isSelected ? "checked" : "" %>
                                           onchange="toggleQuantityInput(this)">
                                    <div class="item-info">
                                        <% if (item.getImage() != null && !item.getImage().isEmpty()) { %>
                                        <img src="${pageContext.request.contextPath}/assets/user/img/<%= item.getImage() %>" 
                                             alt="<%= item.getName() %>" 
                                             class="item-image"
                                             onerror="this.style.display='none'">
                                        <% } %>
                                        <div class="item-details">
                                            <div class="item-name"><%= item.getName() %></div>
                                            <div class="item-meta">
                                                <%= item.getTypeDisplayName() %> • <%= item.getFormattedPrice() %>
                                            </div>
                                        </div>
                                        <div class="item-price" data-price="<%= item.getPrice() %>">
                                            <%= item.getFormattedPrice() %>
                                        </div>
                                    </div>
                                    <input type="number" 
                                           name="quantities" 
                                           class="quantity-input"
                                           value="<%= quantity %>"
                                           min="1"
                                           max="10"
                                           <%= isSelected ? "" : "disabled" %>
                                           data-item-id="<%= item.getItemID() %>"
                                           data-item-price="<%= item.getPrice() %>"
                                           oninput="calculateComboPrice()">
                                </div>
                                <% } 
                                } else { %>
                                <p style="text-align: center; color: #6b7280; padding: 20px;">
                                    Chưa có món lẻ nào. Vui lòng thêm món lẻ trước!
                                </p>
                                <% } %>
                            </div>
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Trạng thái</label>
                        <div class="checkbox-group">
                            <input type="checkbox" id="status" name="status" 
                                   <%= isEdit ? (combo.getStatus() ? "checked" : "") : "checked" %>>
                            <label for="status">Còn bán (Hiển thị cho khách hàng)</label>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">
                            <%= isEdit ? "💾 Cập nhật" : "➕ Thêm mới" %>
                        </button>
                        <a href="${pageContext.request.contextPath}/staff/food-combos" class="btn btn-secondary">
                            ↩️ Quay lại
                        </a>
                    </div>
                </form>
            </div>
        </div>

        <jsp:include page="../layout/StaffFooter.jsp"/>

        <script>
            function toggleQuantityInput(checkbox) {
                const row = checkbox.closest('.item-row');
                const quantityInput = row.querySelector('.quantity-input');

                if (checkbox.checked) {
                    quantityInput.disabled = false;
                    quantityInput.value = quantityInput.value || '1';
                } else {
                    quantityInput.disabled = true;
                    quantityInput.value = '1';
                }

                // Recalculate price when item selection changes
                calculateComboPrice();
            }

            // Calculate combo price automatically
            function calculateComboPrice() {
                const checkedItems = document.querySelectorAll('.item-checkbox:checked');
                let totalOriginal = 0;

                checkedItems.forEach(checkbox => {
                    const row = checkbox.closest('.item-row');
                    const quantityInput = row.querySelector('.quantity-input');
                    const itemPrice = parseFloat(quantityInput.getAttribute('data-item-price')) || 0;
                    const quantity = parseInt(quantityInput.value) || 0;

                    totalOriginal += itemPrice * quantity;
                });

                // Get discount value
                const discountInput = document.getElementById('discount');
                const discount = parseFloat(discountInput.value) || 0;

                // Calculate final price
                const finalPrice = Math.max(0, totalOriginal - discount);

                // Update UI
                const totalOriginalPriceInput = document.getElementById('totalOriginalPrice');
                const priceInput = document.getElementById('price');

                if (totalOriginalPriceInput) {
                    totalOriginalPriceInput.value = formatPrice(totalOriginal);
                }

                if (priceInput) {
                    priceInput.value = Math.round(finalPrice);
                }
            }

            // Format price with thousand separators
            function formatPrice(price) {
                return new Intl.NumberFormat('vi-VN').format(Math.round(price)) + ' đ';
            }

            // Initialize discount input event listener and calculate initial price
            document.addEventListener('DOMContentLoaded', function () {
                const discountInput = document.getElementById('discount');
                if (discountInput) {
                    discountInput.addEventListener('input', calculateComboPrice);
                }

                // Calculate initial price
                setTimeout(function () {
                    calculateComboPrice();
                }, 100);
            });

            // Form validation
            document.getElementById('foodComboForm').addEventListener('submit', function (e) {
                // Recalculate price before submit to ensure accuracy
                calculateComboPrice();

                const name = document.getElementById('name').value.trim();
                const price = parseFloat(document.getElementById('price').value);
                const checkedItems = document.querySelectorAll('.item-checkbox:checked');

                let errors = [];

                if (!name) {
                    errors.push("Tên combo không được để trống");
                }

                if (checkedItems.length === 0) {
                    errors.push("Vui lòng chọn ít nhất một món cho combo");
                }

                if (isNaN(price) || price <= 0) {
                    errors.push("Giá combo phải lớn hơn 0. Vui lòng chọn ít nhất một món và kiểm tra lại giảm giá");
                }

                // Validate quantities
                checkedItems.forEach(checkbox => {
                    const row = checkbox.closest('.item-row');
                    const quantityInput = row.querySelector('.quantity-input');
                    const quantity = parseInt(quantityInput.value);
                    if (quantity < 1 || quantity > 10) {
                        errors.push("Số lượng mỗi món phải từ 1-10");
                    }
                });

                if (errors.length > 0) {
                    e.preventDefault();
                    alert("Lỗi:\n• " + errors.join("\n• "));
                    return false;
                }

                // Set quantities for unchecked items to 0 (or don't send them)
                document.querySelectorAll('.item-checkbox').forEach(checkbox => {
                    if (!checkbox.checked) {
                        const row = checkbox.closest('.item-row');
                        const quantityInput = row.querySelector('.quantity-input');
                        quantityInput.disabled = true;
                    }
                });
            });
        </script>

    </body>
</html>

