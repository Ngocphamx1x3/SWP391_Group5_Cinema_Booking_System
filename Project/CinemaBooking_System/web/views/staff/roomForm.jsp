<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.Room"%>
<%
    Room room = (Room) request.getAttribute("room");
    boolean isEdit = room != null;
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title><%= isEdit ? "Chỉnh sửa" : "Thêm mới" %> Phòng Chiếu | Cinema Booking</title>
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

            .capacity-info {
                background: #f8f9fa;
                border: 1px solid #e2e8f0;
                border-radius: 8px;
                padding: 12px 16px;
                margin-top: 8px;
                font-size: 13px;
                color: #6b7280;
            }

            .capacity-info strong {
                color: #007bff;
            }

            .capacity-warning {
                background: rgba(239, 68, 68, 0.1);
                border: 1px solid rgba(239, 68, 68, 0.3);
                color: #ef4444;
            }

            .capacity-success {
                background: rgba(16, 185, 129, 0.1);
                border: 1px solid rgba(16, 185, 129, 0.3);
                color: #10b981;
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

            /* ===== Required Field ===== */
            .required::after {
                content: " *";
                color: #ef4444;
            }

            /* ===== Input Error ===== */
            .input-error {
                border-color: #ef4444 !important;
                box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.25) !important;
            }

            .error-message {
                color: #ef4444;
                font-size: 12px;
                margin-top: 5px;
                font-weight: 600;
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
                <h2>🎬 CINEMA PRO</h2>
                <p>Staff Panel</p>
            </div>
            <nav>
                <a href="${pageContext.request.contextPath}/staffdashboard">🏢 Thông tin rạp của tôi</a>
                <a href="${pageContext.request.contextPath}/staff/rooms" class="active">🎭 Quản lý phòng chiếu</a>
                <a href="${pageContext.request.contextPath}/views/staff/seatManager.jsp">💺 Thiết kế ghế trong phòng</a>
                <a href="${pageContext.request.contextPath}/views/staff/screeningManager.jsp">📅 Quản lý lịch chiếu</a>
                <a href="${pageContext.request.contextPath}/views/staff/bookingManager.jsp">🎫 Quản lý đặt vé</a>
                <a href="${pageContext.request.contextPath}/views/staff/cinemaReports.jsp">📈 Báo cáo rạp của tôi</a>
            </nav>
            <a href="${pageContext.request.contextPath}/logout" class="logout">🚪 Đăng xuất</a>
        </div>

        <header>
            <h1><%= isEdit ? "✏️ Chỉnh sửa Phòng Chiếu" : "➕ Thêm Phòng Chiếu Mới" %></h1>
            <div class="header-right">
                <span>👤 Staff: <%= session.getAttribute("staffName") != null ? session.getAttribute("staffName") : "Nhân viên" %></span>
                <span>⏰ <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %></span>
            </div>
        </header>

        <div class="content">
            <div class="form-container">
                <div class="form-header">
                    <h2><%= isEdit ? "Chỉnh sửa Thông Tin Phòng Chiếu" : "Thêm Phòng Chiếu Mới" %></h2>
                    <p><%= isEdit ? "Cập nhật thông tin phòng chiếu hiện có" : "Điền đầy đủ thông tin để thêm phòng chiếu mới" %></p>
                </div>

                <% if (error != null) { %>
                <div class="alert alert-error">
                    ❌ <%= error %>
                </div>
                <% } %>

                <form action="${pageContext.request.contextPath}/staff/rooms" method="post" id="roomForm">
                    <% if (isEdit) { %>
                    <input type="hidden" name="id" value="<%= room.getId() %>">
                    <% } %>
                    <input type="hidden" name="action" value="<%= isEdit ? "update" : "create" %>">

                    <div class="form-row">
                        <div class="form-group">
                            <label for="code" class="required">Mã phòng</label>
                            <input type="text" id="code" name="code" 
                                   value="<%= isEdit ? room.getCode() : "" %>" 
                                   placeholder="VD: R01, R02, IMAX_01"
                                   required>
                            <small style="color: #6b7280; font-size: 12px;">Mã phòng phải là duy nhất trong rạp</small>
                        </div>

                        <div class="form-group">
                            <label for="name" class="required">Tên phòng</label>
                            <input type="text" id="name" name="name" 
                                   value="<%= isEdit ? room.getName() : "" %>" 
                                   placeholder="VD: Phòng 1 - Standard, Phòng IMAX"
                                   required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="description">Mô tả</label>
                        <textarea id="description" name="description" 
                                  placeholder="Mô tả chi tiết về phòng chiếu, đặc điểm, tiện ích..."><%= isEdit ? room.getDescription() : "" %></textarea>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="screenType" class="required">Loại màn hình</label>
                            <select id="screenType" name="screenType" required>
                                <option value="">-- Chọn loại màn hình --</option>
                                <option value="2D" <%= isEdit && "2D".equals(room.getScreenType()) ? "selected" : "" %>>2D Standard</option>
                                <option value="3D" <%= isEdit && "3D".equals(room.getScreenType()) ? "selected" : "" %>>3D</option>
                                <option value="IMAX" <%= isEdit && "IMAX".equals(room.getScreenType()) ? "selected" : "" %>>IMAX</option>
                                <option value="4DX" <%= isEdit && "4DX".equals(room.getScreenType()) ? "selected" : "" %>>4DX</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="soundSystem" class="required">Hệ thống âm thanh</label>
                            <select id="soundSystem" name="soundSystem" required>
                                <option value="">-- Chọn hệ thống âm thanh --</option>
                                <option value="Dolby Digital" <%= isEdit && "Dolby Digital".equals(room.getSoundSystem()) ? "selected" : "" %>>Dolby Digital</option>
                                <option value="Dolby Surround 7.1" <%= isEdit && "Dolby Surround 7.1".equals(room.getSoundSystem()) ? "selected" : "" %>>Dolby Surround 7.1</option>
                                <option value="Dolby Atmos" <%= isEdit && "Dolby Atmos".equals(room.getSoundSystem()) ? "selected" : "" %>>Dolby Atmos</option>
                                <option value="IMAX Sound" <%= isEdit && "IMAX Sound".equals(room.getSoundSystem()) ? "selected" : "" %>>IMAX Sound</option>
                                <option value="DTS:X" <%= isEdit && "DTS:X".equals(room.getSoundSystem()) ? "selected" : "" %>>DTS:X</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-row-3">
                        <div class="form-group">
                            <label for="seatRows" class="required">Số hàng ghế</label>
                            <input type="number" id="seatRows" name="seatRows" 
                                   value="<%= isEdit ? room.getSeatRows() : "9" %>" 
                                   min="1" max="20" 
                                   placeholder="9"
                                   required>
                        </div>

                        <div class="form-group">
                            <label for="seatColumns" class="required">Số cột ghế</label>
                            <input type="number" id="seatColumns" name="seatColumns" 
                                   value="<%= isEdit ? room.getSeatColumns() : "14" %>" 
                                   min="1" max="25" 
                                   placeholder="14"
                                   required>
                        </div>

                        <div class="form-group">
                            <label for="capacity" class="required">Sức chứa thực tế</label>
                            <input type="number" id="capacity" name="capacity" 
                                   value="<%= isEdit ? room.getCapacity() : "111" %>" 
                                   min="1" max="500" 
                                   placeholder="111"
                                   required>
                            <small style="color: #6b7280; font-size: 12px;">Số ghế thực tế trong phòng</small>
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Thông tin layout</label>
                        <div class="capacity-info" id="layoutInfo">
                            <strong id="layoutText">9 x 14 = 126 ghế (Tối đa)</strong>
                            <br>
                            <span id="capacityStatus">Sức chứa thực tế: <strong>111 ghế</strong></span>
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Trạng thái</label>
                        <div class="checkbox-group">
                            <input type="checkbox" id="status" name="status" 
                                   <%= isEdit ? (room.isStatus() ? "checked" : "") : "checked" %>>
                            <label for="status">Đang hoạt động</label>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">
                            <%= isEdit ? "💾 Cập nhật" : "➕ Thêm mới" %>
                        </button>
                        <a href="${pageContext.request.contextPath}/staff/rooms" class="btn btn-secondary">
                            ↩️ Quay lại
                        </a>
                    </div>
                </form>
            </div>
        </div>

        <footer>
            © 2025 Cinema Booking System - Staff Panel | Powered by Modern Technology
        </footer>

        <script>
            // Cập nhật thông tin layout và kiểm tra capacity
            function updateLayoutInfo() {
                const seatRows = parseInt(document.getElementById('seatRows').value) || 0;
                const seatColumns = parseInt(document.getElementById('seatColumns').value) || 0;
                const capacity = parseInt(document.getElementById('capacity').value) || 0;
                
                const maxCapacity = seatRows * seatColumns;
                
                // Cập nhật layout text
                document.getElementById('layoutText').textContent = 
                    `${seatRows} x ${seatColumns} = ${maxCapacity} ghế (Tối đa)`;
                
                // Kiểm tra và cập nhật trạng thái capacity
                const capacityStatus = document.getElementById('capacityStatus');
                const layoutInfo = document.getElementById('layoutInfo');
                const capacityInput = document.getElementById('capacity');
                
                if (capacity > maxCapacity) {
                    // Lỗi: capacity vượt quá max
                    capacityStatus.innerHTML = `❌ <strong>Vượt quá giới hạn: ${capacity} > ${maxCapacity}</strong>`;
                    layoutInfo.className = 'capacity-info capacity-warning';
                    capacityInput.classList.add('input-error');
                } else if (capacity === maxCapacity) {
                    // Vừa đủ
                    capacityStatus.innerHTML = `✅ <strong>Sức chứa tối đa: ${capacity} ghế</strong>`;
                    layoutInfo.className = 'capacity-info capacity-success';
                    capacityInput.classList.remove('input-error');
                } else if (capacity > 0) {
                    // Hợp lệ nhưng không đầy đủ
                    capacityStatus.innerHTML = `⚠️ <strong>Sức chứa thực tế: ${capacity} ghế</strong> (Còn ${maxCapacity - capacity} ghế trống)`;
                    layoutInfo.className = 'capacity-info';
                    capacityInput.classList.remove('input-error');
                } else {
                    // Chưa nhập
                    capacityStatus.innerHTML = `<strong>Sức chứa thực tế: ${capacity} ghế</strong>`;
                    layoutInfo.className = 'capacity-info';
                    capacityInput.classList.remove('input-error');
                }
            }

            // Gắn sự kiện cho các trường
            document.getElementById('seatRows').addEventListener('input', updateLayoutInfo);
            document.getElementById('seatColumns').addEventListener('input', updateLayoutInfo);
            document.getElementById('capacity').addEventListener('input', updateLayoutInfo);

            // Tính toán ban đầu
            updateLayoutInfo();

            // Form validation
            document.getElementById('roomForm').addEventListener('submit', function (e) {
                const code = document.getElementById('code').value.trim();
                const name = document.getElementById('name').value.trim();
                const screenType = document.getElementById('screenType').value;
                const soundSystem = document.getElementById('soundSystem').value;
                const seatRows = parseInt(document.getElementById('seatRows').value);
                const seatColumns = parseInt(document.getElementById('seatColumns').value);
                const capacity = parseInt(document.getElementById('capacity').value);
                
                let errors = [];

                // Validate mã phòng
                if (!code) {
                    errors.push("Mã phòng không được để trống");
                }

                // Validate tên phòng
                if (!name) {
                    errors.push("Tên phòng không được để trống");
                }

                // Validate loại màn hình
                if (!screenType) {
                    errors.push("Vui lòng chọn loại màn hình");
                }

                // Validate hệ thống âm thanh
                if (!soundSystem) {
                    errors.push("Vui lòng chọn hệ thống âm thanh");
                }

                // Validate số hàng/số cột
                if (isNaN(seatRows) || seatRows < 1 || seatRows > 20) {
                    errors.push("Số hàng ghế phải từ 1-20");
                }

                if (isNaN(seatColumns) || seatColumns < 1 || seatColumns > 25) {
                    errors.push("Số cột ghế phải từ 1-25");
                }

                // Validate capacity
                if (isNaN(capacity) || capacity < 1) {
                    errors.push("Sức chứa phải lớn hơn 0");
                }

                // VALIDATION QUAN TRỌNG: Capacity không vượt quá số hàng × số cột
                const maxCapacity = seatRows * seatColumns;
                if (capacity > maxCapacity) {
                    errors.push(`Sức chứa (${capacity}) không thể vượt quá ${maxCapacity} (số hàng × số cột)`);
                }

                // Hiển thị lỗi nếu có
                if (errors.length > 0) {
                    e.preventDefault();
                    alert("Lỗi:\n• " + errors.join("\n• "));
                    return false;
                }
            });

            // Real-time validation cho capacity
            document.getElementById('capacity').addEventListener('blur', function() {
                const seatRows = parseInt(document.getElementById('seatRows').value) || 0;
                const seatColumns = parseInt(document.getElementById('seatColumns').value) || 0;
                const capacity = parseInt(this.value) || 0;
                const maxCapacity = seatRows * seatColumns;
                
                if (capacity > maxCapacity) {
                    this.title = `Vượt quá giới hạn! Tối đa: ${maxCapacity} ghế`;
                } else {
                    this.title = '';
                }
            });

            // Tự động đề xuất capacity khi thay đổi layout
            document.getElementById('seatRows').addEventListener('change', function() {
                const seatRows = parseInt(this.value) || 0;
                const seatColumns = parseInt(document.getElementById('seatColumns').value) || 0;
                const capacityInput = document.getElementById('capacity');
                
                // Chỉ đề xuất nếu capacity chưa được chỉnh sửa
                if (!capacityInput.dataset.modified) {
                    const suggestedCapacity = seatRows * seatColumns;
                    capacityInput.value = suggestedCapacity;
                    updateLayoutInfo();
                }
            });

            document.getElementById('seatColumns').addEventListener('change', function() {
                const seatRows = parseInt(document.getElementById('seatRows').value) || 0;
                const seatColumns = parseInt(this.value) || 0;
                const capacityInput = document.getElementById('capacity');
                
                // Chỉ đề xuất nếu capacity chưa được chỉnh sửa
                if (!capacityInput.dataset.modified) {
                    const suggestedCapacity = seatRows * seatColumns;
                    capacityInput.value = suggestedCapacity;
                    updateLayoutInfo();
                }
            });

            // Đánh dấu capacity đã được chỉnh sửa thủ công
            document.getElementById('capacity').addEventListener('input', function() {
                this.dataset.modified = 'true';
            });
        </script>

    </body>
</html>