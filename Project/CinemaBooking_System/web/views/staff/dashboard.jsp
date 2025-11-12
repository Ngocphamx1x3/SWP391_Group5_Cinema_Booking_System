<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
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
                <h2>🎬 CINEMA PRO</h2>
                <p>Staff Panel</p>
            </div>
            <nav>
                <a href="${pageContext.request.contextPath}/staffdashboard" class="active">🏢 Thông tin rạp của tôi</a>
                <a href="${pageContext.request.contextPath}/staff/rooms">🎭 Quản lý phòng chiếu</a>
                <a href="${pageContext.request.contextPath}/staff/seat-design">💺 Thiết kế ghế trong phòng</a>
                <a href="${pageContext.request.contextPath}/staff/schedules">📅 Quản lý lịch chiếu</a>
                <a href="${pageContext.request.contextPath}/views/staff/bookingManager.jsp">🎫 Quản lý đặt vé</a>
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
                    <h3>🎟️ Vé đã bán tháng này</h3>
                    <div class="stat-value">
                        ${ticketsSoldToday}
                    </div>
                    <div class="stat-change">
                        ↑ ${ticketsChangePercent}% so với hôm qua
                    </div>
                </div>

                <div class="stat-box">
                    <h3>💰 Doanh thu tháng này</h3>
                    <div class="stat-value" style="font-size: 1.6em;">
                        <fmt:formatNumber value="${revenueCurrentShift}" type="number" groupingUsed="true" /> VNĐ
                    </div>
                    <div class="stat-change">↑ 8.3% so với hôm qua</div>
                </div>

                <div class="stat-box">
                    <h3>🎬 Phòng đang hoạt động</h3>
                    <div class="stat-value">
                        ${activeRooms} / ${totalRooms}
                    </div>
                    <div class="stat-change">
                        Cập nhật theo trạng thái phòng
                    </div>
                </div>

                <div class="stat-box">
                    <h3>⏰ Suất chiếu hôm nay</h3>
                    <div class="stat-value">
                        ${todaySchedules}
                    </div>
                    <div class="stat-change">Tổng số suất chiếu trong ngày</div>
                </div>

                <div class="stat-box">
                    <h3>✅ Vé đã kiểm tra hôm nay</h3>
                    <div class="stat-value">3</div>
                    <div class="stat-change">Còn 1 vé chưa check-in</div>
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
                            <td><strong>CHÂU BÁU ĐỜI TÔI</strong></td>
                            <td>Phòng 3 - IMAX Lotte Hòa Lạc</td>
                            <td>18:00 - 20:00</td>
                            <td>12/120</td>
                            <td class="status-success">✅ Đang chiếu</td>
                            <td><button style="background:#ffc107;border:none;padding:5px 10px;border-radius:5px;cursor:pointer;">Check-in</button></td>
                        </tr>
                        <tr>
                            <td><strong>NGHỆ THUẬT SĂN QUỶ VÀ NẤU MÌ 2</strong></td>
                            <td>Phòng 3 - IMAX Lotte Hòa Lạc</td>
                            <td>14:30 - 16:20</td>
                            <td>45/100</td>
                            <td class="status-pending">⏳ Sắp chiếu</td>
                            <td><button style="background:#ffc107;border:none;padding:5px 10px;border-radius:5px;cursor:pointer;">Check-in</button></td>
                        </tr>
                        <tr>
                            <td><strong>Shin Cậu Bé Bút Chì Movie 31: Đại Chiến Siêu Năng Lực Sushi Bay</strong></td>
                            <td>Phòng 3 - IMAX Lotte Hòa Lạc</td>
                            <td>16:45 - 19:00</td>
                            <td>28/150</td>
                            <td class="status-pending">⏳ Sắp chiếu</td>
                            <td><button style="background:#ffc107;border:none;padding:5px 10px;border-radius:5px;cursor:pointer;">Check-in</button></td>
                        </tr>
                        <tr>
                            <td><strong>NHỮNG KỶ NGUYÊN CỦA TAYLOR SWIFT</strong></td>
                            <td>Phòng 3 - IMAX Lotte Hòa Lạc</td>
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
                            <td>ngocphamx1x3</td>
                            <td>CHÂU BÁU ĐỜI TÔI</td>
                            <td>14:00 07/10</td>
                            <td>A1, A2, A3</td>
                            <td>360,000₫</td>
                            <td class="status-success">✅ Đã check-in</td>
                        </tr>
                        <tr>
                            <td>#TK1002</td>
                            <td>ngocphamquang30</td>
                            <td>NHỮNG KỶ NGUYÊN CỦA TAYLOR SWIFT</td>
                            <td>15:30 07/10</td>
                            <td>B5, B6</td>
                            <td>240,000₫</td>
                            <td class="status-pending">⏳ Chưa check-in</td>
                        </tr>
                        <tr>
                            <td>#TK1003</td>
                            <td>ngocphamx1x32</td>
                            <td>Shin Cậu Bé Bút Chì Movie 31: Đại Chiến Siêu Năng Lực Sushi Bay</td>
                            <td>16:45 07/10</td>
                            <td>C8, C9</td>
                            <td>240,000₫</td>
                            <td class="status-pending">⏳ Chưa check-in</td>
                        </tr>
                        <tr>
                            <td>#TK1004</td>
                            <td>ngocphamx1x223</td>
                            <td>NGHỆ THUẬT SĂN QUỶ VÀ NẤU MÌ 2</td>
                            <td>18:15 07/10</td>
                            <td>D12</td>
                            <td>120,000₫</td>
                            <td class="status-pending">⏳ Chưa check-in</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <!-- Footer -->
            <footer>
                © 2025 Cinema Booking System - Admin Panel | Powered by Modern Technology
            </footer>

    </body>
</html>