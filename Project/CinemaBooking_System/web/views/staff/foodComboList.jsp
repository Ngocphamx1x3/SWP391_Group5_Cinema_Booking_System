<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.FoodCombo, java.util.List"%>
<%!
    private boolean isValidImageFile(String imageName) {
        if (imageName == null || imageName.trim().isEmpty()) {
            return false;
        }
        String lower = imageName.toLowerCase();
        return lower.endsWith(".jpg") || lower.endsWith(".jpeg") || 
               lower.endsWith(".png") || lower.endsWith(".gif") || 
               lower.endsWith(".webp") || lower.endsWith(".svg");
    }
%>
<%
    List<FoodCombo> foodCombos = (List<FoodCombo>) request.getAttribute("foodCombos");
    String success = request.getParameter("success");
    String error = request.getParameter("error");
    String searchKeyword = (String) request.getAttribute("searchKeyword");
    
    request.setAttribute("activePage", "food-combos");
    request.setAttribute("pageTitle", "🍔 Quản lý Combo");
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Quản lý Combo | Cinema Booking</title>
        <jsp:include page="../layout/StaffStyles.jsp"/>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/staff/css/foodCombo.css">
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
                                <% if (isValidImageFile(combo.getImage())) { %>
                                <div style="position: relative; width: 50px; height: 50px;">
                                    <img src="<%= request.getContextPath() %>/assets/user/img/<%= combo.getImage() %>" 
                                         alt="<%= combo.getName() != null ? combo.getName() : "" %>" 
                                         style="width: 50px; height: 50px; object-fit: cover; border-radius: 8px; border: 1px solid #e2e8f0;"
                                         id="comboImage_<%= combo.getComboID() %>"
                                         onerror="handleComboImageError(this);">
                                    <div id="comboPlaceholder_<%= combo.getComboID() %>" 
                                         class="image-placeholder" style="display: none; position: absolute; top: 0; left: 0; width: 50px; height: 50px;">
                                        <div style="display: flex; align-items: center; justify-content: center; height: 100%;">Không có ảnh</div>
                                    </div>
                                </div>
                                <% } else { %>
                                <div class="image-placeholder" style="width: 50px; height: 50px;">Không có ảnh</div>
                                <% } %>
                            </td>
                            <td><strong><%= combo.getName() %></strong></td>
                            <td class="price-cell"><%= combo.getFormattedPrice() %></td>
                            <td>
                                <span class="items-count">
                                    <%= (combo.getItems() != null) ? combo.getTotalItemsCount() : 0 %> món
                                </span>
                            </td>
                            <td>
                                <small style="color: #6b7280;">
                                    <% 
                                        String description = combo.getDescription();
                                        if (description != null && !description.trim().isEmpty()) {
                                            String displayDesc = description.length() > 50 
                                                ? description.substring(0, 50) + "..." 
                                                : description;
                                            out.print(displayDesc);
                                        } else {
                                            out.print("Không có mô tả");
                                        }
                                    %>
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

            const keywordInput = document.querySelector('input[name="keyword"]');
            if (keywordInput) {
                keywordInput.addEventListener('keypress', function (e) {
                    if (e.key === 'Enter') {
                        e.preventDefault();
                        const searchForm = document.getElementById('searchForm');
                        if (searchForm) {
                            searchForm.submit();
                        }
                    }
                });
            }
            
            const resetBtn = document.querySelector('.btn-secondary');
            if (resetBtn) {
                resetBtn.addEventListener('click', function (e) {
                    e.preventDefault();
                    window.location.href = '<%= request.getContextPath() %>/staff/food-combos';
                });
            }
        </script>
        <jsp:include page="../layout/StaffFooter.jsp"/>

    </body>
</html>

