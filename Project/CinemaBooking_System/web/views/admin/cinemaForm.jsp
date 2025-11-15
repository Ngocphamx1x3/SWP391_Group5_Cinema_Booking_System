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

            /* ===== Form Container ===== */
            .form-container {
                background: #ffffff; 
                border: 1px solid #e2e8f0; 
                border-radius: 20px;
                padding: 40px;
                max-width: 800px;
                margin: 0 auto;
                box-shadow: 0 10px 20px rgba(0, 0, 0, 0.05); 
            }

            .form-header {
                text-align: center;
                margin-bottom: 40px;
            }

            .form-header h2 {
                font-size: 24px;
                font-weight: 700;
                color: #1a202c; 
                background: none;
                -webkit-background-clip: unset;
                -webkit-text-fill-color: unset;
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
                color: #4a5568;
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
                background: #ffffff; 
                border: 1px solid #ced4da; 
                border-radius: 12px;
                padding: 14px 16px;
                color: #2d3748; 
                font-size: 14px;
                outline: none;
                transition: all 0.3s ease;
                font-family: 'Inter', sans-serif;
            }

            .form-group input:focus,
            .form-group select:focus,
            .form-group textarea:focus {
                border-color: #007bff; 
                box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.25); 
            }

            .form-group textarea {
                resize: vertical;
                min-height: 80px;
            }
            
            .form-group select option {
                color: #333;
                background-color: #fff;
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
                accent-color: #007bff; 
            }

            .checkbox-group label {
                margin-bottom: 0;
                text-transform: none;
                letter-spacing: normal;
                font-size: 14px;
                color: #2d3748;
            }

            /* ===== Form Actions ===== */
            .form-actions {
                display: flex;
                gap: 15px;
                margin-top: 40px;
                padding-top: 30px;
                border-top: 1px solid #e2e8f0; 
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
                background: #ffffff; 
                border-top: 1px solid #e2e8f0; 
                color: #6b7280;
                text-align: center;
                padding: 25px;
                margin-left: 280px;
                margin-top: 40px;
                font-size: 14px;
            }
            .toolbar select option {
                color: #333;
                background-color: #fff;
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
                <a href="${pageContext.request.contextPath}/admin/movies">Quản lý phim</a>
                <a href="${pageContext.request.contextPath}/admin/seat-types">Quản lý loại ghế</a>
                <a href="${pageContext.request.contextPath}/views/admin/paymentManager.jsp">Quản lý thanh toán</a>
                <a href="${pageContext.request.contextPath}/admin/vouchers">Quản lý Voucher</a>
            </nav>
            <a href="${pageContext.request.contextPath}/logout" class="logout">Đăng xuất</a>
        </div>

        <header>
            <h1><%= isEdit ? "Chỉnh sửa Rạp Chiếu" : "Thêm Rạp Chiếu Mới" %></h1>
            <div class="header-right">
                <span>Admin: Nguyễn Văn A</span>
                <span><%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %></span>
            </div>
        </header>

        <div class="content">
            <div class="form-container">
                <div class="form-header">
                    <h2><%= isEdit ? "Chỉnh sửa Thông Tin Rạp Chiếu" : "Thêm Rạp Chiếu Mới" %></h2>
                    <p><%= isEdit ? "Cập nhật thông tin rạp chiếu hiện có" : "Điền đầy đủ thông tin để thêm rạp chiếu mới" %></p>
                </div>

                <% if (error != null) { %>
                <div class="alert alert-error">
                    <%= error %>
                </div>
                <% } %>

                <form action="${pageContext.request.contextPath}/admin/cinemas" method="post" id="cinemaForm">
                    <% if (isEdit) { %>
                    <input type="hidden" name="id" value="<%= cinema.getId() %>">
                    <% } %>
                    <input type="hidden" name="action" value="<%= isEdit ? "update" : "create" %>">

                    <div class="form-row">
                        <div class="form-group">
                            <label for="code" class="required">Mã rạp</label>
                            <input type="text" id="code" name="code" 
                                   value="<%= isEdit ? cinema.getCode() : "" %>" 
                                   placeholder="VD: LOTTE_HL, CGV_LB, GALAXY_TH"
                                   required>
                        </div>

                        <div class="form-group">
                            <label for="name" class="required">Tên rạp</label>
                            <input type="text" id="name" name="name" 
                                   value="<%= isEdit ? cinema.getName() : "" %>" 
                                   placeholder="VD: Lotte Hòa Lạc, CGV Long Biên"
                                   required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="address" class="required">Địa chỉ</label>
                        <input type="text" id="address" name="address" 
                               value="<%= isEdit ? cinema.getAddress() : "" %>" 
                               placeholder="VD: Tầng 4, Vincom Long Biên, Quận Long Biên, Hà Nội"
                               required>
                    </div>

                    <div class="form-group">
                        <label for="description">Mô tả</label>
                        <textarea id="description" name="description" 
                                  placeholder="Mô tả chi tiết về rạp chiếu, tiện ích, đặc điểm..."><%= isEdit ? cinema.getDescription() : "" %></textarea>
                    </div>

                    <div class="form-row-3">
                        <div class="form-group">
                            <label for="capacity" class="required">Sức chứa</label>
                            <input type="number" id="capacity" name="capacity" 
                                   value="<%= isEdit ? cinema.getCapacity() : "500" %>" 
                                   min="1" max="5000" 
                                   placeholder="500"
                                   required>
                        </div>

                        <div class="form-group">
                            <label for="totalRooms" class="required">Số phòng</label>
                            <input type="number" id="totalRooms" name="totalRooms" 
                                   value="<%= isEdit ? cinema.getTotalRooms() : "3" %>" 
                                   min="1" max="20"
                                   placeholder="3"
                                   required>
                        </div>

                        <div class="form-group">
                            <label for="phone" class="required">Điện thoại</label>
                            <input type="text" id="phone" name="phone" 
                                   value="<%= isEdit ? cinema.getPhone() : "" %>" 
                                   placeholder="VD: 024 1234 5678"
                                   required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="operatingHours" class="required">Giờ hoạt động</label>
                        <input type="text" id="operatingHours" name="operatingHours" 
                               value="<%= isEdit ? cinema.getOperatingHours() : "8:00 - 23:00 hàng ngày" %>" 
                               placeholder="VD: 8:00 - 23:00 hàng ngày"
                               required>
                    </div>

                    <div class="form-group">
                        <label>Trạng thái</label>
                        <div class="checkbox-group">
                            <input type="checkbox" id="status" name="status" 
                                   <%= isEdit ? (cinema.isStatus() ? "checked" : "") : "checked" %>>
                            <label for="status">Đang hoạt động</label>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">
                            <%= isEdit ? "Cập nhật" : "Thêm mới" %>
                        </button>
                        <a href="${pageContext.request.contextPath}/admin/cinemas" class="btn btn-secondary">
                            Quay lại
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
            document.getElementById('cinemaForm').addEventListener('submit', function (e) {
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
            document.getElementById('phone').addEventListener('input', function (e) {
                let value = e.target.value.replace(/\D/g, '');
                if (value.length > 0) {
                    value = value.match(/.{1,4}/g).join(' ');
                }
                e.target.value = value;
            });
        </script>

    </body>
</html>