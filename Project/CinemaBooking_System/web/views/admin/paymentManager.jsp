<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý Thanh toán | Cinema Booking</title>
    <%-- Kế thừa toàn bộ CSS từ trang Dashboard để đảm bảo đồng bộ --%>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
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

        /* ===== Sidebar (Giữ nguyên) ===== */
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

        /* ===== Header (Giữ nguyên) ===== */
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


        /* ===== Content (Giữ nguyên) ===== */
        .content {
            margin-left: 280px;
            padding: 40px;
        }
        .section-title {
            font-size: 24px;
            font-weight: 700;
            margin-bottom: 25px;
            background: linear-gradient(135deg, #ffffff 0%, #00d4ff 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        /* ===== Filter Bar (CSS MỚI) ===== */
        .filter-container {
            background: linear-gradient(135deg, rgba(15, 20, 25, 0.9) 0%, rgba(26, 31, 46, 0.9) 100%);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(0, 255, 255, 0.15);
            border-radius: 20px;
            padding: 25px;
            margin-bottom: 40px;
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
            align-items: flex-end;
        }
        .filter-group {
            display: flex;
            flex-direction: column;
            gap: 8px;
            flex-grow: 1;
        }
        .filter-group label {
            font-size: 13px;
            font-weight: 500;
            color: #94a3b8;
        }
        .filter-group input, .filter-group select {
            background: rgba(0, 0, 0, 0.3);
            border: 1px solid #334155;
            border-radius: 8px;
            padding: 10px 12px;
            color: #e4e9f0;
            font-family: 'Inter', sans-serif;
            font-size: 14px;
            transition: border-color 0.3s, box-shadow 0.3s;
        }
        .filter-group input:focus, .filter-group select:focus {
            outline: none;
            border-color: #00d4ff;
            box-shadow: 0 0 0 3px rgba(0, 212, 255, 0.2);
        }
        .filter-buttons button {
            padding: 10px 20px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s ease;
            font-size: 14px;
        }
        .btn-filter {
            background: linear-gradient(135deg, #00d4ff 0%, #0099ff 100%);
            color: #0a0e27;
        }
        .btn-filter:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(0, 212, 255, 0.3);
        }
        .btn-clear {
            background: rgba(107, 114, 128, 0.3);
            color: #e4e9f0;
            margin-left: 10px;
        }
        .btn-clear:hover {
             background: rgba(107, 114, 128, 0.5);
        }

        /* ===== Table Section (Tái sử dụng & tinh chỉnh) ===== */
        .table-container {
            background: linear-gradient(135deg, rgba(15, 20, 25, 0.9) 0%, rgba(26, 31, 46, 0.9) 100%);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(0, 255, 255, 0.15);
            border-radius: 20px;
            padding: 0;
            margin-bottom: 40px;
            overflow: hidden; /* Để bo tròn góc cho table */
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        th {
            background: rgba(0, 212, 255, 0.08);
            color: #00d4ff;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 12px;
            letter-spacing: 1px;
            padding: 18px 20px;
            text-align: left;
        }

        td {
            padding: 18px 20px;
            border-top: 1px solid rgba(255, 255, 255, 0.05);
            color: #94a3b8;
            font-size: 14px;
        }

        tr:hover td {
            background: rgba(0, 212, 255, 0.05);
            color: #e4e9f0;
        }
        
        .status {
            padding: 5px 10px;
            border-radius: 12px;
            font-weight: 600;
            font-size: 12px;
            display: inline-block;
        }

        .status-success {
            background-color: rgba(16, 185, 129, 0.1);
            color: #10b981;
        }
        .status-refunded {
            background-color: rgba(239, 68, 68, 0.1);
            color: #ef4444;
        }
        .status-pending {
            background-color: rgba(245, 158, 11, 0.1);
            color: #f59e0b;
        }
        .status-failed {
            background-color: rgba(107, 114, 128, 0.1);
            color: #6b7280;
        }
        
        .action-buttons button {
            background: none;
            border: 1px solid #334155;
            color: #94a3b8;
            padding: 6px 12px;
            border-radius: 6px;
            cursor: pointer;
            margin-right: 8px;
            transition: all 0.3s ease;
        }
        .action-buttons button:hover {
            border-color: #00d4ff;
            color: #00d4ff;
            background: rgba(0, 212, 255, 0.1);
        }

        /* ===== Pagination (CSS MỚI) ===== */
        .pagination-container {
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 25px 0;
        }
        .pagination a {
            color: #94a3b8;
            padding: 8px 14px;
            text-decoration: none;
            transition: background-color .3s;
            border: 1px solid #334155;
            margin: 0 4px;
            border-radius: 6px;
        }
        .pagination a.active {
            background: linear-gradient(135deg, #00d4ff 0%, #0099ff 100%);
            color: #0a0e27;
            font-weight: 700;
            border-color: #00d4ff;
        }
        .pagination a:hover:not(.active) {
            background-color: rgba(0, 212, 255, 0.1);
            border-color: #00d4ff;
        }

        /* ===== Footer (Giữ nguyên) ===== */
        footer {
            background: rgba(15, 20, 25, 0.9);
            backdrop-filter: blur(10px);
            border-top: 1px solid rgba(0, 255, 255, 0.1);
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
            <h2>🎬 CINEMA PRO</h2>
            <p>Admin Panel</p>
        </div>
        <nav>
            <a href="${pageContext.request.contextPath}/admindashboard">📊 Bảng điều khiển</a>
            <a href="${pageContext.request.contextPath}/views/admin/userManager.jsp">👥 Quản lý người dùng</a>
            <a href="${pageContext.request.contextPath}/admin/staff">🧑‍💼 Quản lý nhân viên</a>
            <a href="${pageContext.request.contextPath}/admin/cinemas">🏢 Quản lý rạp</a>
            <a href="${pageContext.request.contextPath}/admin/seat-types">💺 Quản lý loại ghế</a>
            <%-- Đánh dấu trang hiện tại là active --%>
            <a href="${pageContext.request.contextPath}/views/admin/paymentManager.jsp" class="active">💳 Quản lý thanh toán</a>
        </nav>
        <a href="${pageContext.request.contextPath}/logout" class="logout">🚪 Đăng xuất</a>
    </div>

    <header>
        <h1>Quản lý thanh toán</h1>
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

        <h2 class="section-title">🔍 Lọc và tìm kiếm giao dịch</h2>
        <div class="filter-container">
            <div class="filter-group">
                <label for="transactionId">Mã Giao Dịch</label>
                <input type="text" id="transactionId" placeholder="VD: #PAY12345">
            </div>
            <div class="filter-group">
                <label for="userEmail">Email Người Dùng</label>
                <input type="email" id="userEmail" placeholder="VD: user@example.com">
            </div>
            <div class="filter-group">
                <label for="status">Trạng Thái</label>
                <select id="status">
                    <option value="">Tất cả</option>
                    <option value="success">Thành công</option>
                    <option value="pending">Đang chờ</option>
                    <option value="failed">Thất bại</option>
                    <option value="refunded">Đã hoàn tiền</option>
                </select>
            </div>
            <div class="filter-group">
                <label for="paymentMethod">Phương Thức</label>
                <select id="paymentMethod">
                    <option value="">Tất cả</option>
                    <option value="vnpay">VNPAY</option>
                    <option value="momo">MoMo</option>
                    <option value="creditcard">Thẻ tín dụng</option>
                    <option value="atcounter">Tại quầy</option>
                </select>
            </div>
            <div class="filter-buttons">
                <button class="btn-filter">Lọc</button>
                <button class="btn-clear">Xóa bộ lọc</button>
            </div>
        </div>


        <h2 class="section-title">📑 Danh sách Giao dịch</h2>
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Mã GD</th>
                        <th>Người dùng</th>
                        <th>Tổng tiền</th>
                        <th>Phương thức</th>
                        <th>Thời gian</th>
                        <th>Trạng thái</th>
                        <th>Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <%-- Dữ liệu mẫu - Sẽ được thay thế bằng vòng lặp JSTL/Servlet --%>
                    <tr>
                        <td>#PAY12345</td>
                        <td>user1@gmail.com</td>
                        <td>480,000₫</td>
                        <td>VNPAY</td>
                        <td>08/10/2025 14:20</td>
                        <td><span class="status status-success">Thành công</span></td>
                        <td class="action-buttons">
                            <button>Chi tiết</button>
                            <button>Hoàn tiền</button>
                        </td>
                    </tr>
                    <tr>
                        <td>#PAY12346</td>
                        <td>user2@yahoo.com</td>
                        <td>240,000₫</td>
                        <td>MoMo</td>
                        <td>08/10/2025 11:55</td>
                        <td><span class="status status-success">Thành công</span></td>
                        <td class="action-buttons">
                            <button>Chi tiết</button>
                            <button>Hoàn tiền</button>
                        </td>
                    </tr>
                     <tr>
                        <td>#PAY12347</td>
                        <td>test@domain.com</td>
                        <td>120,000₫</td>
                        <td>Thẻ tín dụng</td>
                        <td>07/10/2025 22:10</td>
                        <td><span class="status status-refunded">Đã hoàn tiền</span></td>
                        <td class="action-buttons">
                            <button>Chi tiết</button>
                        </td>
                    </tr>
                    <tr>
                        <td>#PAY12348</td>
                        <td>anotheruser@mail.com</td>
                        <td>360,000₫</td>
                        <td>VNPAY</td>
                        <td>07/10/2025 19:30</td>
                        <td><span class="status status-failed">Thất bại</span></td>
                        <td class="action-buttons">
                            <button>Chi tiết</button>
                        </td>
                    </tr>
                    <tr>
                        <td>#PAY12349</td>
                        <td>newcustomer@outlook.com</td>
                        <td>600,000₫</td>
                        <td>Tại quầy</td>
                        <td>06/10/2025 18:00</td>
                        <td><span class="status status-pending">Đang chờ</span></td>
                         <td class="action-buttons">
                            <button>Chi tiết</button>
                            <button>Hủy</button>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
        
        <div class="pagination-container">
            <div class="pagination">
              <a href="#">&laquo;</a>
              <a href="#" class="active">1</a>
              <a href="#">2</a>
              <a href="#">3</a>
              <a href="#">4</a>
              <a href="#">&raquo;</a>
            </div>
        </div>

    </div>

    <footer>
        © 2025 Cinema Booking System - Admin Panel | Powered by Modern Technology
    </footer>

</body>
</html>