<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.Cinema, java.util.List"%>
<%
    List<Cinema> cinemas = (List<Cinema>) request.getAttribute("cinemas");
    String success = request.getParameter("success");
    String error = request.getParameter("error");
    String searchKeyword = (String) request.getAttribute("searchKeyword");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý Rạp Chiếu | Cinema Booking</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: #f4f7fa; 
            color: #2d3748; 
            min-height: 100vh;
        }

        /* ===== Sidebar ===== */
        .sidebar {
            position: fixed;
            top: 0;
            left: 0;
            width: 280px;
            height: 100vh;
            background: #ffffff; 
            border-right: 1px solid #e2e8f0; 
            display: flex;
            flex-direction: column;
            padding: 30px 0;
            box-shadow: 2px 0 15px rgba(0, 0, 0, 0.05); 
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
            color: #1a202c;
            background: none;
            -webkit-background-clip: unset;
            -webkit-text-fill-color: unset;
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
            color: #4a5568; 
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
            background: #e6f7ff; 
            color: #007bff; 
            padding-left: 35px;
        }

        .sidebar a:hover::before {
            transform: scaleY(1);
        }

        .sidebar a.active {
            background: #e6f7ff; 
            color: #007bff; 
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
            background: rgba(255, 255, 255, 0.8); 
            backdrop-filter: blur(20px);
            border-bottom: 1px solid #e2e8f0; 
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
            color: #1a202c; 
            background: none;
            -webkit-background-clip: unset;
            -webkit-text-fill-color: unset;
        }

        .header-right {
            display: flex;
            align-items: center;
            gap: 35px;
        }

        .header-right span {
            font-weight: 500;
            color: #4a5568; 
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

        .btn-manage {
            background: rgba(255, 193, 7, 0.2);
            color: #ffc107;
            border: 1px solid rgba(255, 193, 7, 0.3);
        }

        .btn-manage:hover {
            background: rgba(255, 193, 7, 0.3);
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
        }
    </style>
</head>
<body>

    <div class="sidebar">
        <div class="sidebar-logo">
            <h2>🎬 CINEMA PRO</h2>
            <p>Admin Panel</p>
        </div>
        <nav>
            <a href="${pageContext.request.contextPath}/admindashboard">📊 Bảng điều khiển</a>
            <a href="${pageContext.request.contextPath}/views/admin/userManager.jsp">👥 Quản lý người dùng</a>
            <a href="${pageContext.request.contextPath}/admin/staff">🧑‍💼 Quản lý nhân viên</a>
            <a href="${pageContext.request.contextPath}/admin/cinemas" class="active">🏢 Quản lý rạp</a>
            <a href="${pageContext.request.contextPath}/admin/movies">🎞️ Quản lý phim</a>
            <a href="${pageContext.request.contextPath}/admin/seat-types">💺 Quản lý loại ghế</a>
            <a href="${pageContext.request.contextPath}/views/admin/paymentManager.jsp">💳 Quản lý thanh toán</a>
        </nav>
        <a href="${pageContext.request.contextPath}/logout" class="logout">🚪 Đăng xuất</a>
    </div>

    <header>
        <h1>🏢 Quản lý Rạp Chiếu</h1>
        <div class="header-right">
            <span>👤 Admin: Nguyễn Văn A</span>
            <span>⏰ <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %></span>
        </div>
    </header>

    <div class="content">

        <% if (success != null) { %>
        <div class="alert alert-success">
            <% 
                switch(success) {
                    case "create": 
                        out.print("✅ Thêm rạp chiếu thành công!");
                        break;
                    case "update":
                        out.print("✅ Cập nhật rạp chiếu thành công!");
                        break;
                    case "delete":
                        out.print("✅ Xóa rạp chiếu thành công!");
                        break;
                    case "assign":
                        out.print("✅ Phân công nhân viên thành công!");
                        break;
                    case "update-assignment":
                        out.print("✅ Cập nhật phân công thành công!");
                        break;
                    case "remove-staff":
                        out.print("✅ Gỡ phân công nhân viên thành công!");
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
            <form method="GET" action="${pageContext.request.contextPath}/admin/cinemas" class="search-box">
                <input type="text" name="search" 
                       placeholder="🔍 Tìm kiếm theo mã, tên, địa chỉ rạp..." 
                       value="<%= searchKeyword != null ? searchKeyword : "" %>">
                <button type="submit" class="btn">Tìm kiếm</button>
                <a href="${pageContext.request.contextPath}/admin/cinemas" class="btn" style="
                   background: #6c757d; /* Nền xám */
                   color: #ffffff; /* Chữ trắng */
                   border: 1px solid #6c757d;
                   ">🔄 Reset</a>
            </form>
            <a href="${pageContext.request.contextPath}/admin/cinemas?action=add" class="btn">➕ Thêm rạp chiếu</a>
        </div>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Mã</th>
                        <th>Tên rạp</th>
                        <th>Địa chỉ</th>
                        <th>Sức chứa</th>
                        <th>Số phòng</th>
                        <th>Điện thoại</th>
                        <th>Giờ hoạt động</th>
                        <th>Trạng thái</th>
                        <th>Ngày tạo</th>
                        <th>Ngày cập nhật</th>
                        <th>Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (cinemas != null && !cinemas.isEmpty()) { 
                        for (Cinema cinema : cinemas) { 
                    %>
                    <tr>
                        <td>#<%= cinema.getId() %></td>
                        <td><strong><%= cinema.getCode() %></strong></td>
                        <td>
                            <strong><%= cinema.getName() %></strong>
                            <% if (cinema.getDescription() != null && !cinema.getDescription().isEmpty()) { %>
                                <br><small style="color: #6b7280;"><%= cinema.getDescription() %></small>
                            <% } %>
                        </td>
                        <td><%= cinema.getAddress() %></td>
                        <td><%= cinema.getFormattedCapacity() %></td>
                        <td><%= cinema.getTotalRooms() %> phòng</td>
                        <td><%= cinema.getPhone() %></td>
                        <td><%= cinema.getOperatingHours() %></td>
                        <td>
                            <span class="status-badge <%= cinema.isStatus() ? "status-active" : "status-inactive" %>">
                                <%= cinema.getStatusText() %>
                            </span>
                        </td>
                        <td>
                            <small style="color: #6b7280;">
                                <%= cinema.getFormattedCreatedDate() %>
                            </small>
                        </td>
                        <td>
                            <small style="color: #6b7280;">
                                <%= cinema.getFormattedUpdatedDate() %>
                            </small>
                        </td>
                        <td>
                            <div class="action-buttons">
                                <a href="${pageContext.request.contextPath}/admin/cinemas?action=manage-staff&id=<%= cinema.getId() %>" 
                                   class="btn-small btn-manage" title="Quản lý nhân viên">👥</a>
                                <a href="${pageContext.request.contextPath}/admin/cinemas?action=edit&id=<%= cinema.getId() %>" 
                                   class="btn-small btn-edit" title="Chỉnh sửa">✏️</a>
                                <a href="${pageContext.request.contextPath}/admin/cinemas?action=delete&id=<%= cinema.getId() %>" 
                                   class="btn-small btn-delete" 
                                   onclick="return confirm('Bạn có chắc chắn muốn xóa rạp chiếu này?')"
                                   title="Xóa">🗑️</a>
                            </div>
                        </td>
                    </tr>
                    <% } 
                       } else { %>
                    <tr>
                        <td colspan="12" style="text-align: center; color: #6b7280; padding: 40px;">
                            📝 Chưa có rạp chiếu nào. Hãy thêm rạp chiếu đầu tiên!
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>

    <footer>
        © 2025 Cinema Booking System - Admin Panel | Powered by Modern Technology
    </footer>

</body>
</html>