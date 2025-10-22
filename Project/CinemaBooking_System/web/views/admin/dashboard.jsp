<%@page contentType="text/html" pageEncoding="UTF-8"%>
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

        .notification-badge {
            position: relative;
            cursor: pointer;
        }

        .notification-badge .badge {
            position: absolute;
            top: -8px;
            right: -8px;
            background: linear-gradient(135deg, #ff0080 0%, #ff0040 100%);
            color: white;
            padding: 3px 7px;
            border-radius: 10px;
            font-size: 11px;
            font-weight: 700;
            box-shadow: 0 0 10px rgba(255, 0, 128, 0.5); 
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

    <div class="sidebar">
        <div class="sidebar-logo">
            <h2>🎬 CINEMA PRO</h2>
            <p>Admin Panel</p>
        </div>
        <nav>
            <a href="${pageContext.request.contextPath}/admindashboard" class="active">📊 Bảng điều khiển</a>
            <a href="${pageContext.request.contextPath}/views/admin/userManager.jsp">👥 Quản lý người dùng</a>
            <a href="${pageContext.request.contextPath}/admin/staff">🧑‍💼 Quản lý nhân viên</a>
            <a href="${pageContext.request.contextPath}/admin/cinemas">🏢 Quản lý rạp</a>
            <a href="${pageContext.request.contextPath}/admin/movies">🎞️ Quản lý phim</a>
            <a href="${pageContext.request.contextPath}/admin/seat-types">💺 Quản lý loại ghế</a>
            <a href="${pageContext.request.contextPath}/views/admin/paymentManager.jsp">💳 Quản lý thanh toán</a>

        </nav>
        <a href="${pageContext.request.contextPath}/logout" class="logout">🚪 Đăng xuất</a>
    </div>

    <header>
        <h1>Bảng điều khiển tổng quan</h1>
        <div class="header-right">
            <span>👤 Admin: Nguyễn Văn A</span>
            <span>⏰ <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %></span>
            <div class="notification-badge">
                <span>🔔</span>
                <span class="badge">3</span>
            </div>
        </div>
    </header>

    <div class="content">

        <div class="stats-container">
            <div class="stat-box">
                <h3>🎟️ Tổng vé đã bán</h3>
                <div class="stat-value">25,340</div>
                <div class="stat-change">↑ 12.5% so với tháng trước</div>
            </div>
            <div class="stat-box">
                <h3>💰 Doanh thu hôm nay</h3>
                <div class="stat-value">3.2 tỷ</div>
                <div class="stat-change">↑ 8.3% so với hôm qua</div>
            </div>
            <div class="stat-box">
                <h3>🏢 Rạp hoạt động</h3>
                <div class="stat-value">15/18</div>
                <div class="stat-change negative">↓ 3 rạp bảo trì</div>
            </div>
            <div class="stat-box">
                <h3>🎬 Phim đang chiếu</h3>
                <div class="stat-value">12</div>
                <div class="stat-change">↑ 2 phim mới tuần này</div>
            </div>
            <div class="stat-box">
                <h3>👥 Người dùng mới</h3>
                <div class="stat-value">152</div>
                <div class="stat-change">↑ 24% so với tuần trước</div>
            </div>
            <div class="stat-box">
                <h3>⚠️ Sự cố hệ thống</h3>
                <div class="stat-value">3</div>
                <div class="stat-change negative">Cần xử lý ngay</div>
            </div>
        </div>

        <h2 class="section-title">📈 Thống kê và xu hướng</h2>
        <div class="charts-grid">
            <div class="chart-box">
                <h3>Doanh thu theo tháng</h3>
                <div class="chart-placeholder">Biểu đồ cột - Doanh thu 12 tháng</div>
            </div>
            <div class="chart-box">
                <h3>Tỷ lệ vé bán theo phim</h3>
                <div class="chart-placeholder">Biểu đồ tròn - Top 5 phim</div>
            </div>
        </div>

        <h2 class="section-title">🧾 Giao dịch gần đây</h2>
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Mã GD</th>
                        <th>Rạp</th>
                        <th>Phim</th>
                        <th>Số vé</th>
                        <th>Thành tiền</th>
                        <th>Thời gian</th>
                        <th>Trạng thái</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>#T1001</td>
                        <td>CGV Times City</td>
                        <td>Venom 3</td>
                        <td>4</td>
                        <td>480,000₫</td>
                        <td>10:35 07/10</td>
                        <td class="status-success">✅ Hoàn tất</td>
                    </tr>
                    <tr>
                        <td>#T1002</td>
                        <td>Lotte Hà Đông</td>
                        <td>Inside Out 2</td>
                        <td>2</td>
                        <td>240,000₫</td>
                        <td>09:15 07/10</td>
                        <td class="status-success">✅ Hoàn tất</td>
                    </tr>
                    <tr>
                        <td>#T1003</td>
                        <td>CGV Tràng Tiền</td>
                        <td>Joker: Folie à Deux</td>
                        <td>1</td>
                        <td>120,000₫</td>
                        <td>08:20 07/10</td>
                        <td class="status-refund">❌ Hoàn tiền</td>
                    </tr>
                    <tr>
                        <td>#T1004</td>
                        <td>Galaxy Nguyễn Du</td>
                        <td>Deadpool & Wolverine</td>
                        <td>3</td>
                        <td>360,000₫</td>
                        <td>11:50 07/10</td>
                        <td class="status-success">✅ Hoàn tất</td>
                    </tr>
                    <tr>
                        <td>#T1005</td>
                        <td>BHD Star Vincom</td>
                        <td>The Marvels</td>
                        <td>5</td>
                        <td>600,000₫</td>
                        <td>14:25 07/10</td>
                        <td class="status-success">✅ Hoàn tất</td>
                    </tr>
                </tbody>
            </table>
        </div>

        <h2 class="section-title">🔔 Thông báo mới</h2>
        <div class="notifications">
            <ul>
                <li><strong>[10:20]</strong> Hệ thống thanh toán VNPay bảo trì lúc 23h đêm nay.</li>
                <li><strong>[09:10]</strong> Rạp Galaxy Nguyễn Trãi yêu cầu hỗ trợ kỹ thuật khẩn cấp.</li>
                <li><strong>[08:30]</strong> Phim mới "Dune: Part Two" đã được thêm vào danh sách chiếu.</li>
                <li><strong>[07:45]</strong> Cập nhật phiên bản hệ thống lên v2.5.3 thành công.</li>
            </ul>
        </div>
    </div>

    <footer>
        © 2025 Cinema Booking System - Admin Panel | Powered by Modern Technology
    </footer>

</body>
</html>