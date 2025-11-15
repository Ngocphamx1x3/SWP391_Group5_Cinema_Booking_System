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


            .content {
                margin-left: 280px;
                padding: 40px;
            }


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


            footer {
                background: #ffffff;
                border-top: 1px solid #e2e8f0;
                color: #6b7280;
                text-align: center;
                padding: 25px;
                margin-left: 280px;
                font-size: 14px;
            }
        </style>
    </head>
    <body>


        <div class="sidebar">
            <div class="sidebar-logo">
                <h2>CINEMA PRO</h2>
                <p>Staff Panel</p>
            </div>
            <nav>
                <a href="${pageContext.request.contextPath}/staffdashboard" class="active">Thông tin rạp của tôi</a>
                <a href="${pageContext.request.contextPath}/staff/rooms">Quản lý phòng chiếu</a>
                <a href="${pageContext.request.contextPath}/staff/seat-design">Thiết kế ghế trong phòng</a>
                <a href="${pageContext.request.contextPath}/staff/schedules">Quản lý lịch chiếu</a>
                <a href="${pageContext.request.contextPath}/views/staff/bookingManager.jsp">Quản lý đặt vé</a>
            </nav>
            <a href="${pageContext.request.contextPath}/logout" class="logout">Đăng xuất</a>
        </div>


        <header>
            <h1>Bảng điều khiển nhân viên</h1>
            <div class="header-right">
                <c:if test="${not empty staffUser}">
                    <span>${staffUser.username} (${staffUser.role})</span>
                </c:if>
                <c:if test="${empty staffUser}">
                    <span>Nhân viên</span>
                </c:if>
                <span><%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %></span>
            </div>
        </header>

        <!-- Main content -->
        <div class="content">

            <!-- Stats Cards -->
            <div class="stats-container">
                <div class="stat-box">
                    <h3>Tổng vé đã bán</h3>
                    <div class="stat-value">
                        ${ticketsSoldToday}
                    </div>
                    <div class="stat-change">
                        Tổng vé đã bán của rạp
                    </div>
                </div>

                <div class="stat-box">
                    <h3>Tổng doanh thu rạp</h3>
                    <div class="stat-value" style="font-size: 1.6em;">
                        <fmt:formatNumber value="${revenueCurrentShift}" type="number" groupingUsed="true" /> VNĐ
                    </div>
                    <div class="stat-change">Doanh thu tổng của rạp</div>
                </div>

                <div class="stat-box">
                    <h3>Phòng đang hoạt động</h3>
                    <div class="stat-value">
                        ${activeRooms} / ${totalRooms}
                    </div>
                    <div class="stat-change">
                        Cập nhật theo trạng thái phòng
                    </div>
                </div>
            </div>


            <h2 class="section-title">Suất chiếu hôm nay</h2>
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>Id</th>
                            <th>Phim</th>
                            <th>Phòng</th>
                            <th>Bắt đầu</th>
                            <th>Kết thúc</th>
                            <th>Trạng thái</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="schedule" items="${todaySchedules}">
                            <tr>
                                <td>${schedule.id}</td>
                                <td><strong>${schedule.movieName}</strong></td>
                                <td>${schedule.roomName}</td>
                                <td><fmt:formatDate value="${schedule.startAt}" pattern="HH:mm" /></td>
                                <td><fmt:formatDate value="${schedule.finishAt}" pattern="HH:mm" /></td>
                                <td class="${schedule.status == 'Đang hoạt động' ? 'status-success' : 'status-pending'}">
                                    ${schedule.status}
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>




            <h2 class="section-title">Đặt vé gần đây</h2>
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
                        <c:forEach var="booking" items="${recentBookings}">
                            <tr>
                                <td>#${booking.ticketCode}</td>
                                <td>${booking.customerName}</td>
                                <td>${booking.movieName}</td>
                                <td><fmt:formatDate value="${booking.showtime}" pattern="HH:mm dd/MM/yyyy"/></td>
                                <td>${booking.seatsFormatted}</td>
                                <td>${booking.totalAmountFormatted}</td>
                                <td class="${booking.statusBadgeClass}">${booking.statusFormatted}</td>
                            </tr>
                        </c:forEach>

                    </tbody>
                </table>
            </div>

            <!-- Footer -->
            <footer>
                © 2025 Cinema Booking System - staff Panel | Powered by Modern Technology
            </footer>

    </body>
</html>


