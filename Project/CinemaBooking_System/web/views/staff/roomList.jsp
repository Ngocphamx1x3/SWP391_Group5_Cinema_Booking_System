<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.Room, java.util.List"%>
<%
    List<Room> rooms = (List<Room>) request.getAttribute("rooms");
    String success = request.getParameter("success");
    String error = request.getParameter("error");
    String searchKeyword = (String) request.getAttribute("searchKeyword");
    String selectedScreenType = (String) request.getAttribute("selectedScreenType");
    
    // Set active page for sidebar highlighting
    request.setAttribute("activePage", "rooms");
    request.setAttribute("pageTitle", "🎭 Quản lý Phòng Chiếu");
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Quản lý Phòng Chiếu | Cinema Booking</title>
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

            @media (max-width: 768px) {
                .search-box form {
                    flex-direction: column;
                    align-items: stretch;
                }

                .search-box input,
                .search-box select {
                    min-width: 100%;
                }
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

            .screen-type-badge {
                padding: 4px 12px;
                border-radius: 6px;
                font-size: 11px;
                font-weight: 600;
                display: inline-block;
                margin: 2px;
            }

            .screen-2d {
                background: rgba(59, 130, 246, 0.2);
                color: #3b82f6;
                border: 1px solid rgba(59, 130, 246, 0.3);
            }

            .screen-3d {
                background: rgba(16, 185, 129, 0.2);
                color: #10b981;
                border: 1px solid rgba(16, 185, 129, 0.3);
            }

            .screen-imax {
                background: rgba(245, 158, 11, 0.2);
                color: #f59e0b;
                border: 1px solid rgba(245, 158, 11, 0.3);
            }

            .screen-4dx {
                background: rgba(139, 92, 246, 0.2);
                color: #8b5cf6;
                border: 1px solid rgba(139, 92, 246, 0.3);
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
                            out.print("✅ Thêm phòng chiếu thành công!");
                            break;
                        case "update":
                            out.print("✅ Cập nhật phòng chiếu thành công!");
                            break;
                        case "delete":
                            out.print("✅ Xóa phòng chiếu thành công!");
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
                <form method="GET" action="${pageContext.request.contextPath}/staff/rooms" class="search-box" id="searchForm">
                    <input type="text" name="keyword" 
                           placeholder="🔍 Tìm kiếm theo mã, tên, loại phòng..." 
                           value="<%= searchKeyword != null ? searchKeyword : "" %>">

                    <select name="type" id="screenTypeFilter">
                        <option value="">Tất cả loại phòng</option>
                        <option value="2D" <%= "2D".equals(selectedScreenType) ? "selected" : "" %>>2D Standard</option>
                        <option value="3D" <%= "3D".equals(selectedScreenType) ? "selected" : "" %>>3D</option>
                        <option value="IMAX" <%= "IMAX".equals(selectedScreenType) ? "selected" : "" %>>IMAX</option>
                        <option value="4DX" <%= "4DX".equals(selectedScreenType) ? "selected" : "" %>>4DX</option>
                    </select>

                    <button type="submit" class="btn">Tìm kiếm</button>
                    <a href="${pageContext.request.contextPath}/staff/rooms" class="btn btn-secondary">🔄 Reset</a>
                </form>
                <a href="${pageContext.request.contextPath}/staff/rooms?action=add" class="btn">➕ Thêm phòng chiếu</a>
            </div>

            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Mã phòng</th>
                            <th>Tên phòng</th>
                            <th>Loại màn hình</th>
                            <th>Hệ thống âm thanh</th>
                            <th>Sức chứa</th>
                            <th>Layout ghế</th>
                            <th>Trạng thái</th>
                            <th>Ngày tạo</th>
                            <th>Ngày cập nhật</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (rooms != null && !rooms.isEmpty()) { 
                            for (Room room : rooms) { 
                        %>
                        <tr>
                            <td>#<%= room.getId() %></td>
                            <td><strong><%= room.getCode() %></strong></td>
                            <td>
                                <strong><%= room.getName() %></strong>
                                <% if (room.getDescription() != null && !room.getDescription().isEmpty()) { %>
                                <br><small style="color: #6b7280;"><%= room.getDescription() %></small>
                                <% } %>
                            </td>
                            <td>
                                <span class="screen-type-badge screen-<%= room.getScreenType().toLowerCase() %>">
                                    <%= room.getScreenTypeText() %>
                                </span>
                            </td>
                            <td><%= room.getSoundSystem() %></td>
                            <td><%= room.getCapacity() %> ghế</td>
                            <td><%= room.getSeatRows() %> x <%= room.getSeatColumns() %></td>
                            <td>
                                <span class="status-badge <%= room.isStatus() ? "status-active" : "status-inactive" %>">
                                    <%= room.getStatusText() %>
                                </span>
                            </td>
                            <td>
                                <small style="color: #6b7280;">
                                    <%= room.getFormattedCreatedDate() %>
                                </small>
                            </td>
                            <td>
                                <small style="color: #6b7280;">
                                    <%= room.getFormattedUpdatedDate() %>
                                </small>
                            </td>
                            <td>
                                <div class="action-buttons">
                                    <a href="${pageContext.request.contextPath}/staff/rooms?action=edit&id=<%= room.getId() %>" 
                                       class="btn-small btn-edit" title="Chỉnh sửa">✏️</a>
                                    <a href="${pageContext.request.contextPath}/staff/rooms?action=delete&id=<%= room.getId() %>" 
                                       class="btn-small btn-delete" 
                                       onclick="return confirm('Bạn có chắc chắn muốn xóa phòng chiếu này?')"
                                       title="Xóa">🗑️</a>
                                </div>
                            </td>
                        </tr>
                        <% } 
                       } else { %>
                        <tr>
                            <td colspan="11" style="text-align: center; color: #6b7280; padding: 40px;">
                                📝 Chưa có phòng chiếu nào. Hãy thêm phòng chiếu đầu tiên!
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
        <script>
            document.getElementById('screenTypeFilter').addEventListener('change', function () {
                document.getElementById('searchForm').submit();
            });

            document.querySelector('.btn-secondary').addEventListener('click', function (e) {
                e.preventDefault();
                window.location.href = '${pageContext.request.contextPath}/staff/rooms';
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