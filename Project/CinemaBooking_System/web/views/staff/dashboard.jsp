<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Staff Dashboard | Cinema Booking</title>
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
                background: linear-gradient(135deg, #ffffff 0%, #ffc107 100%);
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
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

            /* ===== Stats Cards ===== */
            .stats-container {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
                gap: 25px;
                margin-bottom: 40px;
            }

            .stat-box {
                background: #ffffff;
                border: 1px solid #e2e8f0;
                border-radius: 20px;
                padding: 30px;
                position: relative;
                overflow: hidden;
                transition: all 0.3s ease;
            }

            .stat-box::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                height: 3px;
                background: linear-gradient(90deg, #00d4ff 0%, #0099ff 100%);
                transform: scaleX(0);
                transition: transform 0.3s ease;
            }

            .stat-box:hover {
                transform: translateY(-5px);
                border-color: #007bff;
                box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
            }

            .stat-box:hover::before {
                transform: scaleX(1);
            }

            .stat-box h3 {
                color: #6b7280;
                font-size: 13px;
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: 1px;
                margin-bottom: 12px;
            }

            .stat-box .stat-value {
                font-size: 36px;
                font-weight: 700;
                color: #1a202c;
                background: none;
                -webkit-background-clip: unset;
                -webkit-text-fill-color: unset;
                margin-bottom: 8px;
            }

            .stat-box .stat-change {
                font-size: 13px;
                color: #10b981;
                font-weight: 600;
            }

            .stat-box .stat-change.negative {
                color: #ef4444;
            }

            /* ===== Charts Section ===== */
            .section-title {
                font-size: 24px;
                font-weight: 700;
                margin-bottom: 25px;
                color: #1a202c;
                background: none;
                -webkit-background-clip: unset;
                -webkit-text-fill-color: unset;
            }

            .charts-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(450px, 1fr));
                gap: 25px;
                margin-bottom: 40px;
            }

            .chart-box {
                background: #ffffff;
                border: 1px solid #e2e8f0;
                border-radius: 20px;
                padding: 30px;
                transition: all 0.3s ease;
            }

            .chart-box:hover {
                border-color: #007bff;
                box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
            }

            .chart-box h3 {
                font-size: 18px;
                font-weight: 600;
                color: #1a202c;
                margin-bottom: 20px;
            }

            .chart-placeholder {
                background: #f8f9fa;
                border: 1px dashed #ced4da;
                border-radius: 12px;
                height: 300px;
                display: flex;
                align-items: center;
                justify-content: center;
                color: #6b7280;
                font-size: 14px;
            }

            /* ===== Table Section ===== */
            .table-container {
                background: #ffffff;
                border: 1px solid #e2e8f0;
                border-radius: 20px;
                padding: 30px;
                margin-bottom: 40px;
                overflow-x: auto;
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

            .status-success {
                color: #10b981;
                font-weight: 600;
            }

            .status-refund {
                color: #ef4444;
                font-weight: 600;
            }

            /* ===== Notifications ===== */
            .notifications {
                background: #ffffff;
                border: 1px solid #e2e8f0;
                border-radius: 20px;
                padding: 30px;
                margin-bottom: 40px;
            }

            .notifications h2 {
                font-size: 20px;
                font-weight: 600;
                margin-bottom: 20px;
                color: #1a202c;
            }

            .notifications ul {
                list-style: none;
            }

            .notifications li {
                padding: 15px;
                background: #e6f7ff;
                border-left: 3px solid #007bff;
                border-radius: 8px;
                margin-bottom: 12px;
                color: #2d3748;
                font-size: 14px;
                transition: all 0.3s ease;
            }
            .toolbar select option {
                color: #333;
                background-color: #fff;
            }

            .notifications li:hover {
                background: #d0ebf9; /* Nền xanh đậm hơn khi hover */
                transform: translateX(5px);
            }

            /* ===== Footer ===== */
            footer {
                background: #ffffff; /* Nền trắng */
                border-top: 1px solid #e2e8f0; /* Viền xám nhạt */
                color: #6b7280; /* Giữ nguyên */
                text-align: center;
                padding: 25px;
                margin-left: 280px;
                font-size: 14px;
            }
        </style>
    </head>
    <body>

        <!-- Sidebar -->
        <div class="sidebar">
            <div class="sidebar-logo">
                <h2>🎬 CINEMA STAFF</h2>
                <p>Staff Panel</p>
            </div>
            <nav>
                <a href="${pageContext.request.contextPath}/staffdashboard" class="active">🏢 Thông tin rạp của tôi</a>
                <a href="${pageContext.request.contextPath}/staff/rooms">🎭 Quản lý phòng chiếu</a>
                <a href="${pageContext.request.contextPath}/staff/seat-design">💺 Thiết kế ghế trong phòng</a>
                <a href="${pageContext.request.contextPath}/staff/schedules">📅 Quản lý lịch chiếu</a>
                <a href="${pageContext.request.contextPath}/views/staff/bookingManager.jsp">🎫 Quản lý đặt vé</a>
                <a href="${pageContext.request.contextPath}/views/staff/cinemaReports.jsp">📈 Báo cáo rạp của tôi</a>
            </nav>
            <a href="${pageContext.request.contextPath}/logout" class="logout">🚪 Đăng xuất</a>
        </div>

        <!-- Header -->
        <header>
            <h1>Bảng điều khiển nhân viên</h1>
            <div class="header-right">
                <c:if test="${not empty staffUser}">
                    <span>👤 ${staffUser.username} (${staffUser.role})</span>
                </c:if>
                <c:if test="${empty staffUser}">
                    <span>👤 Nhân viên</span>
                </c:if>
                <span>⏰ <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %></span>
            </div>
        </header>

        <!-- Main content -->
        <div class="content">

            <!-- Stats Cards -->
            <div class="stats-container">
                <div class="stat-box">
                    <h3>🎟️ Vé đã bán hôm nay</h3>
                    <div class="stat-value">342</div>
                    <div class="stat-change">↑ 15% so với hôm qua</div>
                </div>
                <div class="stat-box">
                    <h3>💰 Doanh thu ca</h3>
                    <div class="stat-value">42.5M</div>
                    <div class="stat-change">↑ 8.3% so với ca trước</div>
                </div>
                <div class="stat-box">
                    <h3>👥 Khách hàng mới</h3>
                    <div class="stat-value">28</div>
                    <div class="stat-change">↑ 12% so với tuần trước</div>
                </div>
                <div class="stat-box">
                    <h3>⏰ Suất chiếu hôm nay</h3>
                    <div class="stat-value">18</div>
                    <div class="stat-change">3 suất sắp bắt đầu</div>
                </div>
                <div class="stat-box">
                    <h3>✅ Vé đã kiểm tra</h3>
                    <div class="stat-value">156</div>
                    <div class="stat-change">Còn 42 vé chưa check-in</div>
                </div>
                <div class="stat-box">
                    <h3>⚠️ Yêu cầu hỗ trợ</h3>
                    <div class="stat-value">3</div>
                    <div class="stat-change negative">Cần xử lý ngay</div>
                </div>
            </div>

            <!-- Today's Screenings -->
            <h2 class="section-title">🎬 Suất chiếu hôm nay</h2>
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>Phim</th>
                            <th>Phòng</th>
                            <th>Thời gian</th>
                            <th>Số ghế trống</th>
                            <th>Trạng thái</th>
                            <th>Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td><strong>Deadpool & Wolverine</strong></td>
                            <td>Phòng 1</td>
                            <td>14:00 - 16:15</td>
                            <td>12/120</td>
                            <td class="status-success">✅ Đang chiếu</td>
                            <td><button style="background:#ffc107;border:none;padding:5px 10px;border-radius:5px;cursor:pointer;">Check-in</button></td>
                        </tr>
                        <tr>
                            <td><strong>Inside Out 2</strong></td>
                            <td>Phòng 3</td>
                            <td>15:30 - 17:20</td>
                            <td>45/100</td>
                            <td class="status-pending">⏳ Sắp chiếu</td>
                            <td><button style="background:#ffc107;border:none;padding:5px 10px;border-radius:5px;cursor:pointer;">Check-in</button></td>
                        </tr>
                        <tr>
                            <td><strong>Venom 3</strong></td>
                            <td>Phòng 2</td>
                            <td>16:45 - 19:00</td>
                            <td>28/150</td>
                            <td class="status-pending">⏳ Sắp chiếu</td>
                            <td><button style="background:#ffc107;border:none;padding:5px 10px;border-radius:5px;cursor:pointer;">Check-in</button></td>
                        </tr>
                        <tr>
                            <td><strong>Joker: Folie à Deux</strong></td>
                            <td>Phòng 4</td>
                            <td>18:15 - 20:30</td>
                            <td>67/120</td>
                            <td class="status-pending">⏳ Sắp chiếu</td>
                            <td><button style="background:#ffc107;border:none;padding:5px 10px;border-radius:5px;cursor:pointer;">Check-in</button></td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <!-- Recent Bookings -->
            <h2 class="section-title">🧾 Đặt vé gần đây</h2>
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>Mã vé</th>
                            <th>Khách hàng</th>
                            <th>Phim</th>
                            <th>Suất chiếu</th>
                            <th>Ghế</th>
                            <th>Thành tiền</th>
                            <th>Trạng thái</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>#TK1001</td>
                            <td>Nguyễn Văn A</td>
                            <td>Deadpool & Wolverine</td>
                            <td>14:00 07/10</td>
                            <td>A1, A2, A3</td>
                            <td>360,000₫</td>
                            <td class="status-success">✅ Đã check-in</td>
                        </tr>
                        <tr>
                            <td>#TK1002</td>
                            <td>Trần Thị B</td>
                            <td>Inside Out 2</td>
                            <td>15:30 07/10</td>
                            <td>B5, B6</td>
                            <td>240,000₫</td>
                            <td class="status-pending">⏳ Chưa check-in</td>
                        </tr>
                        <tr>
                            <td>#TK1003</td>
                            <td>Lê Văn C</td>
                            <td>Venom 3</td>
                            <td>16:45 07/10</td>
                            <td>C8, C9</td>
                            <td>240,000₫</td>
                            <td class="status-pending">⏳ Chưa check-in</td>
                        </tr>
                        <tr>
                            <td>#TK1004</td>
                            <td>Phạm Thị D</td>
                            <td>Joker: Folie à Deux</td>
                            <td>18:15 07/10</td>
                            <td>D12</td>
                            <td>120,000₫</td>
                            <td class="status-pending">⏳ Chưa check-in</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <!-- Notifications -->
            <h2 class="section-title">🔔 Thông báo ca làm</h2>
            <div class="notifications">
                <ul>
                    <li><strong>[10:20]</strong> Kiểm tra hệ thống máy chiếu phòng 2 trước suất 16:45.</li>
                    <li><strong>[09:45]</strong> Khách hàng Nguyễn Văn X yêu cầu đổi vé suất 15:30.</li>
                    <li><strong>[08:30]</strong> Cập nhật danh sách vé đặt trước cho các suất chiếu hôm nay.</li>
                    <li><strong>[07:15]</strong> Họp đầu ca: Nhắc nhở về quy trình check-in và an toàn.</li>
                </ul>
            </div>
        </div>

        <!-- Footer -->
        <footer>
            © 2025 Cinema Booking System - Staff Panel | Ca làm: 07:00 - 15:00
        </footer>

    </body>
</html>