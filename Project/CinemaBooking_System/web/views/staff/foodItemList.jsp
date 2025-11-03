<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.FoodItem, java.util.List"%>
<%
    List<FoodItem> foodItems = (List<FoodItem>) request.getAttribute("foodItems");
    String success = request.getParameter("success");
    String error = request.getParameter("error");
    String searchKeyword = (String) request.getAttribute("searchKeyword");
    String selectedType = (String) request.getAttribute("selectedType");
    
    // Set active page for sidebar highlighting
    request.setAttribute("activePage", "food-items");
    request.setAttribute("pageTitle", "🍿 Quản lý Món Lẻ");
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Quản lý Món Lẻ | Cinema Booking</title>
        <jsp:include page="../layout/StaffStyles.jsp"/>
        <style>
            /* ===== Content-specific styles ===== */

            /* ===== Toolbar ===== */
            .toolbar {
                background: #ffffff;
                border: 1px solid #e2e8f0;
                border-radius: 20px;
                padding: 25px 30px;
                margin-bottom: 30px;
                display: flex;
                justify-content: space-between;
                align-items: center;
                flex-wrap: wrap;
                gap: 20px;
                box-shadow: 0 10px 20px rgba(0, 0, 0, 0.05);
            }

            .search-box {
                display: flex;
                gap: 15px;
                flex: 1;
                min-width: 300px;
                align-items: center;
            }

            .search-box form {
                display: flex;
                gap: 15px;
                width: 100%;
                align-items: center;
                flex-wrap: wrap;
            }

            .search-box input,
            .search-box select {
                flex: 1;
                min-width: 150px;
                background: #ffffff;
                border: 1px solid #ced4da;
                border-radius: 12px;
                padding: 12px 20px;
                color: #2d3748;
                font-size: 14px;
                outline: none;
                transition: all 0.3s ease;
                font-family: 'Inter', sans-serif;
            }

            .search-box input:focus,
            .search-box select:focus {
                border-color: #007bff;
                box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.25);
            }

            .search-box input::placeholder {
                color: #6b7280;
            }

            .search-box select option {
                color: #333;
                background-color: #fff;
            }

            .btn {
                background: linear-gradient(135deg, #00d4ff 0%, #0099ff 100%);
                color: white;
                border: none;
                border-radius: 12px;
                padding: 12px 28px;
                font-size: 14px;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.3s ease;
                display: flex;
                align-items: center;
                gap: 8px;
                text-decoration: none;
            }

            .btn:hover {
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

            /* ===== Table Container ===== */
            .table-container {
                background: #ffffff;
                border: 1px solid #e2e8f0;
                border-radius: 20px;
                padding: 30px;
                overflow-x: auto;
                box-shadow: 0 10px 20px rgba(0, 0, 0, 0.05);
            }

            table {
                width: 100%;
                border-collapse: collapse;
            }

            th {
                background: #f8f9fa;
                color: #4a5568;
                font-weight: 600;
                text-transform: uppercase;
                font-size: 12px;
                letter-spacing: 1px;
                padding: 15px;
                text-align: left;
                border-bottom: 2px solid #dee2e6;
            }

            td {
                padding: 18px 15px;
                border-bottom: 1px solid #e2e8f0;
                color: #2d3748;
                font-size: 14px;
            }

            tr:hover td {
                background: #f8f9fa;
                color: #1a202c;
            }

            .status-badge {
                padding: 6px 14px;
                border-radius: 20px;
                font-size: 12px;
                font-weight: 600;
                display: inline-block;
            }

            .status-active {
                background: rgba(16, 185, 129, 0.2);
                color: #10b981;
                border: 1px solid rgba(16, 185, 129, 0.3);
            }

            .status-inactive {
                background: rgba(239, 68, 68, 0.2);
                color: #ef4444;
                border: 1px solid rgba(239, 68, 68, 0.3);
            }

            .type-badge {
                padding: 4px 12px;
                border-radius: 6px;
                font-size: 11px;
                font-weight: 600;
                display: inline-block;
                margin: 2px;
            }

            .type-popcorn {
                background: rgba(245, 158, 11, 0.2);
                color: #f59e0b;
                border: 1px solid rgba(245, 158, 11, 0.3);
            }

            .type-drink {
                background: rgba(59, 130, 246, 0.2);
                color: #3b82f6;
                border: 1px solid rgba(59, 130, 246, 0.3);
            }

            .type-snack {
                background: rgba(139, 92, 246, 0.2);
                color: #8b5cf6;
                border: 1px solid rgba(139, 92, 246, 0.3);
            }

            .type-other {
                background: rgba(107, 114, 128, 0.2);
                color: #6b7280;
                border: 1px solid rgba(107, 114, 128, 0.3);
            }

            .action-buttons {
                display: flex;
                gap: 8px;
                flex-wrap: wrap;
            }

            .btn-small {
                padding: 8px 16px;
                font-size: 12px;
                border-radius: 8px;
                border: none;
                cursor: pointer;
                transition: all 0.3s ease;
                font-weight: 600;
                text-decoration: none;
                display: inline-block;
            }

            .btn-edit {
                background: rgba(0, 123, 255, 0.2);
                color: #007bff;
                border: 1px solid rgba(0, 123, 255, 0.3);
            }

            .btn-edit:hover {
                background: rgba(0, 123, 255, 0.3);
                transform: translateY(-2px);
            }

            .btn-toggle {
                background: rgba(245, 158, 11, 0.2);
                color: #f59e0b;
                border: 1px solid rgba(245, 158, 11, 0.3);
            }

            .btn-toggle:hover {
                background: rgba(245, 158, 11, 0.3);
                transform: translateY(-2px);
            }

            .btn-delete {
                background: rgba(239, 68, 68, 0.2);
                color: #ef4444;
                border: 1px solid rgba(239, 68, 68, 0.3);
            }

            .btn-delete:hover {
                background: rgba(239, 68, 68, 0.3);
                transform: translateY(-2px);
            }

            .price-cell {
                font-weight: 700;
                color: #10b981;
                font-size: 15px;
            }

            .image-cell {
                width: 60px;
            }

            .image-preview {
                width: 50px;
                height: 50px;
                object-fit: cover;
                border-radius: 8px;
                border: 1px solid #e2e8f0;
            }

            /* ===== Alert Messages ===== */
            .alert {
                padding: 15px 20px;
                border-radius: 12px;
                margin-bottom: 20px;
                font-weight: 600;
            }

            .alert-success {
                background: rgba(16, 185, 129, 0.2);
                color: #10b981;
                border: 1px solid rgba(16, 185, 129, 0.3);
            }

            .alert-error {
                background: rgba(239, 68, 68, 0.2);
                color: #ef4444;
                border: 1px solid rgba(239, 68, 68, 0.3);
            }

            /* ===== Responsive ===== */
            @media (max-width: 768px) {
                .action-buttons {
                    flex-direction: column;
                }
                .toolbar {
                    flex-direction: column;
                    align-items: stretch;
                }
                .search-box {
                    min-width: 100%;
                }
            }
        </style>
    </head>
    <body>

        <jsp:include page="../layout/StaffSidebar.jsp"/>
        <jsp:include page="../layout/StaffHeader.jsp"/>

        <div class="content">

            <% if (success != null) { %>
            <div class="alert alert-success">
                <% 
                    switch(success) {
                        case "create": 
                            out.print("✅ Thêm món thành công!");
                            break;
                        case "update":
                            out.print("✅ Cập nhật món thành công!");
                            break;
                        case "delete":
                            out.print("✅ Xóa món thành công!");
                            break;
                        case "toggle":
                            out.print("✅ Cập nhật trạng thái thành công!");
                            break;
                    }
                %>
            </div>
            <% } %>

            <% if (error != null) { %>
            <div class="alert alert-error">
                ❌ <%= error %>
            </div>
            <% } %>

            <div class="toolbar">
                <form method="GET" action="${pageContext.request.contextPath}/staff/food-items" class="search-box" id="searchForm">
                    <input type="text" name="keyword" 
                           placeholder="🔍 Tìm kiếm theo tên, mô tả..." 
                           value="<%= searchKeyword != null ? searchKeyword : "" %>">

                    <select name="type" id="typeFilter">
                        <option value="">Tất cả loại</option>
                        <option value="Popcorn" <%= "Popcorn".equals(selectedType) ? "selected" : "" %>>Bắp rang</option>
                        <option value="Drink" <%= "Drink".equals(selectedType) ? "selected" : "" %>>Nước uống</option>
                        <option value="Snack" <%= "Snack".equals(selectedType) ? "selected" : "" %>>Đồ ăn vặt</option>
                    </select>

                    <button type="submit" class="btn">Tìm kiếm</button>
                    <a href="${pageContext.request.contextPath}/staff/food-items" class="btn btn-secondary">🔄 Reset</a>
                </form>
                <a href="${pageContext.request.contextPath}/staff/food-items?action=add" class="btn">➕ Thêm món mới</a>
            </div>

            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Hình ảnh</th>
                            <th>Tên món</th>
                            <th>Loại</th>
                            <th>Giá</th>
                            <th>Mô tả</th>
                            <th>Trạng thái</th>
                            <th>Ngày tạo</th>
                            <th>Ngày cập nhật</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (foodItems != null && !foodItems.isEmpty()) { 
                            for (FoodItem item : foodItems) { 
                        %>
                        <tr>
                            <td>#<%= item.getItemID() %></td>
                            <td class="image-cell">
                                <% if (item.getImage() != null && !item.getImage().isEmpty()) { %>
                                <div style="position: relative; width: 50px; height: 50px;">
                                    <img src="${pageContext.request.contextPath}/assets/user/img/<%= item.getImage() %>" 
                                         alt="<%= item.getName() %>" 
                                         class="image-preview"
                                         id="itemImage_<%= item.getItemID() %>"
                                         onerror="handleItemImageError(this);">
                                    <div id="itemPlaceholder_<%= item.getItemID() %>" 
                                         style="display: none; width: 50px; height: 50px; background: #e2e8f0; border-radius: 8px; color: #6b7280; font-size: 9px; text-align: center; padding: 2px; border: 1px solid #e2e8f0; position: absolute; top: 0; left: 0;">
                                        <div style="display: flex; align-items: center; justify-content: center; height: 100%;">Không có ảnh</div>
                                    </div>
                                </div>
                                <% } else { %>
                                <div class="image-preview" style="background: #e2e8f0; display: flex; align-items: center; justify-content: center; color: #6b7280; font-size: 9px; text-align: center;">
                                    Không có ảnh
                                </div>
                                <% } %>
                            </td>
                            <td>
                                <strong><%= item.getName() %></strong>
                            </td>
                            <td>
                                <% 
                                    String typeClass = "type-other";
                                    if (item.getType() != null) {
                                        String typeLower = item.getType().toLowerCase();
                                        if (typeLower.contains("popcorn")) typeClass = "type-popcorn";
                                        else if (typeLower.contains("drink")) typeClass = "type-drink";
                                        else if (typeLower.contains("snack")) typeClass = "type-snack";
                                    }
                                %>
                                <span class="type-badge <%= typeClass %>">
                                    <%= item.getTypeDisplayName() %>
                                </span>
                            </td>
                            <td class="price-cell"><%= item.getFormattedPrice() %></td>
                            <td>
                                <small style="color: #6b7280;">
                                    <%= item.getDescription() != null && !item.getDescription().isEmpty() 
                                        ? (item.getDescription().length() > 50 
                                            ? item.getDescription().substring(0, 50) + "..." 
                                            : item.getDescription()) 
                                        : "Không có mô tả" %>
                                </small>
                            </td>
                            <td>
                                <span class="status-badge <%= item.getStatus() ? "status-active" : "status-inactive" %>">
                                    <%= item.getStatusText() %>
                                </span>
                            </td>
                            <td>
                                <small style="color: #6b7280;">
                                    <%= item.getFormattedCreatedDate() %>
                                </small>
                            </td>
                            <td>
                                <small style="color: #6b7280;">
                                    <%= item.getFormattedUpdatedDate() %>
                                </small>
                            </td>
                            <td>
                                <div class="action-buttons">
                                    <a href="${pageContext.request.contextPath}/staff/food-items?action=edit&id=<%= item.getItemID() %>" 
                                       class="btn-small btn-edit" title="Chỉnh sửa">✏️</a>
                                    <a href="${pageContext.request.contextPath}/staff/food-items?action=toggle&id=<%= item.getItemID() %>" 
                                       class="btn-small btn-toggle" 
                                       title="<%= item.getStatus() ? "Ẩn món" : "Hiện món" %>"
                                       onclick="return confirm('Bạn có chắc muốn <%= item.getStatus() ? "ẩn" : "hiện" %> món này?')">
                                        <%= item.getStatus() ? "👁️" : "👁️‍🗨️" %>
                                    </a>
                                    <a href="${pageContext.request.contextPath}/staff/food-items?action=delete&id=<%= item.getItemID() %>" 
                                       class="btn-small btn-delete" 
                                       onclick="return confirm('Bạn có chắc chắn muốn xóa món này?')"
                                       title="Xóa">🗑️</a>
                                </div>
                            </td>
                        </tr>
                        <% } 
                       } else { %>
                        <tr>
                            <td colspan="10" style="text-align: center; color: #6b7280; padding: 40px;">
                                📝 Chưa có món nào. Hãy thêm món đầu tiên!
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
        <script>
            // Handle image error for food item images
            function handleItemImageError(img) {
                const itemId = img.id.replace('itemImage_', '');
                const placeholder = document.getElementById('itemPlaceholder_' + itemId);
                
                if (placeholder) {
                    img.style.display = 'none';
                    placeholder.style.display = 'block';
                }
                
                // Prevent infinite loop
                img.onerror = null;
            }

            document.getElementById('typeFilter').addEventListener('change', function () {
                document.getElementById('searchForm').submit();
            });

            document.querySelector('.btn-secondary').addEventListener('click', function (e) {
                e.preventDefault();
                window.location.href = '${pageContext.request.contextPath}/staff/food-items';
            });

            document.querySelector('input[name="keyword"]').addEventListener('keypress', function (e) {
                if (e.key === 'Enter') {
                    document.getElementById('searchForm').submit();
                }
            });
        </script>
        <jsp:include page="../layout/StaffFooter.jsp"/>

    </body>
</html>

