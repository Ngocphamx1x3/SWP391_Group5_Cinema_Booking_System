<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.Cinema"%>
<%
    Cinema cinema = (Cinema) request.getAttribute("cinema");
    boolean isEdit = cinema != null;
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title><%= isEdit ? "Chỉnh sửa" : "Thêm mới" %> Rạp Chiếu | Cinema Booking</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        /* Kế thừa toàn bộ CSS từ các trang trước */
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

        /* ===== Form Container ===== */
        .form-container {
            background: linear-gradient(135deg, rgba(15, 20, 25, 0.9) 0%, rgba(26, 31, 46, 0.9) 100%);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(0, 255, 255, 0.15);
            border-radius: 20px;
            padding: 40px;
            max-width: 800px;
            margin: 0 auto;
        }

        .form-header {
            text-align: center;
            margin-bottom: 40px;
        }

        .form-header h2 {
            font-size: 24px;
            font-weight: 700;
            background: linear-gradient(135deg, #ffffff 0%, #00d4ff 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 10px;
        }

        .form-header p {
            color: #6b7280;
            font-size: 14px;
        }

        /* ===== Form Styles ===== */
        .form-group {
            margin-bottom: 25px;
        }

        .form-group label {
            display: block;
            color: #94a3b8;
            font-size: 13px;
            font-weight: 600;
            margin-bottom: 8px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%;
            background: rgba(0, 212, 255, 0.05);
            border: 1px solid rgba(0, 255, 255, 0.2);
            border-radius: 12px;
            padding: 14px 16px;
            color: #e4e9f0;
            font-size: 14px;
            outline: none;
            transition: all 0.3s ease;
            font-family: 'Inter', sans-serif;
        }

        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            border-color: #00d4ff;
            box-shadow: 0 0 20px rgba(0, 212, 255, 0.3);
        }

        .form-group textarea {
            resize: vertical;
            min-height: 80px;
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }

        .form-row-3 {
            display: grid;
            grid-template-columns: 1fr 1fr 1fr;
            gap: 20px;
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
            accent-color: #00d4ff;
        }

        .checkbox-group label {
            margin-bottom: 0;
            text-transform: none;
            letter-spacing: normal;
            font-size: 14px;
            color: #e4e9f0;
        }

        /* ===== Form Actions ===== */
        .form-actions {
            display: flex;
            gap: 15px;
            margin-top: 40px;
            padding-top: 30px;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
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
            box-shadow: 0 8px 25px rgba(0, 212, 255, 0.4);
        }

        .btn-secondary {
            background: rgba(107, 114, 128, 0.3);
            color: #e4e9f0;
            border: 1px solid rgba(107, 114, 128, 0.5);
        }

        .btn-secondary:hover {
            background: rgba(107, 114, 128, 0.5);
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

        /* ===== Required Field ===== */
        .required::after {
            content: " *";
            color: #ef4444;
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
            .form-row, .form-row-3 {
                grid-template-columns: 1fr;
            }
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
            <a href="${pageContext.request.contextPath}/admin/cinemas" class="active">🏢 Quản lý rạp</a>
            <a href="${pageContext.request.contextPath}/admin/seat-types">💺 Quản lý loại ghế</a>
            <a href="${pageContext.request.contextPath}/views/admin/paymentManager.jsp">💳 Quản lý thanh toán</a>
        </nav>
        <a href="${pageContext.request.contextPath}/logout" class="logout">🚪 Đăng xuất</a>
    </div>

    <!-- Header -->
    <header>
        <h1><%= isEdit ? "✏️ Chỉnh sửa Rạp Chiếu" : "➕ Thêm Rạp Chiếu Mới" %></h1>
        <div class="header-right">
            <span>👤 Admin: Nguyễn Văn A</span>
            <span>⏰ <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %></span>
        </div>
    </header>

    <!-- Main content -->
    <div class="content">
        <div class="form-container">
            <!-- Form Header -->
            <div class="form-header">
                <h2><%= isEdit ? "Chỉnh sửa Thông Tin Rạp Chiếu" : "Thêm Rạp Chiếu Mới" %></h2>
                <p><%= isEdit ? "Cập nhật thông tin rạp chiếu hiện có" : "Điền đầy đủ thông tin để thêm rạp chiếu mới" %></p>
            </div>

            <!-- Error Message -->
            <% if (error != null) { %>
                <div class="alert alert-error">
                    ❌ <%= error %>
                </div>
            <% } %>

            <!-- Form -->
            <form action="${pageContext.request.contextPath}/admin/cinemas" method="post" id="cinemaForm">
                <% if (isEdit) { %>
                    <input type="hidden" name="id" value="<%= cinema.getId() %>">
                <% } %>
                <input type="hidden" name="action" value="<%= isEdit ? "update" : "create" %>">

                <div class="form-row">
                    <!-- Mã rạp -->
                    <div class="form-group">
                        <label for="code" class="required">Mã rạp</label>
                        <input type="text" id="code" name="code" 
                               value="<%= isEdit ? cinema.getCode() : "" %>" 
                               placeholder="VD: LOTTE_HL, CGV_LB, GALAXY_TH"
                               required>
                    </div>

                    <!-- Tên rạp -->
                    <div class="form-group">
                        <label for="name" class="required">Tên rạp</label>
                        <input type="text" id="name" name="name" 
                               value="<%= isEdit ? cinema.getName() : "" %>" 
                               placeholder="VD: Lotte Hòa Lạc, CGV Long Biên"
                               required>
                    </div>
                </div>

                <!-- Địa chỉ -->
                <div class="form-group">
                    <label for="address" class="required">Địa chỉ</label>
                    <input type="text" id="address" name="address" 
                           value="<%= isEdit ? cinema.getAddress() : "" %>" 
                           placeholder="VD: Tầng 4, Vincom Long Biên, Quận Long Biên, Hà Nội"
                           required>
                </div>

                <!-- Mô tả -->
                <div class="form-group">
                    <label for="description">Mô tả</label>
                    <textarea id="description" name="description" 
                              placeholder="Mô tả chi tiết về rạp chiếu, tiện ích, đặc điểm..."><%= isEdit ? cinema.getDescription() : "" %></textarea>
                </div>

                <div class="form-row-3">
                    <!-- Sức chứa -->
                    <div class="form-group">
                        <label for="capacity" class="required">Sức chứa</label>
                        <input type="number" id="capacity" name="capacity" 
                               value="<%= isEdit ? cinema.getCapacity() : "500" %>" 
                               min="1" max="5000" 
                               placeholder="500"
                               required>
                    </div>

                    <!-- Số phòng -->
                    <div class="form-group">
                        <label for="totalRooms" class="required">Số phòng</label>
                        <input type="number" id="totalRooms" name="totalRooms" 
                               value="<%= isEdit ? cinema.getTotalRooms() : "3" %>" 
                               min="1" max="20"
                               placeholder="3"
                               required>
                    </div>

                    <!-- Điện thoại -->
                    <div class="form-group">
                        <label for="phone" class="required">Điện thoại</label>
                        <input type="text" id="phone" name="phone" 
                               value="<%= isEdit ? cinema.getPhone() : "" %>" 
                               placeholder="VD: 024 1234 5678"
                               required>
                    </div>
                </div>

                <!-- Giờ hoạt động -->
                <div class="form-group">
                    <label for="operatingHours" class="required">Giờ hoạt động</label>
                    <input type="text" id="operatingHours" name="operatingHours" 
                           value="<%= isEdit ? cinema.getOperatingHours() : "8:00 - 23:00 hàng ngày" %>" 
                           placeholder="VD: 8:00 - 23:00 hàng ngày"
                           required>
                </div>

                <!-- Trạng thái -->
                <div class="form-group">
                    <label>Trạng thái</label>
                    <div class="checkbox-group">
                        <input type="checkbox" id="status" name="status" 
                               <%= isEdit ? (cinema.isStatus() ? "checked" : "") : "checked" %>>
                        <label for="status">Đang hoạt động</label>
                    </div>
                </div>

                <!-- Form Actions -->
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">
                        <%= isEdit ? "💾 Cập nhật" : "➕ Thêm mới" %>
                    </button>
                    <a href="${pageContext.request.contextPath}/admin/cinemas" class="btn btn-secondary">
                        ↩️ Quay lại
                    </a>
                </div>
            </form>
        </div>
    </div>

    <!-- Footer -->
    <footer>
        © 2025 Cinema Booking System - Admin Panel | Powered by Modern Technology
    </footer>

    <!-- JavaScript -->
    <script>
        // Form validation
        document.getElementById('cinemaForm').addEventListener('submit', function(e) {
            const code = document.getElementById('code').value.trim();
            const name = document.getElementById('name').value.trim();
            const address = document.getElementById('address').value.trim();
            const capacity = document.getElementById('capacity').value;
            const totalRooms = document.getElementById('totalRooms').value;
            const phone = document.getElementById('phone').value.trim();
            const operatingHours = document.getElementById('operatingHours').value.trim();
            
            if (!code) {
                alert('Vui lòng nhập mã rạp');
                e.preventDefault();
                return;
            }
            
            if (!name) {
                alert('Vui lòng nhập tên rạp');
                e.preventDefault();
                return;
            }
            
            if (!address) {
                alert('Vui lòng nhập địa chỉ');
                e.preventDefault();
                return;
            }
            
            if (capacity < 1) {
                alert('Sức chứa phải lớn hơn 0');
                e.preventDefault();
                return;
            }
            
            if (totalRooms < 1) {
                alert('Số phòng phải lớn hơn 0');
                e.preventDefault();
                return;
            }
            
            if (!phone) {
                alert('Vui lòng nhập số điện thoại');
                e.preventDefault();
                return;
            }
            
            if (!operatingHours) {
                alert('Vui lòng nhập giờ hoạt động');
                e.preventDefault();
                return;
            }
        });

        // Format phone number
        document.getElementById('phone').addEventListener('input', function(e) {
            let value = e.target.value.replace(/\D/g, '');
            if (value.length > 0) {
                value = value.match(/.{1,4}/g).join(' ');
            }
            e.target.value = value;
        });
    </script>

</body>
</html>