<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.Cinema, model.CinemaStaff, java.util.List"%>
<%
    Cinema cinema = (Cinema) request.getAttribute("cinema");
    List<CinemaStaff> staffAssignments = (List<CinemaStaff>) request.getAttribute("staffAssignments");
    String success = request.getParameter("success");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý Nhân viên - <%= cinema.getName() %> | Cinema Booking</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: #f4f7fa; /* Nền sáng */
            color: #2d3748; /* Chữ tối */
            min-height: 100vh;
        }

        /* ===== Sidebar ===== */
        .sidebar {
            position: fixed;
            top: 0;
            left: 0;
            width: 280px;
            height: 100vh;
            background: #ffffff; /* Nền trắng */
            border-right: 1px solid #e2e8f0; /* Viền xám nhạt */
            display: flex;
            flex-direction: column;
            padding: 30px 0;
            box-shadow: 2px 0 15px rgba(0, 0, 0, 0.05); /* Bóng đổ nhẹ */
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
            color: #1a202c; /* Chữ đen/tối */
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
            color: #4a5568; /* Chữ xám tối */
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
            background: #e6f7ff; /* Nền xanh nhạt khi hover */
            color: #007bff; /* Chữ xanh đậm khi hover */
            padding-left: 35px;
        }

        .sidebar a:hover::before {
            transform: scaleY(1);
        }

        .sidebar a.active {
            background: #e6f7ff; /* Nền xanh nhạt */
            color: #007bff; /* Chữ xanh đậm */
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
            background: rgba(255, 255, 255, 0.8); /* Nền trắng mờ */
            backdrop-filter: blur(20px);
            border-bottom: 1px solid #e2e8f0; /* Viền xám nhạt */
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
            color: #1a202c; /* Chữ đen/tối */
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
            color: #4a5568; /* Chữ xám tối */
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

        /* ===== Cinema Info Card ===== */
        .cinema-info {
            background: #ffffff; /* Nền trắng */
            border: 1px solid #e2e8f0; /* Viền xám nhạt */
            border-radius: 20px;
            padding: 30px;
            margin-bottom: 30px;
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.05);
        }

        .cinema-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            flex-wrap: wrap;
            gap: 20px;
        }

        .cinema-title {
            flex: 1;
        }

        .cinema-title h2 {
            font-size: 24px;
            font-weight: 700;
            color: #1a202c; /* Chữ đen/tối */
            background: none;
            -webkit-background-clip: unset;
            -webkit-text-fill-color: unset;
            margin-bottom: 5px;
        }

        .cinema-title p {
            color: #6b7280;
            font-size: 14px;
        }

        .cinema-details {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }

        .detail-item {
            display: flex;
            flex-direction: column;
            gap: 5px;
        }

        .detail-label {
            color: #6b7280; /* Chữ xám trung bình */
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .detail-value {
            color: #2d3748; /* Chữ tối */
            font-size: 14px;
            font-weight: 500;
        }

        /* ===== Toolbar ===== */
        .toolbar {
            background: #ffffff; /* Nền trắng */
            border: 1px solid #e2e8f0; /* Viền xám nhạt */
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
        
        .toolbar h3 {
            color: #1a202c; /* Chữ đen/tối */
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
            box-shadow: 0 8px 25px rgba(0, 123, 255, 0.3); /* Bóng đổ xanh */
        }

        .btn-secondary {
            background: #6c757d; /* Nền xám */
            color: #ffffff; /* Chữ trắng */
            border: 1px solid #6c757d;
        }

        .btn-secondary:hover {
            background: #5a6268; /* Nền xám đậm hơn */
        }

        /* ===== Table Container ===== */
        .table-container {
            background: #ffffff; /* Nền trắng */
            border: 1px solid #e2e8f0; /* Viền xám nhạt */
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
            background: #f8f9fa; /* Nền xám nhạt */
            color: #4a5568; /* Chữ xám tối */
            font-weight: 600;
            text-transform: uppercase;
            font-size: 12px;
            letter-spacing: 1px;
            padding: 15px;
            text-align: left;
            border-bottom: 2px solid #dee2e6; /* Viền xám đậm hơn */
        }

        td {
            padding: 18px 15px;
            border-bottom: 1px solid #e2e8f0; /* Viền xám nhạt */
            color: #2d3748; /* Chữ tối */
            font-size: 14px;
        }

        tr:hover td {
            background: #f8f9fa; /* Nền xám nhạt khi hover */
            color: #1a202c; /* Chữ đen/tối */
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
            background: rgba(0, 123, 255, 0.2); /* Đổi sang xanh dương nhạt */
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

        /* ===== Empty State ===== */
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #6b7280;
        }

        .empty-state i {
            font-size: 48px;
            margin-bottom: 20px;
            display: block;
        }

        .empty-state h3 {
            font-size: 18px;
            margin-bottom: 10px;
            color: #4a5568; /* Chữ xám tối */
        }

        .empty-state p {
            font-size: 14px;
            margin-bottom: 20px;
        }
        .toolbar select option {
            color: #333;
            background-color: #fff;
        }

        /* ===== Footer ===== */
        footer {
            background: #ffffff; /* Nền trắng */
            border-top: 1px solid #e2e8f0; /* Viền xám nhạt */
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

    <div class="sidebar">
        <div class="sidebar-logo">
            <h2>CINEMA PRO</h2>
            <p>Admin Panel</p>
        </div>
        <nav>
            <a href="${pageContext.request.contextPath}/admindashboard">Bảng điều khiển</a>
            <a href="${pageContext.request.contextPath}/views/admin/userManager.jsp">Quản lý người dùng</a>
            <a href="${pageContext.request.contextPath}/admin/staff">Quản lý nhân viên</a>
            <a href="${pageContext.request.contextPath}/admin/cinemas" class="active">Quản lý rạp</a>
            <a href="${pageContext.request.contextPath}/admin/seat-types">Quản lý loại ghế</a>
            <a href="${pageContext.request.contextPath}/views/admin/paymentManager.jsp">Quản lý thanh toán</a>
            <a href="${pageContext.request.contextPath}/admin/vouchers">Quản lý Voucher</a>
        </nav>
        <a href="${pageContext.request.contextPath}/logout" class="logout">Đăng xuất</a>
    </div>

    <header>
        <h1>Quản lý Nhân viên - <%= cinema.getName() %></h1>
        <div class="header-right">
            <span>Admin: Nguyễn Văn A</span>
            <span><%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %></span>
        </div>
    </header>

    <div class="content">

        <% if (success != null) { %>
        <div class="alert alert-success">
            <% 
                switch(success) {
                    case "assign": 
                        out.print("Phân công nhân viên thành công!");
                        break;
                    case "update-assignment":
                        out.print("Cập nhật phân công thành công!");
                        break;
                    case "remove-staff":
                        out.print("Gỡ phân công nhân viên thành công!");
                        break;
                }
            %>
        </div>
        <% } %>

        <% if (error != null) { %>
        <div class="alert alert-error">
            Có lỗi xảy ra khi xử lý!
        </div>
        <% } %>

        <div class="cinema-info">
            <div class="cinema-header">
                <div class="cinema-title">
                    <h2><%= cinema.getName() %></h2>
                    <p><%= cinema.getCode() %> - <%= cinema.getAddress() %></p>
                </div>
                <a href="${pageContext.request.contextPath}/admin/cinemas" class="btn btn-secondary">Quay lại danh sách</a>
            </div>
            <div class="cinema-details">
                <div class="detail-item">
                    <span class="detail-label">Sức chứa</span>
                    <span class="detail-value"><%= cinema.getFormattedCapacity() %></span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Số phòng</span>
                    <span class="detail-value"><%= cinema.getTotalRooms() %> phòng</span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Điện thoại</span>
                    <span class="detail-value"><%= cinema.getPhone() %></span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Giờ hoạt động</span>
                    <span class="detail-value"><%= cinema.getOperatingHours() %></span>
                </div>
            </div>
        </div>

        <div class="toolbar">
            <div>
                <h3 style="margin-bottom: 5px;">Danh sách nhân viên</h3>
                <p style="color: #6b7280; font-size: 14px;">Quản lý phân công nhân viên cho rạp chiếu</p>
            </div>
            <a href="${pageContext.request.contextPath}/admin/cinemas?action=assign-staff&cinemaId=<%= cinema.getId() %>" class="btn">Phân công nhân viên</a>
        </div>

        <div class="table-container">
            <% if (staffAssignments != null && !staffAssignments.isEmpty()) { %>
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Tên nhân viên</th>
                        <th>Email</th>
                        <th>Vai trò</th>
                        <th>Ngày phân công</th>
                        <th>Trạng thái</th>
                        <th>Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (CinemaStaff assignment : staffAssignments) { %>
                    <tr>
                        <td>#<%= assignment.getId() %></td>
                        <td>
                            <strong><%= assignment.getStaffName() %></strong>
                        </td>
                        <td><%= assignment.getStaffEmail() %></td>
                        <td>
                            <span style="background: rgba(139, 92, 246, 0.2); color: #8b5cf6; padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 600;">
                                <%= assignment.getRoleInCinema() %>
                            </span>
                        </td>
                        <td>
                            <small style="color: #6b7280;">
                                <%= assignment.getFormattedAssignedAt() %>
                            </small>
                        </td>
                        <td>
                            <span class="status-badge <%= assignment.isStatus() ? "status-active" : "status-inactive" %>">
                                <%= assignment.getStatusText() %>
                            </span>
                        </td>
                        <td>
                            <div class="action-buttons">
                                <a href="${pageContext.request.contextPath}/admin/cinemas?action=edit-assignment&assignmentId=<%= assignment.getId() %>" 
                                   class="btn-small btn-edit" title="Chỉnh sửa phân công">Sửa</a>
                                <a href="${pageContext.request.contextPath}/admin/cinemas?action=remove-staff&assignmentId=<%= assignment.getId() %>&cinemaId=<%= cinema.getId() %>" 
                                   class="btn-small btn-delete" 
                                   onclick="return confirm('Bạn có chắc chắn muốn gỡ phân công nhân viên này?')"
                                   title="Gỡ phân công">Xóa</a>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
            <% } else { %>
            <div class="empty-state">
                <i>👥</i>
                <h3>Chưa có nhân viên nào được phân công</h3>
                <p>Hãy phân công nhân viên đầu tiên cho rạp chiếu này</p>
                <a href="${pageContext.request.contextPath}/admin/cinemas?action=assign-staff&cinemaId=<%= cinema.getId() %>" class="btn">➕ Phân công nhân viên đầu tiên</a>
            </div>
            <% } %>
        </div>
    </div>

    <footer>
        © 2025 Cinema Booking System - Admin Panel | Powered by Modern Technology
    </footer>

</body>
</html>