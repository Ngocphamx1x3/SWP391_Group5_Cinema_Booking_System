<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.Room, java.util.List"%>
<%
    List<Room> rooms = (List<Room>) request.getAttribute("rooms");
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Chọn Phòng Thiết Kế Ghế | Cinema Booking</title>
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
                margin-bottom: 10px;
            }

            .form-header p {
                color: #6b7280;
                font-size: 14px;
            }

            /* ===== Room Grid ===== */
            .room-grid {
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
                gap: 25px;
                margin-top: 30px;
            }

            .room-card {
                background: #ffffff;
                border: 1px solid #e2e8f0;
                border-radius: 16px;
                padding: 25px;
                display: flex;
                flex-direction: column;
                gap: 20px;
                transition: all 0.3s ease;
                position: relative;
            }

            .room-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 15px 30px rgba(0, 0, 0, 0.1);
                border-color: #007bff;
            }

            .room-header {
                display: flex;
                justify-content: between;
                align-items: flex-start;
                gap: 15px;
            }

            .room-info {
                flex: 1;
            }

            .room-info h3 {
                font-size: 18px;
                font-weight: 700;
                color: #1a202c;
                margin-bottom: 5px;
            }

            .room-code {
                color: #6b7280;
                font-size: 14px;
                font-weight: 500;
                margin-bottom: 10px;
            }

            .room-description {
                color: #6b7280;
                font-size: 13px;
                line-height: 1.4;
                margin-bottom: 15px;
            }

            .room-details {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 12px;
                margin-bottom: 15px;
            }

            .detail-item {
                display: flex;
                flex-direction: column;
                gap: 4px;
            }

            .detail-label {
                font-size: 11px;
                color: #6b7280;
                text-transform: uppercase;
                letter-spacing: 1px;
                font-weight: 600;
            }

            .detail-value {
                font-size: 14px;
                font-weight: 600;
                color: #1a202c;
                display: flex;
                align-items: center;
                gap: 6px;
            }

            .room-status {
                position: absolute;
                top: 20px;
                right: 20px;
                padding: 6px 12px;
                border-radius: 20px;
                font-size: 11px;
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: 1px;
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

            .btn {
                padding: 12px 20px;
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
            }

            .btn-secondary:hover {
                background: #5a6268;
                transform: translateY(-2px);
            }

            .btn:disabled {
                opacity: 0.6;
                cursor: not-allowed;
                transform: none !important;
            }

            .no-rooms {
                text-align: center;
                padding: 60px 20px;
                color: #6b7280;
            }

            .no-rooms h3 {
                font-size: 20px;
                margin-bottom: 10px;
                color: #4a5568;
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
                .room-grid {
                    grid-template-columns: 1fr;
                }
                .room-details {
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
                <a href="${pageContext.request.contextPath}/staff/rooms">🎭 Quản lý phòng chiếu</a>
                <a href="${pageContext.request.contextPath}/staff/seat-design" class="active">💺 Thiết kế ghế trong phòng</a>
                <a href="${pageContext.request.contextPath}/staff/schedules">📅 Quản lý lịch chiếu</a>
                <a href="${pageContext.request.contextPath}/staff/bookings">🎫 Quản lý đặt vé</a>
                <a href="${pageContext.request.contextPath}/staff/reports">📈 Báo cáo rạp của tôi</a>
            </nav>
            <a href="${pageContext.request.contextPath}/logout" class="logout">🚪 Đăng xuất</a>
        </div>

        <header>
            <h1>🎯 Chọn Phòng Để Thiết Kế Ghế</h1>
            <div class="header-right">
                <span>👤 Staff: <%= session.getAttribute("staffName") != null ? session.getAttribute("staffName") : "Nhân viên" %></span>
                <span>⏰ <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %></span>
            </div>
        </header>

        <div class="content">
            <div class="form-container">
                <div class="form-header">
                    <h2>💺 Thiết Kế Ghế Trong Phòng</h2>
                    <p>Chọn phòng chiếu để bắt đầu thiết kế layout ghế. Bạn có thể kéo thả ghế, thay đổi loại ghế và lưu thiết kế.</p>
                </div>

                <% if (rooms != null && !rooms.isEmpty()) { %>
                <div class="room-grid">
                    <% for (Room room : rooms) { %>
                    <div class="room-card">
                        <span class="room-status <%= room.isStatus() ? "status-active" : "status-inactive" %>">
                            <%= room.isStatus() ? "Đang hoạt động" : "Ngừng hoạt động" %>
                        </span>
                        
                        <div class="room-header">
                            <div class="room-info">
                                <h3><%= room.getName() %></h3>
                                <div class="room-code"><%= room.getCode() %></div>
                                <% if (room.getDescription() != null && !room.getDescription().isEmpty()) { %>
                                <div class="room-description"><%= room.getDescription() %></div>
                                <% } %>
                            </div>
                        </div>

                        <div class="room-details">
                            <div class="detail-item">
                                <span class="detail-label">Loại phòng</span>
                                <span class="detail-value">🎭 <%= room.getScreenType() %></span>
                            </div>
                            <div class="detail-item">
                                <span class="detail-label">Âm thanh</span>
                                <span class="detail-value">🔊 <%= room.getSoundSystem() %></span>
                            </div>
                            <div class="detail-item">
                                <span class="detail-label">Sức chứa</span>
                                <span class="detail-value">💺 <%= room.getCapacity() %> ghế</span>
                            </div>
                            <div class="detail-item">
                                <span class="detail-label">Layout</span>
                                <span class="detail-value">📐 <%= room.getSeatRows() %>x<%= room.getSeatColumns() %></span>
                            </div>
                        </div>

                        <a href="${pageContext.request.contextPath}/staff/seat-design?roomId=<%= room.getId() %>" 
                           class="btn btn-primary <%= !room.isStatus() ? "disabled" : "" %>"
                           <%= !room.isStatus() ? "onclick=\"alert('Phòng này đang ngừng hoạt động. Không thể thiết kế ghế.'); return false;\"" : "" %>>
                            🎨 Thiết kế ghế
                        </a>
                    </div>
                    <% } %>
                </div>
                <% } else { %>
                <div class="no-rooms">
                    <h3>📝 Chưa có phòng chiếu nào</h3>
                    <p>Bạn cần tạo phòng chiếu trước khi có thể thiết kế ghế.</p>
                    <a href="${pageContext.request.contextPath}/staff/rooms?action=add" class="btn btn-primary" style="margin-top: 20px;">
                        ➕ Thêm phòng chiếu mới
                    </a>
                </div>
                <% } %>
            </div>
        </div>

        <footer>
            © 2025 Cinema Booking System - Staff Panel | Powered by Modern Technology
        </footer>

        <script>
            // Thêm hiệu ứng hover cho thẻ phòng
            document.addEventListener('DOMContentLoaded', function() {
                const roomCards = document.querySelectorAll('.room-card');
                roomCards.forEach(card => {
                    card.addEventListener('mouseenter', function() {
                        this.style.transform = 'translateY(-5px)';
                        this.style.boxShadow = '0 15px 30px rgba(0, 0, 0, 0.1)';
                    });
                    
                    card.addEventListener('mouseleave', function() {
                        this.style.transform = 'translateY(0)';
                        this.style.boxShadow = 'none';
                    });
                });
            });
        </script>

    </body>
</html>