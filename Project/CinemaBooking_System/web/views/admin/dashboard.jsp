<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Admin Dashboard | Cinema Booking</title>
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
                /* Bỏ gradient text */
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



            /* ===== Table Style ===== */
            table {
                width: 100%;
                border-collapse: separate;
                border-spacing: 0;
                font-family: 'Inter', sans-serif;
                min-width: 700px;
            }
            .table-container th,
            .table-container td {
                font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            }


            /* ===== Table Header ===== */
            thead th {
                background: #3EABF5; /* tím đậm */
                color: #ffffff;
                font-weight: 600;
                text-transform: uppercase;
                font-size: 13px;
                letter-spacing: 1px;
                padding: 16px 20px;
                text-align: left;
                position: sticky;
                top: 0;
                z-index: 1;
            }

            /* Bo góc header */
            thead th:first-child {
                border-top-left-radius: 15px;
            }
            thead th:last-child {
                border-top-right-radius: 15px;
            }

            /* ===== Table Rows ===== */
            tbody tr {
                background: #f9fafb;
                transition: all 0.2s ease;
                cursor: default;
            }

            tbody tr:nth-child(even) {
                background: #f3f4f6;
            }

            tbody tr:hover {
                background: linear-gradient(90deg, #7FE7FF, #7FE7FF);
                color: #ffffff;
                transform: translateY(-2px);
            }

            /* ===== Table Cells ===== */
            td {
                padding: 14px 20px;
                border-bottom: 1px solid #e5e7eb;
                font-size: 13px;
                color: #1f2937;
                transition: all 0.2s ease;
            }

            /* Bo góc footer nếu có */
            tbody tr:last-child td:first-child {
                border-bottom-left-radius: 15px;
            }
            tbody tr:last-child td:last-child {
                border-bottom-right-radius: 15px;
            }

            /* ===== Time Badge ===== */
            .time-badge {
                background: #e0e7ff;
                color: #4338ca;
                padding: 4px 10px;
                border-radius: 12px;
                font-weight: 600;
                font-size: 12px;
                display: inline-block;
            }

            /* ===== Price Highlight ===== */
            td:nth-child(7) {
                font-weight: 700;
                color: #ef4444; /* đỏ nổi bật */
            }

            /* ===== Status Badges ===== */
            .status-badge {
                padding: 6px 12px;
                border-radius: 9999px; /* bo tròn tròn */
                font-size: 12px;
                font-weight: 600;
                display: inline-block;
                text-align: center;
                transition: all 0.2s ease;
            }

            .status-active {
                background: #d1fae5;
                color: #059669;
            }

            .status-inactive {
                background: #fee2e2;
                color: #b91c1c;
            }

            /* ===== Responsive ===== */
            @media (max-width: 768px) {
                table {
                    font-size: 13px;
                }

                th, td {
                    padding: 12px 15px;
                }

                .time-badge {
                    font-size: 11px;
                    padding: 3px 8px;
                }
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

        <div class="sidebar">
            <div class="sidebar-logo">
                <h2>🎬 CINEMA PRO</h2>
                <p>Admin Panel</p>
            </div>
            <nav>
                <a href="${pageContext.request.contextPath}/admindashboard" class="active">📊 Bảng điều khiển</a>
                <a href="${pageContext.request.contextPath}/admin/user">👥 Quản lý người dùng</a>
                <a href="${pageContext.request.contextPath}/admin/staff">🧑‍💼 Quản lý nhân viên</a>
                <a href="${pageContext.request.contextPath}/admin/cinemas">🏢 Quản lý rạp</a>
                <a href="${pageContext.request.contextPath}/admin/movies">🎞️ Quản lý phim</a>
                <a href="${pageContext.request.contextPath}/admin/seat-types">💺 Quản lý loại ghế</a>
                <a href="${pageContext.request.contextPath}/views/admin/paymentManager.jsp">💳 Quản lý thanh toán</a>
                <a href="${pageContext.request.contextPath}/admin/vouchers">🎫 Quản lý Voucher</a>
            </nav>
            <a href="${pageContext.request.contextPath}/logout" class="logout">🚪 Đăng xuất</a>
        </div>

        <header>
            <h1>Bảng điều khiển tổng quan</h1>
            <div class="header-right">
                <span>👤 Admin: Nguyễn Văn A</span>
                <span>⏰ <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %></span>
            </div>
        </header>

        <div class="content">

            <div class="stats-container">
                <div class="stat-box">
                    <h3>🎟️ Tổng vé đã bán</h3>
                    <div class="stat-value">${totalTickets}</div>
                    <div class="stat-change">↑ 1,6% so với tháng trước</div>
                </div>
                <div class="stat-box">
                    <h3>💰 Doanh thu tháng này</h3>
                    <div class="stat-value" style="font-size: 1.6em;">
                        <fmt:formatNumber value="${totalRevenue}" type="number" groupingUsed="true" /> VNĐ
                    </div>
                    <div class="stat-change">↑ 8.3% so với hôm qua</div>
                </div>
                <div class="stat-box">
                    <h3>🏢 Rạp hoạt động</h3>
                    <div class="stat-value">${activeCinemas} / ${totalCinemas}</div>
                    <div class="stat-change negative"></div>
                </div>
                <div class="stat-box">
                    <h3>🎬 Phim đang chiếu</h3>
                    <div class="stat-value">${activeMovies} / ${totalMovies}</div>
                    <div class="stat-change">↑ 2 phim mới tuần này</div>
                </div>
                <div class="stat-box">
                    <h3>👥 Người dùng</h3>
                    <div class="stat-value">${totalUsers}</div>
                    <div class="stat-change">↑ 2% so với tuần trước</div>
                </div>
            </div>

            <h2 class="section-title">📈 Thống kê và xu hướng</h2>
            <div class="charts-grid">
                <div class="chart-box">
                    <h3>Doanh thu theo tháng</h3>
                    <canvas id="monthlyRevenueChart"></canvas>
                </div>

                <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

                <script>
                    // Lấy dữ liệu từ server (JSP)
                    const labels = [];
                    const data = [];

                    <c:forEach var="entry" items="${revenueByMonth}">
                    labels.push("${entry.key}");
                    data.push(${entry.value});
                    </c:forEach>

                    console.log("📅 Labels:", labels);
                    console.log("💰 Data:", data);

                    // Nếu không có dữ liệu
                    if (labels.length === 0) {
                        document.getElementById('monthlyRevenueChart').insertAdjacentHTML(
                                'beforebegin',
                                '<p style="color:red">⚠️ Không có dữ liệu doanh thu để hiển thị!</p>'
                                );
                    } else {
                        const ctx = document.getElementById('monthlyRevenueChart').getContext('2d');
                        new Chart(ctx, {
                            type: 'bar',
                            data: {
                                labels: labels,
                                datasets: [{
                                        label: 'Doanh thu (VNĐ)',
                                        data: data,
                                        backgroundColor: 'rgba(54, 162, 235, 0.7)',
                                        borderRadius: 8
                                    }]
                            },
                            options: {
                                responsive: true,
                                plugins: {
                                    legend: {display: false},
                                    tooltip: {
                                        callbacks: {
                                            label: function (context) {
                                                return context.parsed.y.toLocaleString('vi-VN') + ' VNĐ';
                                            }
                                        }
                                    }
                                },
                                scales: {
                                    y: {
                                        beginAtZero: true,
                                        ticks: {
                                            callback: function (value) {
                                                return value.toLocaleString('vi-VN') + ' ₫';
                                            }
                                        }
                                    }
                                }
                            }
                        });
                    }
                </script>
            </div>

            <h2 class="section-title">🧾 Giao dịch gần đây</h2>
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Phim</th>
                            <th>Tên lịch</th>
                            <th>Phòng</th>
                            <th>Rạp</th>
                            <th>Bắt đầu</th>
                            <th>Giá vé</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="schedule" items="${recentSchedules}">
                            <tr>
                                <td>${schedule.id}</td>
                                <td>${schedule.movieName}</td>
                                <td>${schedule.name}</td>
                                <td>${schedule.roomName}</td>
                                <td>${schedule.cinemaName}</td>
                                <td><fmt:formatDate value="${schedule.startAt}" pattern="yyyy-MM-dd HH:mm"/></td>
                                <td>
    <fmt:formatNumber value="${schedule.price}" type="number" maxFractionDigits="0" groupingUsed="true"/>
    VNĐ
</td>

                            </tr>
                        </c:forEach>
                    </tbody>
                </table>


            </div>
        </div>

                    <footer>
                        © 2025 Cinema Booking System - Admin Panel | Powered by Modern Technology
                    </footer>

    </body>
</html>