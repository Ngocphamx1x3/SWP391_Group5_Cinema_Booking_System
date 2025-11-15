<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.FoodCombo, model.ComboItem"%>
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
    FoodCombo combo = (FoodCombo) request.getAttribute("foodCombo");
    request.setAttribute("activePage", "food-combos");
    request.setAttribute("pageTitle", "Chi tiết Combo");
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Chi tiết Combo | Cinema Booking</title>
        <jsp:include page="../layout/StaffStyles.jsp"/>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/staff/css/foodCombo.css">
    </head>
    <body>

        <jsp:include page="../layout/StaffSidebar.jsp"/>
        <jsp:include page="../layout/StaffHeader.jsp"/>

        <div class="content">
            <div class="detail-container">
                <div class="detail-header">
                    <h2><%= combo.getName() %></h2>
                    <% if (isValidImageFile(combo.getImage())) { %>
                    <div style="position: relative; width: 200px; height: 200px; margin: 20px auto;">
                        <img src="<%= request.getContextPath() %>/assets/user/img/<%= combo.getImage() %>" 
                             alt="<%= combo.getName() != null ? combo.getName() : "" %>" 
                             class="combo-image"
                             id="detailComboImage"
                             onerror="handleDetailImageError(this);">
                        <div id="detailComboPlaceholder" 
                             class="image-placeholder image-placeholder-large" style="display: none; position: absolute; top: 0; left: 0;">
                            <div style="display: flex; align-items: center; justify-content: center; height: 100%;">Không có ảnh</div>
                        </div>
                    </div>
                    <% } else { %>
                    <div class="image-placeholder image-placeholder-large" style="margin: 20px auto;">Không có ảnh</div>
                    <% } %>
                </div>

                <div class="detail-section">
                    <h3>Thông tin chung</h3>
                    <div class="info-row">
                        <div class="info-label">ID Combo:</div>
                        <div class="info-value">#<%= combo.getComboID() %></div>
                    </div>
                    <div class="info-row">
                        <div class="info-label">Tên combo:</div>
                        <div class="info-value"><strong><%= combo.getName() %></strong></div>
                    </div>
                    <div class="info-row">
                        <div class="info-label">Mô tả:</div>
                        <div class="info-value">
                            <% 
                                String description = combo.getDescription();
                                if (description != null && !description.trim().isEmpty()) {
                                    out.print(description);
                                } else {
                                    out.print("Không có mô tả");
                                }
                            %>
                        </div>
                    </div>
                    <div class="info-row">
                        <div class="info-label">Giá combo:</div>
                        <div class="info-value price-value"><%= combo.getFormattedPrice() %></div>
                    </div>
                    <div class="info-row">
                        <div class="info-label">Trạng thái:</div>
                        <div class="info-value">
                            <span class="status-badge <%= combo.getStatus() ? "status-active" : "status-inactive" %>">
                                <%= combo.getStatusText() %>
                            </span>
                        </div>
                    </div>
                    <div class="info-row">
                        <div class="info-label">Ngày tạo:</div>
                        <div class="info-value"><%= combo.getFormattedCreatedDate() %></div>
                    </div>
                    <% if (combo.getUpdatedDate() != null) { %>
                    <div class="info-row">
                        <div class="info-label">Ngày cập nhật:</div>
                        <div class="info-value"><%= combo.getFormattedUpdatedDate() %></div>
                    </div>
                    <% } %>
                </div>

                <div class="detail-section">
                    <h3>Danh sách món trong combo</h3>
                    <% if (combo.getItems() != null && !combo.getItems().isEmpty()) { %>
                    <table class="items-table">
                        <thead>
                            <tr>
                                <th>Hình ảnh</th>
                                <th>Tên món</th>
                                <th>Loại</th>
                                <th>Giá đơn</th>
                                <th>Số lượng</th>
                                <th>Thành tiền</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                                double totalOriginalPrice = 0;
                                for (ComboItem ci : combo.getItems()) {
                                    if (ci != null && ci.getFoodItem() != null) {
                                        model.FoodItem foodItem = ci.getFoodItem();
                                        double itemPrice = foodItem.getPrice();
                                        int quantity = ci.getQuantity();
                                        double itemTotal = itemPrice * quantity;
                                        totalOriginalPrice += itemTotal;
                                        String itemImage = foodItem.getImage();
                                        String itemName = foodItem.getName();
                                        int itemID = foodItem.getItemID();
                            %>
                            <tr>
                                <td>
                                    <% if (itemImage != null && isValidImageFile(itemImage)) { %>
                                    <div style="position: relative; width: 50px; height: 50px;">
                                        <img src="<%= request.getContextPath() %>/assets/user/img/<%= itemImage %>" 
                                             alt="<%= itemName != null ? itemName : "" %>" 
                                             class="item-image"
                                             id="itemImage_<%= itemID %>"
                                             onerror="handleItemImageErrorInDetail(this);">
                                        <div id="itemPlaceholder_<%= itemID %>" 
                                             class="image-placeholder" style="display: none; position: absolute; top: 0; left: 0; width: 50px; height: 50px;">
                                            <div style="display: flex; align-items: center; justify-content: center; height: 100%;">No img</div>
                                        </div>
                                    </div>
                                    <% } else { %>
                                    <div class="image-placeholder" style="width: 50px; height: 50px;">No img</div>
                                    <% } %>
                                </td>
                                <td><strong><%= itemName != null ? itemName : "N/A" %></strong></td>
                                <td><%= foodItem.getTypeDisplayName() != null ? foodItem.getTypeDisplayName() : "N/A" %></td>
                                <td><%= ci.getFormattedItemPrice() %></td>
                                <td><%= quantity %></td>
                                <td class="price-value"><%= ci.getFormattedSubTotal() %></td>
                            </tr>
                            <% 
                                    }
                                }
                            %>
                        </tbody>
                    </table>

                    <div class="summary-box">
                        <div class="summary-row">
                            <span>Tổng giá trị gốc:</span>
                            <span><%= String.format("%,.0f", totalOriginalPrice) %> đ</span>
                        </div>
                        <div class="summary-row">
                            <span>Giá combo:</span>
                            <span><%= combo.getFormattedPrice() %></span>
                        </div>
                        <div class="summary-row summary-total">
                            <span>
                                <% 
                                    double savings = totalOriginalPrice - combo.getPrice();
                                    if (savings > 0) {
                                        out.print("Tiết kiệm: " + String.format("%,.0f", savings) + " đ");
                                    } else {
                                        out.print("Tổng giá trị:");
                                    }
                                %>
                            </span>
                            <span><%= combo.getFormattedPrice() %></span>
                        </div>
                    </div>
                    <% } else { %>
                    <p style="text-align: center; color: #6b7280; padding: 20px;">
                        Combo này chưa có món nào.
                    </p>
                    <% } %>
                </div>

                <div class="action-buttons">
                    <a href="${pageContext.request.contextPath}/staff/food-combos?action=edit&id=<%= combo.getComboID() %>" 
                       class="btn btn-primary">
                        Chỉnh sửa
                    </a>
                    <a href="${pageContext.request.contextPath}/staff/food-combos" 
                       class="btn btn-secondary">
                        Quay lại
                    </a>
                </div>
            </div>
        </div>

        <jsp:include page="../layout/StaffFooter.jsp"/>

        <script>
            // Handle image error for detail page combo image
            function handleDetailImageError(img) {
                const placeholder = document.getElementById('detailComboPlaceholder');
                
                if (placeholder) {
                    img.style.display = 'none';
                    placeholder.style.display = 'block';
                }
                
                // Prevent infinite loop
                img.onerror = null;
            }

            // Handle image error for food item images in combo detail
            function handleItemImageErrorInDetail(img) {
                const itemId = img.id.replace('itemImage_', '');
                const placeholder = document.getElementById('itemPlaceholder_' + itemId);
                
                if (placeholder) {
                    img.style.display = 'none';
                    placeholder.style.display = 'block';
                }
                
                // Prevent infinite loop
                img.onerror = null;
            }
        </script>

    </body>
</html>

