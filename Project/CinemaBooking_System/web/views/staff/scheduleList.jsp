<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.Schedule, java.util.List"%>
<%
    List<Schedule> schedules = (List<Schedule>) request.getAttribute("schedules");
    String success = request.getParameter("success");
    String error = request.getParameter("error");
    
    // Thêm các biến phân trang
    Integer currentPage = (Integer) request.getAttribute("currentPage");
    Integer pageSize = (Integer) request.getAttribute("pageSize");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    Integer totalRecords = (Integer) request.getAttribute("totalRecords");
    
    // Set giá trị mặc định nếu null
    if (currentPage == null) currentPage = 1;
    if (pageSize == null) pageSize = 10;
    if (totalPages == null) totalPages = 1;
    if (totalRecords == null) totalRecords = 0;
    
    // Set active page for sidebar highlighting
    request.setAttribute("activePage", "schedules");
    request.setAttribute("pageTitle", "📅 Quản lý Lịch Chiếu");
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Quản lý Lịch Chiếu | Cinema Booking</title>
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
            }

            .search-box input {
                flex: 1;
                background: #ffffff;
                border: 1px solid #ced4da;
                border-radius: 12px;
                padding: 12px 20px;
                color: #2d3748;
                font-size: 14px;
                outline: none;
                transition: all 0.3s ease;
            }

            .search-box input:focus {
                border-color: #007bff;
                box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.25);
            }

            .search-box input::placeholder {
                color: #6b7280;
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

            .time-badge {
                background: rgba(59, 130, 246, 0.2);
                color: #3b82f6;
                padding: 4px 10px;
                border-radius: 8px;
                font-size: 11px;
                font-weight: 600;
                display: inline-block;
                margin: 2px 0;
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

            .btn-delete {
                background: rgba(239, 68, 68, 0.2);
                color: #ef4444;
                border: 1px solid rgba(239, 68, 68, 0.3);
            }

            .btn-delete:hover {
                background: rgba(239, 68, 68, 0.3);
                transform: translateY(-2px);
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

            /* ===== Phân trang ===== */
            .pagination {
                background: #ffffff;
                border: 1px solid #e2e8f0;
                border-radius: 12px;
                padding: 20px;
                margin-top: 20px;
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
                display: flex;
                justify-content: space-between;
                align-items: center;
                flex-wrap: wrap;
                gap: 15px;
            }

            .pagination-info {
                color: #6b7280;
                font-size: 14px;
                font-weight: 500;
            }

            .pagination-controls {
                display: flex;
                gap: 8px;
                align-items: center;
                flex-wrap: wrap;
            }

            .page-numbers {
                display: flex;
                gap: 5px;
            }

            .page-size-selector {
                display: flex;
                align-items: center;
                gap: 8px;
            }

            .page-size-selector select {
                padding: 6px 10px;
                border-radius: 6px;
                border: 1px solid #ced4da;
                font-size: 14px;
                outline: none;
            }

            .btn-disabled {
                background: #f8f9fa !important;
                color: #6c757d !important;
                border-color: #dee2e6 !important;
                cursor: not-allowed !important;
                opacity: 0.6;
            }

            .pagination-controls .btn-small {
                min-width: 40px;
                text-align: center;
                padding: 6px 10px;
            }

            /* ===== Footer ===== */
            footer {
                background: #ffffff;
                border-top: 1px solid #e2e8f0;
                color: #6b7280;
                text-align: center;
                padding: 25px;
                margin-left: 280px;
                margin-top: 40px;
                font-size: 14px;
            }

            /* ===== Responsive ===== */
            @media (max-width: 768px) {
                .sidebar {
                    width: 100%;
                    height: auto;
                    position: relative;
                }
                header, .content, footer {
                    margin-left: 0;
                }
                .action-buttons {
                    flex-direction: column;
                }
                .pagination {
                    flex-direction: column;
                    text-align: center;
                }
                .pagination-controls {
                    justify-content: center;
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
                            out.print("✅ Thêm lịch chiếu thành công!");
                            break;
                        case "update":
                            out.print("✅ Cập nhật lịch chiếu thành công!");
                            break;
                        case "delete":
                            out.print("✅ Xóa lịch chiếu thành công!");
                            break;
                    }
                %>
            </div>
            <% } %>

            <% if (error != null) { %>
            <div class="alert alert-error">
                ❌ Có lỗi xảy ra khi xử lý!
            </div>
            <% } %>

            <div class="toolbar">
                <div class="search-box">
                    <input type="text" placeholder="🔍 Tìm kiếm theo tên lịch chiếu...">
                    <button type="button" class="btn">Tìm kiếm</button>
                    <a href="${pageContext.request.contextPath}/staff/schedules" class="btn" style="
                       background: #6c757d;
                       color: #ffffff;
                       border: 1px solid #6c757d;
                       ">🔄 Reset</a>
                </div>
                <a href="${pageContext.request.contextPath}/staff/schedules?action=add" class="btn">➕ Thêm lịch chiếu</a>
            </div>

            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Tên lịch</th>
                            <th>Phim</th>
                            <th>Phòng</th>
                            <th>Thời gian</th>
                            <th>Giá vé</th>
                            <th>Trạng thái</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (schedules != null && !schedules.isEmpty()) { 
                            for (Schedule schedule : schedules) { 
                        %>
                        <tr>
                            <td>#<%= schedule.getId() %></td>
                            <td><strong><%= schedule.getName() %></strong></td>
                            <td>
                                <strong><%= schedule.getMovieName() != null ? schedule.getMovieName() : "Movie #" + schedule.getMovieId() %></strong>
                            </td>
                            <td>
                                <%= schedule.getRoomName() != null ? schedule.getRoomName() : "Room #" + schedule.getRoomId() %>
                                <% if (schedule.getCinemaName() != null) { %>
                                <br><small style="color: #6b7280;"><%= schedule.getCinemaName() %></small>
                                <% } %>
                            </td>
                            <td>
                                <div class="time-badge">Bắt đầu: <%= schedule.getFormattedStartAt() %></div>
                                <div class="time-badge">Kết thúc: <%= schedule.getFormattedFinishAt() %></div>
                            </td>
                            <td><strong><%= String.format("%,d", (long)schedule.getPrice()) %> VND</strong></td>
                            <td>
                                <span class="status-badge <%= Schedule.STATUS_ACTIVE.equals(schedule.getStatus()) ? "status-active" : "status-inactive" %>">
                                    <%= schedule.getStatus() %>
                                </span>
                            </td>
                            <td>
                                <div class="action-buttons">
                                    <% if (schedule.canBeEdited()) { %>
                                    <a href="${pageContext.request.contextPath}/staff/schedules?action=edit&id=<%= schedule.getId() %>" 
                                       class="btn-small btn-edit" title="Chỉnh sửa">✏️</a>
                                    <% } %>
                                    <a href="${pageContext.request.contextPath}/staff/schedules?action=delete&id=<%= schedule.getId() %>" 
                                       class="btn-small btn-delete" 
                                       onclick="return confirm('Bạn có chắc chắn muốn xóa lịch chiếu này?')"
                                       title="Xóa">🗑️</a>
                                </div>
                            </td>
                        </tr>
                        <% } 
                        } else { %>
                        <tr>
                            <td colspan="8" style="text-align: center; color: #6b7280; padding: 40px;">
                                📝 Chưa có lịch chiếu nào. Hãy thêm lịch chiếu đầu tiên!
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>

                <!-- PHÂN TRANG -->
                <% if (schedules != null && !schedules.isEmpty() && totalPages > 1) { %>
                <div class="pagination">
                    
                    <!-- Thông tin trang -->
                    <div class="pagination-info">
                        Hiển thị <%= Math.min((currentPage-1)*pageSize + 1, totalRecords) %> - 
                        <%= Math.min(currentPage * pageSize, totalRecords) %> của <%= totalRecords %> lịch chiếu
                    </div>
                    
                    <!-- Nút phân trang -->
                    <div class="pagination-controls">
                        
                        <!-- Nút đầu trang -->
                        <a href="${pageContext.request.contextPath}/staff/schedules?page=1&pageSize=<%= pageSize %>" 
                           class="btn-small <%= currentPage == 1 ? "btn-disabled" : "btn-edit" %>"
                           <%= currentPage == 1 ? "onclick=\"return false;\"" : "" %>>
                            ⏮️
                        </a>
                        
                        <!-- Nút trang trước -->
                        <a href="${pageContext.request.contextPath}/staff/schedules?page=<%= currentPage - 1 %>&pageSize=<%= pageSize %>" 
                           class="btn-small <%= currentPage == 1 ? "btn-disabled" : "btn-edit" %>"
                           <%= currentPage == 1 ? "onclick=\"return false;\"" : "" %>>
                            ◀️
                        </a>
                        
                        <!-- Các trang -->
                        <div class="page-numbers">
                            <%
                                int startPage = Math.max(1, currentPage - 2);
                                int endPage = Math.min(totalPages, currentPage + 2);
                                
                                for (int i = startPage; i <= endPage; i++) {
                            %>
                            <a href="${pageContext.request.contextPath}/staff/schedules?page=<%= i %>&pageSize=<%= pageSize %>" 
                               class="btn-small <%= i == currentPage ? "btn-primary" : "btn-edit" %>"
                               style="<%= i == currentPage ? "background: #007bff; color: white;" : "" %>">
                                <%= i %>
                            </a>
                            <% } %>
                        </div>
                        
                        <!-- Nút trang sau -->
                        <a href="${pageContext.request.contextPath}/staff/schedules?page=<%= currentPage + 1 %>&pageSize=<%= pageSize %>" 
                           class="btn-small <%= currentPage == totalPages ? "btn-disabled" : "btn-edit" %>"
                           <%= currentPage == totalPages ? "onclick=\"return false;\"" : "" %>>
                            ▶️
                        </a>
                        
                        <!-- Nút cuối trang -->
                        <a href="${pageContext.request.contextPath}/staff/schedules?page=<%= totalPages %>&pageSize=<%= pageSize %>" 
                           class="btn-small <%= currentPage == totalPages ? "btn-disabled" : "btn-edit" %>"
                           <%= currentPage == totalPages ? "onclick=\"return false;\"" : "" %>>
                            ⏭️
                        </a>
                        
                    </div>
                    
                    <!-- Chọn số item mỗi trang -->
                    <div class="page-size-selector">
                        <label style="font-size: 14px; color: #6b7280;">Hiển thị:</label>
                        <select onchange="changePageSize(this.value)" style="padding: 5px; border-radius: 5px; border: 1px solid #ced4da;">
                            <option value="5" <%= pageSize == 5 ? "selected" : "" %>>5</option>
                            <option value="10" <%= pageSize == 10 ? "selected" : "" %>>10</option>
                            <option value="20" <%= pageSize == 20 ? "selected" : "" %>>20</option>
                            <option value="50" <%= pageSize == 50 ? "selected" : "" %>>50</option>
                        </select>
                    </div>
                </div>
                <% } %>
            </div>
        </div>
        
        <jsp:include page="../layout/StaffFooter.jsp"/>

        <script>
        function changePageSize(pageSize) {
            window.location.href = '${pageContext.request.contextPath}/staff/schedules?page=1&pageSize=' + pageSize;
        }
        </script>

    </body>
</html>