<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.SeatType, java.util.List"%>
<%
    List<SeatType> seatTypes = (List<SeatType>) request.getAttribute("seatTypes");
    String success = request.getParameter("success");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Quản lý Loại Ghế | Cinema Booking</title>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <style>
            /* Kế thừa toàn bộ CSS từ dashboard và userManager */
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }

            body {
                font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
                background: linear-gradient(135deg, #0a0e27 0%, #1a1f3a 100%);
                color: #e4e9f0;
                min-height: 100vh;
            }

            /* ===== Sidebar ===== */
            .sidebar {
                position: fixed;
                top: 0;
                left: 0;
                width: 280px;
                height: 100vh;
                background: linear-gradient(180deg, #0f1419 0%, #1a1f2e 100%);
                backdrop-filter: blur(10px);
                border-right: 1px solid rgba(0, 255, 255, 0.1);
                display: flex;
                flex-direction: column;
                padding: 30px 0;
                box-shadow: 5px 0 30px rgba(0, 0, 0, 0.5);
                z-index: 1000;
            }

            .sidebar-logo {
                text-align: center;
                margin-bottom: 50px;
                padding: 0 25px;
            }

            .sidebar-logo h2 {
                font-size: 26px;
                font-weight: 700;
                background: linear-gradient(135deg, #00d4ff 0%, #0099ff 100%);
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
                letter-spacing: 1px;
            }

            .sidebar-logo p {
                font-size: 11px;
                color: #6b7280;
                margin-top: 5px;
                text-transform: uppercase;
                letter-spacing: 2px;
            }

            .sidebar nav {
                flex: 1;
                overflow-y: auto;
            }

            .sidebar a {
                color: #94a3b8;
                text-decoration: none;
                padding: 16px 30px;
                display: flex;
                align-items: center;
                gap: 15px;
                font-size: 15px;
                font-weight: 500;
                transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
                position: relative;
            }

            .sidebar a::before {
                content: '';
                position: absolute;
                left: 0;
                top: 0;
                height: 100%;
                width: 4px;
                background: linear-gradient(180deg, #00d4ff 0%, #0099ff 100%);
                transform: scaleY(0);
                transition: transform 0.3s ease;
            }

            .sidebar a:hover {
                background: rgba(0, 212, 255, 0.08);
                color: #00d4ff;
                padding-left: 35px;
            }

            .sidebar a:hover::before {
                transform: scaleY(1);
            }

            .sidebar a.active {
                background: rgba(0, 212, 255, 0.12);
                color: #00d4ff;
                padding-left: 35px;
            }

            .sidebar a.active::before {
                transform: scaleY(1);
            }

            .sidebar a.logout {
                margin-top: auto;
                background: rgba(239, 68, 68, 0.1);
                color: #ef4444;
                margin: 20px 20px 0;
                border-radius: 12px;
                justify-content: center;
            }

            .sidebar a.logout:hover {
                background: rgba(239, 68, 68, 0.2);
                padding-left: 30px;
            }

            /* ===== Header ===== */
            header {
                margin-left: 280px;
                background: rgba(15, 20, 25, 0.8);
                backdrop-filter: blur(20px);
                border-bottom: 1px solid rgba(0, 255, 255, 0.1);
                padding: 20px 40px;
                display: flex;
                justify-content: space-between;
                align-items: center;
                position: sticky;
                top: 0;
                z-index: 100;
            }

            header h1 {
                font-size: 28px;
                font-weight: 700;
                background: linear-gradient(135deg, #ffffff 0%, #00d4ff 100%);
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
            }

            .header-right {
                display: flex;
                align-items: center;
                gap: 35px;
            }

            .header-right span {
                font-weight: 500;
                color: #94a3b8;
                font-size: 14px;
                display: flex;
                align-items: center;
                gap: 8px;
            }

            /* ===== Content ===== */
            .content {
                margin-left: 280px;
                padding: 40px;
            }

            /* ===== Toolbar ===== */
            .toolbar {
                background: linear-gradient(135deg, rgba(15, 20, 25, 0.9) 0%, rgba(26, 31, 46, 0.9) 100%);
                backdrop-filter: blur(10px);
                border: 1px solid rgba(0, 255, 255, 0.15);
                border-radius: 20px;
                padding: 25px 30px;
                margin-bottom: 30px;
                display: flex;
                justify-content: space-between;
                align-items: center;
                flex-wrap: wrap;
                gap: 20px;
            }

            .search-box {
                display: flex;
                gap: 15px;
                flex: 1;
                min-width: 300px;
            }

            .search-box input {
                flex: 1;
                background: rgba(0, 212, 255, 0.05);
                border: 1px solid rgba(0, 255, 255, 0.2);
                border-radius: 12px;
                padding: 12px 20px;
                color: #e4e9f0;
                font-size: 14px;
                outline: none;
                transition: all 0.3s ease;
            }

            .search-box input:focus {
                border-color: #00d4ff;
                box-shadow: 0 0 20px rgba(0, 212, 255, 0.3);
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
                box-shadow: 0 8px 25px rgba(0, 212, 255, 0.4);
            }

            /* ===== Table Container ===== */
            .table-container {
                background: linear-gradient(135deg, rgba(15, 20, 25, 0.9) 0%, rgba(26, 31, 46, 0.9) 100%);
                backdrop-filter: blur(10px);
                border: 1px solid rgba(0, 255, 255, 0.15);
                border-radius: 20px;
                padding: 30px;
                overflow-x: auto;
            }

            table {
                width: 100%;
                border-collapse: collapse;
            }

            th {
                background: rgba(0, 212, 255, 0.08);
                color: #00d4ff;
                font-weight: 600;
                text-transform: uppercase;
                font-size: 12px;
                letter-spacing: 1px;
                padding: 15px;
                text-align: left;
                border-bottom: 2px solid rgba(0, 212, 255, 0.2);
            }

            td {
                padding: 18px 15px;
                border-bottom: 1px solid rgba(255, 255, 255, 0.05);
                color: #94a3b8;
                font-size: 14px;
            }

            tr:hover td {
                background: rgba(0, 212, 255, 0.05);
                color: #e4e9f0;
            }

            .color-sample {
                width: 20px;
                height: 20px;
                border-radius: 4px;
                display: inline-block;
                border: 2px solid rgba(255, 255, 255, 0.3);
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
                background: rgba(0, 212, 255, 0.2);
                color: #00d4ff;
                border: 1px solid rgba(0, 212, 255, 0.3);
            }

            .btn-edit:hover {
                background: rgba(0, 212, 255, 0.3);
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

            /* ===== Footer ===== */
            footer {
                background: rgba(15, 20, 25, 0.9);
                backdrop-filter: blur(10px);
                border-top: 1px solid rgba(0, 255, 255, 0.1);
                color: #6b7280;
                text-align: center;
                padding: 25px;
                margin-left: 280px;
                margin-top: 40px;
                font-size: 14px;
            }
        </style>
    </head>
    <body>

        <!-- Sidebar -->
        <div class="sidebar">
            <div class="sidebar-logo">
                <h2>🎬 CINEMA PRO</h2>
                <p>Admin Panel</p>
            </div>
            <nav>
                <a href="${pageContext.request.contextPath}/admindashboard">📊 Bảng điều khiển</a>
                <a href="${pageContext.request.contextPath}/views/admin/userManager.jsp">👥 Quản lý người dùng</a>
                <a href="${pageContext.request.contextPath}/admin/staff">🧑‍💼 Quản lý nhân viên</a>
                <a href="${pageContext.request.contextPath}/admin/cinemas">🏢 Quản lý rạp</a>
                <a href="${pageContext.request.contextPath}/admin/seat-types">💺 Quản lý loại ghế</a>
                <a href="${pageContext.request.contextPath}/admin/movies">🎞️ Quản lý phim</a>
                <a href="${pageContext.request.contextPath}/views/admin/paymentManager.jsp">💳 Quản lý thanh toán</a>
            </nav>
            <a href="${pageContext.request.contextPath}/logout" class="logout">🚪 Đăng xuất</a>
        </div>

        <!-- Header -->
        <header>
            <h1>💺 Quản lý Loại Ghế</h1>
            <div class="header-right">
                <span>👤 Admin: Nguyễn Văn A</span>
                <span>⏰ <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %></span>
            </div>
        </header>

        <!-- Main content -->
        <div class="content">

            <!-- Alert Messages -->
            <% if (success != null) { %>
            <div class="alert alert-success">
                <% 
                    switch(success) {
                        case "create": 
                            out.print("✅ Thêm loại ghế thành công!");
                            break;
                        case "update":
                            out.print("✅ Cập nhật loại ghế thành công!");
                            break;
                        case "delete":
                            out.print("✅ Xóa loại ghế thành công!");
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

            <!-- Toolbar -->
            <div class="toolbar">
                <form method="GET" action="${pageContext.request.contextPath}/admin/seat-types" class="search-box">
                    <input type="text" name="search" 
                           placeholder="🔍 Tìm kiếm theo mã, tên loại ghế..." 
                           value="${searchKeyword != null ? searchKeyword : ''}">
                    <button type="submit" style="
                            background: linear-gradient(135deg, #00d4ff 0%, #0099ff 100%);
                            color: white;
                            border: none;
                            border-radius: 12px;
                            padding: 12px 20px;
                            font-size: 14px;
                            font-weight: 600;
                            cursor: pointer;
                            transition: all 0.3s ease;
                            ">Tìm kiếm</button>
                    <a href="${pageContext.request.contextPath}/admin/seat-types" class="btn" style="
                       background: rgba(107, 114, 128, 0.3);
                       color: #e4e9f0;
                       border: 1px solid rgba(107, 114, 128, 0.5);
                       ">🔄 Reset</a>
                </form>
                <a href="${pageContext.request.contextPath}/admin/seat-types?action=add" class="btn">➕ Thêm loại ghế</a>
            </div>

            <!-- Seat Types Table -->
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Mã</th>
                            <th>Tên loại ghế</th>
                            <th>Phụ phí</th>
                            <th>Màu sắc</th>
                            <th>Mô tả</th>
                            <th>Trạng thái</th>
                            <th>Ngày tạo</th>
                            <th>Ngày cập nhật</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (seatTypes != null && !seatTypes.isEmpty()) { 
                            for (SeatType seatType : seatTypes) { 
                        %>
                        <tr>
                            <td>#<%= seatType.getId() %></td>
                            <td><strong><%= seatType.getCode() %></strong></td>
                            <td><%= seatType.getName() %></td>
                            <td><%= seatType.getFormattedSurcharge() %></td>
                            <td>
                                <div style="display: flex; align-items: center; gap: 10px;">
                                    <div class="color-sample" style="background-color: <%= seatType.getColor() %>;"></div>
                                    <span><%= seatType.getColor() %></span>
                                </div>
                            </td>
                            <td><%= seatType.getDescription() != null ? seatType.getDescription() : "" %></td>
                            <td>
                                <span class="status-badge <%= seatType.isStatus() ? "status-active" : "status-inactive" %>">
                                    <%= seatType.getStatusText() %>
                                </span>
                            </td>
                            <td>
                                <small style="color: #6b7280;">
                                    <%= seatType.getFormattedCreatedAt() %>
                                </small>
                            </td>
                            <td>
                                <small style="color: #6b7280;">
                                    <%= seatType.getFormattedUpdatedAt() %> <!-- HIỂN THỊ NGÀY CẬP NHẬT -->
                                </small>
                            </td>
                            <td>
                                <div class="action-buttons">
                                    <a href="${pageContext.request.contextPath}/admin/seat-types?action=edit&id=<%= seatType.getId() %>" 
                                       class="btn-small btn-edit">✏️ Sửa</a>
                                    <a href="${pageContext.request.contextPath}/admin/seat-types?action=delete&id=<%= seatType.getId() %>" 
                                       class="btn-small btn-delete" 
                                       onclick="return confirm('Bạn có chắc chắn muốn xóa loại ghế này?')">🗑️ Xóa</a>
                                </div>
                            </td>
                        </tr>
                        <% } 
                         } else { %>
                        <tr>
                            <td colspan="10" style="text-align: center; color: #6b7280; padding: 40px;">
                                📝 Chưa có loại ghế nào. Hãy thêm loại ghế đầu tiên!
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Footer -->
        <footer>
            © 2025 Cinema Booking System - Admin Panel | Powered by Modern Technology
        </footer>

    </body>
</html>