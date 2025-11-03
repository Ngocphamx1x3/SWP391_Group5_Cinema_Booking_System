<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.FoodCombo, java.util.List"%>
<%
    List<FoodCombo> foodCombos = (List<FoodCombo>) request.getAttribute("foodCombos");
    String success = request.getParameter("success");
    String error = request.getParameter("error");
    String searchKeyword = (String) request.getAttribute("searchKeyword");
    
    // Set active page for sidebar highlighting
    request.setAttribute("activePage", "food-combos");
    request.setAttribute("pageTitle", "🍔 Quản lý Combo");
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Quản lý Combo | Cinema Booking</title>
        <jsp:include page="../layout/StaffStyles.jsp"/>
        <style>
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

            .search-box input {
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

            .search-box input:focus {
                border-color: #007bff;
                box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.25);
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
            }

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

            .btn-detail {
                background: rgba(139, 92, 246, 0.2);
                color: #8b5cf6;
                border: 1px solid rgba(139, 92, 246, 0.3);
            }

            .btn-toggle {
                background: rgba(245, 158, 11, 0.2);
                color: #f59e0b;
                border: 1px solid rgba(245, 158, 11, 0.3);
            }

            .btn-delete {
                background: rgba(239, 68, 68, 0.2);
                color: #ef4444;
                border: 1px solid rgba(239, 68, 68, 0.3);
            }

            .price-cell {
                font-weight: 700;
                color: #10b981;
                font-size: 15px;
            }

            .items-count {
                color: #6b7280;
                font-size: 12px;
            }

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
                            out.print("✅ Thêm combo thành công!");
                            break;
                        case "update":
                            out.print("✅ Cập nhật combo thành công!");
                            break;
                        case "delete":
                            out.print("✅ Xóa combo thành công!");
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
                <form method="GET" action="${pageContext.request.contextPath}/staff/food-combos" class="search-box" id="searchForm">
                    <input type="text" name="keyword" 
                           placeholder="🔍 Tìm kiếm theo tên, mô tả..." 
                           value="<%= searchKeyword != null ? searchKeyword : "" %>">
                    <button type="submit" class="btn">Tìm kiếm</button>
                    <a href="${pageContext.request.contextPath}/staff/food-combos" class="btn btn-secondary">🔄 Reset</a>
                </form>
                <a href="${pageContext.request.contextPath}/staff/food-combos?action=add" class="btn">➕ Thêm combo mới</a>
            </div>

            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Hình ảnh</th>
                            <th>Tên combo</th>
                            <th>Giá</th>
                            <th>Số món</th>
                            <th>Mô tả</th>
                            <th>Trạng thái</th>
                            <th>Ngày tạo</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (foodCombos != null && !foodCombos.isEmpty()) { 
                            for (FoodCombo combo : foodCombos) { 
                        %>
                        <tr>
                            <td>#<%= combo.getComboID() %></td>
                            <td>
                                <% if (combo.getImage() != null && !combo.getImage().isEmpty()) { %>
                                <div style="position: relative; width: 50px; height: 50px;">
                                    <img src="${pageContext.request.contextPath}/assets/user/img/<%= combo.getImage() %>" 
                                         alt="<%= combo.getName() %>" 
                                         style="width: 50px; height: 50px; object-fit: cover; border-radius: 8px; border: 1px solid #e2e8f0;"
                                         id="comboImage_<%= combo.getComboID() %>"
                                         onerror="handleComboImageError(this);">
                                    <div id="comboPlaceholder_<%= combo.getComboID() %>" 
                                         style="display: none; width: 50px; height: 50px; background: #e2e8f0; border-radius: 8px; color: #6b7280; font-size: 9px; text-align: center; padding: 2px; border: 1px solid #e2e8f0; position: absolute; top: 0; left: 0;">
                                        <div style="display: flex; align-items: center; justify-content: center; height: 100%;">Không có ảnh</div>
                                    </div>
                                </div>
                                <% } else { %>
                                <div style="width: 50px; height: 50px; background: #e2e8f0; border-radius: 8px; display: flex; align-items: center; justify-content: center; color: #6b7280; font-size: 9px; text-align: center; padding: 2px; border: 1px solid #e2e8f0;">
                                    Không có ảnh
                                </div>
                                <% } %>
                            </td>
                            <td><strong><%= combo.getName() %></strong></td>
                            <td class="price-cell"><%= combo.getFormattedPrice() %></td>
                            <td>
                                <span class="items-count">
                                    <%= combo.getItems() != null ? combo.getTotalItemsCount() : 0 %> món
                                </span>
                            </td>
                            <td>
                                <small style="color: #6b7280;">
                                    <%= combo.getDescription() != null && !combo.getDescription().isEmpty() 
                                        ? (combo.getDescription().length() > 50 
                                            ? combo.getDescription().substring(0, 50) + "..." 
                                            : combo.getDescription()) 
                                        : "Không có mô tả" %>
                                </small>
                            </td>
                            <td>
                                <span class="status-badge <%= combo.getStatus() ? "status-active" : "status-inactive" %>">
                                    <%= combo.getStatusText() %>
                                </span>
                            </td>
                            <td>
                                <small style="color: #6b7280;">
                                    <%= combo.getFormattedCreatedDate() %>
                                </small>
                            </td>
                            <td>
                                <div class="action-buttons">
                                    <a href="${pageContext.request.contextPath}/staff/food-combos?action=detail&id=<%= combo.getComboID() %>" 
                                       class="btn-small btn-detail" title="Xem chi tiết">👁️</a>
                                    <a href="${pageContext.request.contextPath}/staff/food-combos?action=edit&id=<%= combo.getComboID() %>" 
                                       class="btn-small btn-edit" title="Chỉnh sửa">✏️</a>
                                    <a href="${pageContext.request.contextPath}/staff/food-combos?action=toggle&id=<%= combo.getComboID() %>" 
                                       class="btn-small btn-toggle" 
                                       title="<%= combo.getStatus() ? "Ẩn combo" : "Hiện combo" %>"
                                       onclick="return confirm('Bạn có chắc muốn <%= combo.getStatus() ? "ẩn" : "hiện" %> combo này?')">
                                        <%= combo.getStatus() ? "👁️" : "👁️‍🗨️" %>
                                    </a>
                                    <a href="${pageContext.request.contextPath}/staff/food-combos?action=delete&id=<%= combo.getComboID() %>" 
                                       class="btn-small btn-delete" 
                                       onclick="return confirm('Bạn có chắc chắn muốn xóa combo này?')"
                                       title="Xóa">🗑️</a>
                                </div>
                            </td>
                        </tr>
                        <% } 
                       } else { %>
                        <tr>
                            <td colspan="9" style="text-align: center; color: #6b7280; padding: 40px;">
                                📝 Chưa có combo nào. Hãy thêm combo đầu tiên!
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
        <script>
            // Handle image error for combo images
            function handleComboImageError(img) {
                const comboId = img.id.replace('comboImage_', '');
                const placeholder = document.getElementById('comboPlaceholder_' + comboId);
                
                if (placeholder) {
                    img.style.display = 'none';
                    placeholder.style.display = 'block';
                }
                
                // Prevent infinite loop
                img.onerror = null;
            }

            document.querySelector('input[name="keyword"]').addEventListener('keypress', function (e) {
                if (e.key === 'Enter') {
                    document.getElementById('searchForm').submit();
                }
            });
        </script>
        <jsp:include page="../layout/StaffFooter.jsp"/>

    </body>
</html>

