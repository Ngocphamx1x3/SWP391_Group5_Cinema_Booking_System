<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.CinemaStaff"%>
<%
    CinemaStaff assignment = (CinemaStaff) request.getAttribute("assignment");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chỉnh sửa Phân công | Cinema Booking</title>
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

        /* ===== Form Container ===== */
        .form-container {
            background: #ffffff; /* Nền trắng */
            border: 1px solid #e2e8f0; /* Viền xám nhạt */
            border-radius: 20px;
            padding: 40px;
            max-width: 600px;
            margin: 0 auto;
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.05); /* Bóng đổ nhẹ */
        }

        .form-header {
            text-align: center;
            margin-bottom: 40px;
        }

        .form-header h2 {
            font-size: 24px;
            font-weight: 700;
            color: #1a202c; /* Chữ đen/tối */
            background: none;
            -webkit-background-clip: unset;
            -webkit-text-fill-color: unset;
            margin-bottom: 10px;
        }

        .form-header p {
            color: #6b7280;
            font-size: 14px;
        }

        /* ===== Assignment Info ===== */
        .assignment-info {
            background: #f8f9fa; /* Nền xám rất nhạt */
            border: 1px solid #e2e8f0; /* Viền xám nhạt */
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 30px;
        }

        .info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
        }

        .info-item {
            display: flex;
            flex-direction: column;
            gap: 5px;
        }

        .info-label {
            color: #6b7280; /* Chữ xám trung bình */
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .info-value {
            color: #2d3748; /* Chữ tối */
            font-size: 14px;
            font-weight: 500;
        }

        /* ===== Form Styles ===== */
        .form-group {
            margin-bottom: 25px;
        }

        .form-group label {
            display: block;
            color: #4a5568; /* Chữ xám tối */
            font-size: 13px;
            font-weight: 600;
            margin-bottom: 8px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .form-group select {
            width: 100%;
            background: #ffffff; /* Nền trắng */
            border: 1px solid #ced4da; /* Viền xám */
            border-radius: 12px;
            padding: 14px 16px;
            color: #2d3748; /* Chữ tối */
            font-size: 14px;
            outline: none;
            transition: all 0.3s ease;
            font-family: 'Inter', sans-serif;
        }
        
        .form-group select option {
            color: #333;
            background-color: #fff;
        }

        .form-group select:focus {
            border-color: #007bff; /* Viền xanh khi focus */
            box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.25); /* Focus ring */
        }

        .checkbox-group {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-top: 10px;
        }

        .checkbox-group input[type="checkbox"] {
            width: 18px;
            height: 18px;
            accent-color: #007bff; /* Màu nhấn xanh */
        }

        .checkbox-group label {
            margin-bottom: 0;
            text-transform: none;
            letter-spacing: normal;
            font-size: 14px;
            color: #2d3748; /* Chữ tối */
        }

        /* ===== Form Actions ===== */
        .form-actions {
            display: flex;
            gap: 15px;
            margin-top: 40px;
            padding-top: 30px;
            border-top: 1px solid #e2e8f0; /* Viền xám nhạt */
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

        .btn-primary:hover {
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
            transform: translateY(-2px);
        }

        /* ===== Alert Messages ===== */
        .alert {
            padding: 15px 20px;
            border-radius: 12px;
            margin-bottom: 25px;
            font-weight: 600;
        }

        .alert-error {
            background: rgba(239, 68, 68, 0.2);
            color: #ef4444;
            border: 1px solid rgba(239, 68, 68, 0.3);
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
            <h2>🎬 CINEMA PRO</h2>
            <p>Admin Panel</p>
        </div>
        <nav>
            <a href="${pageContext.request.contextPath}/admindashboard">📊 Bảng điều khiển</a>
            <a href="${pageContext.request.contextPath}/views/admin/userManager.jsp">👥 Quản lý người dùng</a>
            <a href="${pageContext.request.contextPath}/admin/staff">🧑‍💼 Quản lý nhân viên</a>
            <a href="${pageContext.request.contextPath}/admin/cinemas" class="active">🏢 Quản lý rạp</a>
            <a href="${pageContext.request.contextPath}/admin/seat-types">💺 Quản lý loại ghế</a>
            <a href="${pageContext.request.contextPath}/views/admin/paymentManager.jsp">💳 Quản lý thanh toán</a>
        </nav>
        <a href="${pageContext.request.contextPath}/logout" class="logout">🚪 Đăng xuất</a>
    </div>

    <header>
        <h1>✏️ Chỉnh sửa Phân công</h1>
        <div class="header-right">
            <span>👤 Admin: Nguyễn Văn A</span>
            <span>⏰ <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %></span>
        </div>
    </header>

    <div class="content">
        <div class="form-container">
            <div class="form-header">
                <h2>Chỉnh sửa Phân công Nhân viên</h2>
                <p>Cập nhật vai trò và trạng thái phân công</p>
            </div>

            <% if (error != null) { %>
                <div class="alert alert-error">
                    ❌ <%= error %>
                </div>
            <% } %>

            <div class="assignment-info">
                <div class="info-grid">
                    <div class="info-item">
                        <span class="info-label">Nhân viên</span>
                        <span class="info-value"><%= assignment.getStaffName() %></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Email</span>
                        <span class="info-value"><%= assignment.getStaffEmail() %></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Rạp chiếu</span>
                        <span class="info-value"><%= assignment.getCinemaName() %></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Ngày phân công</span>
                        <span class="info-value"><%= assignment.getFormattedAssignedAt() %></span>
                    </div>
                </div>
            </div>

            <form action="${pageContext.request.contextPath}/admin/cinemas" method="post" id="editForm">
                <input type="hidden" name="action" value="update-assignment">
                <input type="hidden" name="assignmentId" value="<%= assignment.getId() %>">

                <div class="form-group">
                    <label for="roleInCinema" class="required">Vai trò tại rạp</label>
                    <select id="roleInCinema" name="roleInCinema" required>
                        <option value="manager" <%= "manager".equals(assignment.getRoleInCinema()) ? "selected" : "" %>>Quản lý rạp</option>
                        <option value="supervisor" <%= "supervisor".equals(assignment.getRoleInCinema()) ? "selected" : "" %>>Giám sát</option>
                        <option value="staff" <%= "staff".equals(assignment.getRoleInCinema()) ? "selected" : "" %>>Nhân viên</option>
                        <option value="cashier" <%= "cashier".equals(assignment.getRoleInCinema()) ? "selected" : "" %>>Thu ngân</option>
                        <option value="technician" <%= "technician".equals(assignment.getRoleInCinema()) ? "selected" : "" %>>Kỹ thuật viên</option>
                    </select>
                </div>

                <div class="form-group">
                    <label>Trạng thái phân công</label>
                    <div class="checkbox-group">
                        <input type="checkbox" id="status" name="status" <%= assignment.isStatus() ? "checked" : "" %>>
                        <label for="status">Đang làm việc</label>
                    </div>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">
                        💾 Cập nhật
                    </button>
                    <a href="${pageContext.request.contextPath}/admin/cinemas?action=manage-staff&id=<%= assignment.getCinemaId() %>" class="btn btn-secondary">
                        ↩️ Quay lại
                    </a>
                </div>
            </form>
        </div>
    </div>

    <footer>
        © 2025 Cinema Booking System - Admin Panel | Powered by Modern Technology
    </footer>

    <script>
        // Form validation
        document.getElementById('editForm').addEventListener('submit', function(e) {
            const roleInCinema = document.getElementById('roleInCinema').value;
            
            if (!roleInCinema) {
                alert('Vui lòng chọn vai trò');
                e.preventDefault();
                return;
            }
        });
    </script>

</body>
</html>