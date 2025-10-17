<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý Nhân viên | Cinema Booking</title>
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

        /* ===== Stats Cards ===== */
        .stats-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 25px;
            margin-bottom: 40px;
        }

        .stat-box {
            background: linear-gradient(135deg, rgba(15, 20, 25, 0.9) 0%, rgba(26, 31, 46, 0.9) 100%);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(0, 255, 255, 0.15);
            border-radius: 20px;
            padding: 25px;
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
            border-color: rgba(0, 255, 255, 0.3);
            box-shadow: 0 10px 40px rgba(0, 212, 255, 0.2);
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
            font-size: 32px;
            font-weight: 700;
            background: linear-gradient(135deg, #ffffff 0%, #00d4ff 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        /* ===== Toolbar ===== */
        .toolbar {
            background: linear-gradient(135deg, rgba(15, 20, 25, 0.9) 0%, rgba(26, 31, 46, 0.9) 100%);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(0, 255, 255, 0.15);
            border-radius: 20px;
            padding: 25px 30px;
            margin-bottom: 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
        }

        .search-box {
            display: flex;
            gap: 15px;
            flex: 1;
            min-width: 300px;
        }

        .search-box input {
            flex: 1;
            background: rgba(0, 212, 255, 0.05);
            border: 1px solid rgba(0, 255, 255, 0.2);
            border-radius: 12px;
            padding: 12px 20px;
            color: #e4e9f0;
            font-size: 14px;
            outline: none;
            transition: all 0.3s ease;
        }

        .search-box input:focus {
            border-color: #00d4ff;
            box-shadow: 0 0 20px rgba(0, 212, 255, 0.3);
        }

        .search-box input::placeholder {
            color: #6b7280;
        }

        .search-box select {
            background: rgba(0, 212, 255, 0.05);
            border: 1px solid rgba(0, 255, 255, 0.2);
            border-radius: 12px;
            padding: 12px 20px;
            color: #e4e9f0;
            font-size: 14px;
            outline: none;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .search-box select:focus {
            border-color: #00d4ff;
        }

        .btn {
            background: linear-gradient(135deg, #00d4ff 0%, #0099ff 100%);
            color: white;
            border: none;
            border-radius: 12px;
            padding: 12px 28px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(0, 212, 255, 0.4);
        }

        /* ===== Table Container ===== */
        .table-container {
            background: linear-gradient(135deg, rgba(15, 20, 25, 0.9) 0%, rgba(26, 31, 46, 0.9) 100%);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(0, 255, 255, 0.15);
            border-radius: 20px;
            padding: 30px;
            overflow-x: auto;
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
            padding: 15px;
            text-align: left;
            border-bottom: 2px solid rgba(0, 212, 255, 0.2);
        }

        td {
            padding: 18px 15px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
            color: #94a3b8;
            font-size: 14px;
        }

        tr:hover td {
            background: rgba(0, 212, 255, 0.05);
            color: #e4e9f0;
        }

        .staff-avatar {
            width: 45px;
            height: 45px;
            border-radius: 50%;
            background: linear-gradient(135deg, #00d4ff 0%, #0099ff 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            color: white;
            font-size: 16px;
        }

        .role-badge {
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            display: inline-block;
        }

        .role-admin {
            background: rgba(239, 68, 68, 0.2);
            color: #ef4444;
            border: 1px solid rgba(239, 68, 68, 0.3);
        }

        .role-manager {
            background: rgba(251, 146, 60, 0.2);
            color: #fb923c;
            border: 1px solid rgba(251, 146, 60, 0.3);
        }

        .role-staff {
            background: rgba(16, 185, 129, 0.2);
            color: #10b981;
            border: 1px solid rgba(16, 185, 129, 0.3);
        }

        .role-support {
            background: rgba(59, 130, 246, 0.2);
            color: #3b82f6;
            border: 1px solid rgba(59, 130, 246, 0.3);
        }

        .status-badge {
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            display: inline-block;
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

        .status-leave {
            background: rgba(251, 146, 60, 0.2);
            color: #fb923c;
            border: 1px solid rgba(251, 146, 60, 0.3);
        }

        .action-buttons {
            display: flex;
            gap: 8px;
        }

        .btn-small {
            padding: 8px 16px;
            font-size: 12px;
            border-radius: 8px;
            border: none;
            cursor: pointer;
            transition: all 0.3s ease;
            font-weight: 600;
        }

        .btn-edit {
            background: rgba(0, 212, 255, 0.2);
            color: #00d4ff;
            border: 1px solid rgba(0, 212, 255, 0.3);
        }

        .btn-edit:hover {
            background: rgba(0, 212, 255, 0.3);
            transform: translateY(-2px);
        }

        .btn-delete {
            background: rgba(239, 68, 68, 0.2);
            color: #ef4444;
            border: 1px solid rgba(239, 68, 68, 0.3);
        }

        .btn-delete:hover {
            background: rgba(239, 68, 68, 0.3);
            transform: translateY(-2px);
        }

        .btn-view {
            background: rgba(139, 92, 246, 0.2);
            color: #8b5cf6;
            border: 1px solid rgba(139, 92, 246, 0.3);
        }

        .btn-view:hover {
            background: rgba(139, 92, 246, 0.3);
            transform: translateY(-2px);
        }

        /* ===== Pagination ===== */
        .pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 10px;
            margin-top: 30px;
        }

        .pagination button {
            background: rgba(0, 212, 255, 0.1);
            border: 1px solid rgba(0, 255, 255, 0.2);
            color: #00d4ff;
            padding: 10px 16px;
            border-radius: 10px;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .pagination button:hover {
            background: rgba(0, 212, 255, 0.2);
            transform: translateY(-2px);
        }

        .pagination button.active {
            background: linear-gradient(135deg, #00d4ff 0%, #0099ff 100%);
            color: white;
            border-color: transparent;
        }

        /* ===== Modal ===== */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.7);
            backdrop-filter: blur(5px);
            z-index: 2000;
            justify-content: center;
            align-items: center;
        }

        .modal.active {
            display: flex;
        }

        .modal-content {
            background: linear-gradient(135deg, rgba(15, 20, 25, 0.95) 0%, rgba(26, 31, 46, 0.95) 100%);
            border: 1px solid rgba(0, 255, 255, 0.2);
            border-radius: 20px;
            padding: 40px;
            max-width: 550px;
            width: 90%;
            max-height: 85vh;
            overflow-y: auto;
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }

        .modal-header h2 {
            font-size: 24px;
            background: linear-gradient(135deg, #ffffff 0%, #00d4ff 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .close-modal {
            background: rgba(239, 68, 68, 0.2);
            border: none;
            color: #ef4444;
            font-size: 24px;
            width: 35px;
            height: 35px;
            border-radius: 50%;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .close-modal:hover {
            background: rgba(239, 68, 68, 0.3);
            transform: rotate(90deg);
        }

        .form-group {
            margin-bottom: 20px;
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
            padding: 12px 16px;
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

        .form-actions {
            display: flex;
            gap: 15px;
            margin-top: 30px;
        }

        .form-actions button {
            flex: 1;
        }

        .btn-cancel {
            background: rgba(107, 114, 128, 0.2);
            color: #9ca3af;
            border: 1px solid rgba(107, 114, 128, 0.3);
        }

        .btn-cancel:hover {
            background: rgba(107, 114, 128, 0.3);
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
            <a href="${pageContext.request.contextPath}/views/admin/staffManager.jsp" class="active">🧑‍💼 Quản lý nhân viên</a>
            <a href="${pageContext.request.contextPath}/views/admin/cinemaManager.jsp">🏢 Quản lý rạp</a>
            <a href="${pageContext.request.contextPath}/views/admin/paymentManager.jsp">💳 Quản lý thanh toán</a>
        </nav>
        <a href="${pageContext.request.contextPath}/logout" class="logout">🚪 Đăng xuất</a>
    </div>

    <!-- Header -->
    <header>
        <h1>🧑‍💼 Quản lý nhân viên</h1>
        <div class="header-right">
            <span>👤 Admin: Nguyễn Văn A</span>
            <span>⏰ <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %></span>
        </div>
    </header>

    <!-- Main content -->
    <div class="content">

        <!-- Stats -->
        <div class="stats-container">
            <div class="stat-box">
                <h3>👥 Tổng nhân viên</h3>
                <div class="stat-value">87</div>
            </div>
            <div class="stat-box">
                <h3>✅ Đang làm việc</h3>
                <div class="stat-value">74</div>
            </div>
            <div class="stat-box">
                <h3>🏖️ Đang nghỉ phép</h3>
                <div class="stat-value">8</div>
            </div>
            <div class="stat-box">
                <h3>🆕 Mới tháng này</h3>
                <div class="stat-value">5</div>
            </div>
        </div>

        <!-- Toolbar -->
        <div class="toolbar">
            <div class="search-box">
                <input type="text" placeholder="🔍 Tìm kiếm theo tên, email, mã nhân viên...">
                <select>
                    <option value="">Tất cả vị trí</option>
                    <option value="admin">Quản trị viên</option>
                    <option value="manager">Quản lý rạp</option>
                    <option value="staff">Nhân viên</option>
                    <option value="support">Hỗ trợ KH</option>
                </select>
                <select>
                    <option value="">Tất cả trạng thái</option>
                    <option value="active">Đang làm việc</option>
                    <option value="leave">Nghỉ phép</option>
                    <option value="inactive">Đã nghỉ việc</option>
                </select>
            </div>
            <button class="btn" onclick="openAddStaffModal()">➕ Thêm nhân viên</button>
        </div>

        <!-- Staff Table -->
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Mã NV</th>
                        <th>Nhân viên</th>
                        <th>Email</th>
                        <th>Số điện thoại</th>
                        <th>Vị trí</th>
                        <th>Rạp phụ trách</th>
                        <th>Ngày vào làm</th>
                        <th>Trạng thái</th>
                        <th>Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>#NV001</td>
                        <td>
                            <div style="display: flex; align-items: center; gap: 12px;">
                                <div class="staff-avatar">PT</div>
                                <span>Phạm Văn Tuấn</span>
                            </div>
                        </td>
                        <td>phamvantuan@cinema.vn</td>
                        <td>0912345001</td>
                        <td><span class="role-badge role-admin">Quản trị viên</span></td>
                        <td>Tất cả</td>
                        <td>01/01/2023</td>
                        <td><span class="status-badge status-active">Đang làm việc</span></td>
                        <td>
                            <div class="action-buttons">
                                <button class="btn-small btn-view" onclick="viewStaff(1)">👁️ Xem</button>
                                <button class="btn-small btn-edit" onclick="editStaff(1)">✏️ Sửa</button>
                                <button class="btn-small btn-delete">🗑️ Xóa</button>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td>#NV002</td>
                        <td>
                            <div style="display: flex; align-items: center; gap: 12px;">
                                <div class="staff-avatar">NTH</div>
                                <span>Nguyễn Thị Hương</span>
                            </div>
                        </td>
                        <td>nguyenthihuong@cinema.vn</td>
                        <td>0987654002</td>
                        <td><span class="role-badge role-manager">Quản lý rạp</span></td>
                        <td>CGV Times City</td>
                        <td>15/02/2023</td>
                        <td><span class="status-badge status-active">Đang làm việc</span></td>
                        <td>
                            <div class="action-buttons">
                                <button class="btn-small btn-view" onclick="viewStaff(2)">👁️ Xem</button>
                                <button class="btn-small btn-edit" onclick="editStaff(2)">✏️ Sửa</button>
                                <button class="btn-small btn-delete">🗑️ Xóa</button>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td>#NV003</td>
                        <td>
                            <div style="display: flex; align-items: center; gap: 12px;">
                                <div class="staff-avatar">LVD</div>
                                <span>Lê Văn Đạt</span>
                            </div>
                        </td>
                        <td>levandat@cinema.vn</td>
                        <td>0901234003</td>
                        <td><span class="role-badge role-manager">Quản lý rạp</span></td>
                        <td>Lotte Hà Đông</td>
                        <td>10/03/2023</td>
                        <td><span class="status-badge status-leave">Nghỉ phép</span></td>
                        <td>
                            <div class="action-buttons">
                                <button class="btn-small btn-view" onclick="viewStaff(3)">👁️ Xem</button>
                                <button class="btn-small btn-edit" onclick="editStaff(3)">✏️ Sửa</button>
                                <button class="btn-small btn-delete">🗑️ Xóa</button>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td>#NV004</td>
                        <td>
                            <div style="display: flex; align-items: center; gap: 12px;">
                                <div class="staff-avatar">TTL</div>
                                <span>Trần Thị Lan</span>
                            </div>
                        </td>
                        <td>tranthilan@cinema.vn</td>
                        <td>0923456004</td>
                        <td><span class="role-badge role-staff">Nhân viên</span></td>
                        <td>CGV Tràng Tiền</td>
                        <td>20/04/2023</td>
                        <td><span class="status-badge status-active">Đang làm việc</span></td>
                        <td>
                            <div class="action-buttons">
                                <button class="btn-small btn-view" onclick="viewStaff(4)">👁️ Xem