<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.FoodCombo, model.ComboItem"%>
<%
    FoodCombo combo = (FoodCombo) request.getAttribute("foodCombo");
    
    // Set active page for sidebar highlighting
    request.setAttribute("activePage", "food-combos");
    request.setAttribute("pageTitle", "👁️ Chi tiết Combo");
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Chi tiết Combo | Cinema Booking</title>
        <jsp:include page="../layout/StaffStyles.jsp"/>
        <style>
            .detail-container {
                background: #ffffff; 
                border: 1px solid #e2e8f0; 
                border-radius: 20px;
                padding: 40px;
                max-width: 900px;
                margin: 0 auto;
                box-shadow: 0 10px 20px rgba(0, 0, 0, 0.05); 
            }

            .detail-header {
                text-align: center;
                margin-bottom: 40px;
                padding-bottom: 20px;
                border-bottom: 2px solid #e2e8f0;
            }

            .detail-header h2 {
                font-size: 28px;
                font-weight: 700;
                color: #1a202c; 
                margin-bottom: 10px;
            }

            .combo-image {
                width: 200px;
                height: 200px;
                object-fit: cover;
                border-radius: 16px;
                border: 2px solid #e2e8f0;
                margin: 20px auto;
                display: block;
            }

            .detail-section {
                margin-bottom: 30px;
            }

            .detail-section h3 {
                font-size: 18px;
                font-weight: 600;
                color: #4a5568;
                margin-bottom: 15px;
                padding-bottom: 10px;
                border-bottom: 1px solid #e2e8f0;
            }

            .info-row {
                display: flex;
                padding: 12px 0;
                border-bottom: 1px solid #f0f0f0;
            }

            .info-label {
                font-weight: 600;
                color: #4a5568;
                min-width: 150px;
            }

            .info-value {
                color: #2d3748;
                flex: 1;
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

            .items-table {
                width: 100%;
                border-collapse: collapse;
                margin-top: 15px;
            }

            .items-table th {
                background: #f8f9fa;
                color: #4a5568;
                font-weight: 600;
                padding: 12px;
                text-align: left;
                border-bottom: 2px solid #dee2e6;
                font-size: 12px;
                text-transform: uppercase;
            }

            .items-table td {
                padding: 15px 12px;
                border-bottom: 1px solid #e2e8f0;
                color: #2d3748;
            }

            .items-table tr:hover td {
                background: #f8f9fa;
            }

            .item-image {
                width: 50px;
                height: 50px;
                object-fit: cover;
                border-radius: 8px;
                border: 1px solid #e2e8f0;
            }

            .price-value {
                font-weight: 700;
                color: #10b981;
            }

            .summary-box {
                background: #e3f2fd;
                border-radius: 12px;
                padding: 20px;
                margin-top: 20px;
            }

            .summary-row {
                display: flex;
                justify-content: space-between;
                padding: 8px 0;
                font-size: 16px;
            }

            .summary-total {
                font-weight: 700;
                font-size: 20px;
                color: #007bff;
                border-top: 2px solid #90caf9;
                padding-top: 10px;
                margin-top: 10px;
            }

            .action-buttons {
                display: flex;
                gap: 15px;
                margin-top: 30px;
                padding-top: 30px;
                border-top: 2px solid #e2e8f0;
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

            .btn-secondary {
                background: #6c757d; 
                color: #ffffff; 
            }

            .btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 25px rgba(0, 123, 255, 0.3);
            }
        </style>
    </head>
    <body>

        <jsp:include page="../layout/StaffSidebar.jsp"/>
        <jsp:include page="../layout/StaffHeader.jsp"/>

        <div class="content">
            <div class="detail-container">
                <div class="detail-header">
                    <h2><%= combo.getName() %></h2>
                    <% if (combo.getImage() != null && !combo.getImage().isEmpty()) { %>
                    <div style="position: relative; width: 200px; height: 200px; margin: 20px auto;">
                        <img src="${pageContext.request.contextPath}/assets/user/img/<%= combo.getImage() %>" 
                             alt="<%= combo.getName() %>" 
                             class="combo-image"
                             id="detailComboImage"
                             onerror="handleDetailImageError(this);">
                        <div id="detailComboPlaceholder" 
                             style="display: none; width: 200px; height: 200px; background: #e2e8f0; border-radius: 16px; color: #6b7280; font-size: 14px; text-align: center; border: 2px solid #e2e8f0; position: absolute; top: 0; left: 0;">
                            <div style="display: flex; align-items: center; justify-content: center; height: 100%;">Không có ảnh</div>
                        </div>
                    </div>
                    <% } else { %>
                    <div style="width: 200px; height: 200px; background: #e2e8f0; border-radius: 16px; display: flex; align-items: center; justify-content: center; color: #6b7280; font-size: 14px; text-align: center; border: 2px solid #e2e8f0; margin: 20px auto;">
                        Không có ảnh
                    </div>
                    <% } %>
                </div>

                <div class="detail-section">
                    <h3>📋 Thông tin chung</h3>
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
                            <%= combo.getDescription() != null && !combo.getDescription().isEmpty() 
                                ? combo.getDescription() 
                                : "Không có mô tả" %>
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
                    <h3>🍿 Danh sách món trong combo</h3>
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
                                    if (ci.getFoodItem() != null) {
                                        double itemTotal = ci.getFoodItem().getPrice() * ci.getQuantity();
                                        totalOriginalPrice += itemTotal;
                            %>
                            <tr>
                                <td>
                                    <% if (ci.getFoodItem().getImage() != null && !ci.getFoodItem().getImage().isEmpty()) { %>
                                    <img src="${pageContext.request.contextPath}/assets/user/img/<%= ci.getFoodItem().getImage() %>" 
                                         alt="<%= ci.getFoodItem().getName() %>" 
                                         class="item-image"
                                         onerror="this.style.display='none'">
                                    <% } else { %>
                                    <div style="width: 50px; height: 50px; background: #e2e8f0; border-radius: 8px;"></div>
                                    <% } %>
                                </td>
                                <td><strong><%= ci.getFoodItem().getName() %></strong></td>
                                <td><%= ci.getFoodItem().getTypeDisplayName() %></td>
                                <td><%= ci.getFormattedItemPrice() %></td>
                                <td><%= ci.getQuantity() %></td>
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
                        ✏️ Chỉnh sửa
                    </a>
                    <a href="${pageContext.request.contextPath}/staff/food-combos" 
                       class="btn btn-secondary">
                        ↩️ Quay lại
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
        </script>

    </body>
</html>

