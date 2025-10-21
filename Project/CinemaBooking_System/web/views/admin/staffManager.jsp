<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
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
            flex-wrap: wrap;
        }

        .btn-small {
            padding: 8px 12px;
            font-size: 11px;
            border-radius: 8px;
            border: none;
            cursor: pointer;
            transition: all 0.3s ease;
            font-weight: 600;
            text-decoration: none;
            display: inline-block;
            text-align: center;
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

        .btn-warning {
            background: rgba(251, 146, 60, 0.2);
            color: #fb923c;
            border: 1px solid rgba(251, 146, 60, 0.3);
        }

        .btn-warning:hover {
            background: rgba(251, 146, 60, 0.3);
            transform: translateY(-2px);
        }

        .btn-success {
            background: rgba(16, 185, 129, 0.2);
            color: #10b981;
            border: 1px solid rgba(16, 185, 129, 0.3);
        }

        .btn-success:hover {
            background: rgba(16, 185, 129, 0.3);
            transform: translateY(-2px);
        }

        .btn-primary {
            background: rgba(59, 130, 246, 0.2);
            color: #3b82f6;
            border: 1px solid rgba(59, 130, 246, 0.3);
        }

        .btn-primary:hover {
            background: rgba(59, 130, 246, 0.3);
            transform: translateY(-2px);
        }

        /* ===== Success/Error Messages ===== */
        .alert {
            padding: 15px 20px;
            border-radius: 12px;
            margin-bottom: 20px;
            font-weight: 500;
        }

        .alert-success {
            background: rgba(16, 185, 129, 0.2);
            color: #10b981;
            border: 1px solid rgba(16, 185, 129, 0.3);
        }

        .alert-error {
            background: rgba(239, 68, 68, 0.2);
            color: #ef4444;
            border: 1px solid rgba(239, 68, 68, 0.3);
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
            <a href="${pageContext.request.contextPath}/admin/staff" class="active">🧑‍💼 Quản lý nhân viên</a>
            <a href="${pageContext.request.contextPath}/admin/cinemas">🏢 Quản lý rạp</a>
            <a href="${pageContext.request.contextPath}/admin/movies">🎞️ Quản lý phim</a>
            <a href="${pageContext.request.contextPath}/admin/seat-types">💺 Quản lý loại ghế</a>
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
                <div class="stat-value">${staffList.size()}</div>
            </div>
            <div class="stat-box">
                <h3>✅ Đang làm việc</h3>
                <div class="stat-value">
                    <c:set var="activeCount" value="0" />
                    <c:forEach var="staff" items="${staffList}">
                        <c:if test="${staff.status}">
                            <c:set var="activeCount" value="${activeCount + 1}" />
                        </c:if>
                    </c:forEach>
                    ${activeCount}
                </div>
            </div>
            <div class="stat-box">
                <h3>🏢 Có phân công</h3>
                <div class="stat-value">
                    <c:set var="assignedCount" value="0" />
                    <c:forEach var="staff" items="${staffList}">
                        <c:if test="${staff.hasCinemaAssignment()}">
                            <c:set var="assignedCount" value="${assignedCount + 1}" />
                        </c:if>
                    </c:forEach>
                    ${assignedCount}
                </div>
            </div>
            <div class="stat-box">
                <h3>🆕 Mới tháng này</h3>
                <div class="stat-value">
                    <c:set var="newThisMonth" value="0" />
                    <c:forEach var="staff" items="${staffList}">
                        <c:if test="${staff.createdAt != null}">
                            <c:set var="createdMonth" value="${staff.createdAt.month + 1}" />
                            <c:set var="currentMonth" value="<%= java.util.Calendar.getInstance().get(java.util.Calendar.MONTH) + 1 %>" />
                            <c:if test="${createdMonth == currentMonth}">
                                <c:set var="newThisMonth" value="${newThisMonth + 1}" />
                            </c:if>
                        </c:if>
                    </c:forEach>
                    ${newThisMonth}
                </div>
            </div>
        </div>

        <!-- Success/Error Messages -->
        <c:if test="${not empty param.success}">
            <div class="alert alert-success">
                <c:choose>
                    <c:when test="${param.success == 'create'}">✅ Thêm nhân viên thành công!</c:when>
                    <c:when test="${param.success == 'update'}">✅ Cập nhật nhân viên thành công!</c:when>
                    <c:when test="${param.success == 'delete'}">✅ Xóa nhân viên thành công!</c:when>
                    <c:when test="${param.success == 'status'}">✅ Cập nhật trạng thái thành công!</c:when>
                    <c:when test="${param.success == 'assign'}">✅ Phân công rạp thành công!</c:when>
                    <c:when test="${param.success == 'update-assignment'}">✅ Cập nhật phân công thành công!</c:when>
                </c:choose>
            </div>
        </c:if>

        <c:if test="${not empty param.error}">
            <div class="alert alert-error">
                <c:choose>
                    <c:when test="${param.error == 'create'}">❌ Lỗi khi thêm nhân viên!</c:when>
                    <c:when test="${param.error == 'update'}">❌ Lỗi khi cập nhật nhân viên!</c:when>
                    <c:when test="${param.error == 'delete'}">❌ Lỗi khi xóa nhân viên!</c:when>
                    <c:when test="${param.error == 'status'}">❌ Lỗi khi cập nhật trạng thái!</c:when>
                </c:choose>
            </div>
        </c:if>

        <!-- Toolbar -->
        <div class="toolbar">
            <form method="get" action="${pageContext.request.contextPath}/admin/staff" class="search-box">
                <input type="text" name="search" placeholder="🔍 Tìm kiếm theo tên, email, mã nhân viên..." 
                       value="${param.search}">
                <select name="roleFilter">
                    <option value="">Tất cả vị trí</option>
                    <option value="admin" ${param.roleFilter == 'admin' ? 'selected' : ''}>Quản trị viên</option>
                    <option value="manager" ${param.roleFilter == 'manager' ? 'selected' : ''}>Quản lý rạp</option>
                    <option value="staff" ${param.roleFilter == 'staff' ? 'selected' : ''}>Nhân viên</option>
                    <option value="support" ${param.roleFilter == 'support' ? 'selected' : ''}>Hỗ trợ KH</option>
                </select>
                <select name="statusFilter">
                    <option value="">Tất cả trạng thái</option>
                    <option value="active" ${param.statusFilter == 'active' ? 'selected' : ''}>Đang làm việc</option>
                    <option value="inactive" ${param.statusFilter == 'inactive' ? 'selected' : ''}>Đã nghỉ việc</option>
                </select>
                <button type="submit" class="btn">🔍 Tìm kiếm</button>
            </form>
            <a href="${pageContext.request.contextPath}/admin/staff?action=add" class="btn">➕ Thêm nhân viên</a>
        </div>

        <!-- Staff Table -->
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Nhân viên</th>
                        <th>Email</th>
                        <th>Số điện thoại</th>
                        <th>Vị trí</th>
                        <th>Rạp phụ trách</th>
                        <th>Ngày tạo</th>
                        <th>Trạng thái</th>
                        <th>Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="staff" items="${staffList}">
                        <tr>
                            <td>#${staff.id}</td>
                            <td>
                                <div style="display: flex; align-items: center; gap: 12px;">
                                    <div class="staff-avatar">
                                        ${staff.username.substring(0, 1).toUpperCase()}
                                    </div>
                                    <span>${staff.username}</span>
                                </div>
                            </td>
                            <td>${staff.email}</td>
                            <td>${staff.phoneNumber}</td>
                            <td>
                                <span class="role-badge 
                                    <c:choose>
                                        <c:when test="${staff.role == 'admin'}">role-admin</c:when>
                                        <c:when test="${staff.role == 'manager'}">role-manager</c:when>
                                        <c:when test="${staff.role == 'staff'}">role-staff</c:when>
                                        <c:otherwise>role-support</c:otherwise>
                                    </c:choose>">
                                    <c:choose>
                                        <c:when test="${staff.role == 'admin'}">Quản trị viên</c:when>
                                        <c:when test="${staff.role == 'manager'}">Quản lý rạp</c:when>
                                        <c:when test="${staff.role == 'staff'}">Nhân viên</c:when>
                                        <c:otherwise>Hỗ trợ KH</c:otherwise>
                                    </c:choose>
                                </span>
                            </td>
                            <td>${staff.cinemaInfo}</td>
                            <td>${staff.formattedCreatedAt}</td>
                            <td>
                                <span class="status-badge ${staff.status ? 'status-active' : 'status-inactive'}">
                                    ${staff.statusText}
                                </span>
                            </td>
                            <td>
                                <div class="action-buttons">
                                    <!-- View -->
                                    <a href="${pageContext.request.contextPath}/admin/staff?action=view&id=${staff.id}" 
                                       class="btn-small btn-view">👁️ Xem</a>
                                    
                                    <!-- Edit -->
                                    <a href="${pageContext.request.contextPath}/admin/staff?action=edit&id=${staff.id}" 
                                       class="btn-small btn-edit">✏️ Sửa</a>
                                    
                                    <!-- Toggle Status -->
                                    <c:choose>
                                        <c:when test="${staff.status}">
                                            <a href="${pageContext.request.contextPath}/admin/staff?action=toggle-status&id=${staff.id}&status=false" 
                                               class="btn-small btn-warning">🚫 Vô hiệu</a>
                                        </c:when>
                                        <c:otherwise>
                                            <a href="${pageContext.request.contextPath}/admin/staff?action=toggle-status&id=${staff.id}&status=true" 
                                               class="btn-small btn-success">✅ Kích hoạt</a>
                                        </c:otherwise>
                                    </c:choose>
                                    
                                    <!-- Delete -->
                                    <a href="${pageContext.request.contextPath}/admin/staff?action=delete&id=${staff.id}" 
                                       class="btn-small btn-delete" 
                                       onclick="return confirm('Bạn có chắc muốn xóa nhân viên ${staff.username}?')">🗑️ Xóa</a>
                                    
                                    <!-- Assign Cinema -->
                                    <a href="${pageContext.request.contextPath}/admin/staff?action=assign-cinema&staffId=${staff.id}" 
                                       class="btn-small btn-primary">🏢 Phân công</a>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>

            <c:if test="${empty staffList}">
                <div style="text-align: center; padding: 40px; color: #94a3b8;">
                    <p>📭 Không có nhân viên nào được tìm thấy.</p>
                </div>
            </c:if>
        </div>

        <!-- Pagination (có thể thêm sau) -->
        <!-- <div class="pagination">
            <button>‹</button>
            <button class="active">1</button>
            <button>2</button>
            <button>3</button>
            <button>›</button>
        </div> -->
    </div>

    <!-- Footer -->
    <footer>
        <p>© 2024 Cinema Booking System. All rights reserved.</p>
    </footer>

</body>
</html>