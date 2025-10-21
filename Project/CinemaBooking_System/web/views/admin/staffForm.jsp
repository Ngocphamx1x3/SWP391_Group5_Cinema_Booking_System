<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>
        <c:choose>
            <c:when test="${not empty staff && viewMode}">Thông tin nhân viên</c:when>
            <c:when test="${not empty staff}">Chỉnh sửa nhân viên</c:when>
            <c:otherwise>Thêm nhân viên mới</c:otherwise>
        </c:choose>
        | Cinema Booking
    </title>
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

        /* ===== Form Container ===== */
        .form-container {
            background: linear-gradient(135deg, rgba(15, 20, 25, 0.9) 0%, rgba(26, 31, 46, 0.9) 100%);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(0, 255, 255, 0.15);
            border-radius: 20px;
            padding: 40px;
            max-width: 600px;
            margin: 0 auto;
        }

        .form-group {
            margin-bottom: 25px;
        }

        .form-group label {
            display: block;
            color: #94a3b8;
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 8px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .form-group input,
        .form-group select {
            width: 100%;
            background: rgba(0, 212, 255, 0.05);
            border: 1px solid rgba(0, 255, 255, 0.2);
            border-radius: 12px;
            padding: 14px 16px;
            color: #e4e9f0;
            font-size: 15px;
            outline: none;
            transition: all 0.3s ease;
            font-family: 'Inter', sans-serif;
        }

        .form-group input:focus,
        .form-group select:focus {
            border-color: #00d4ff;
            box-shadow: 0 0 20px rgba(0, 212, 255, 0.3);
        }

        .form-group input:read-only {
            background: rgba(107, 114, 128, 0.1);
            color: #6b7280;
            cursor: not-allowed;
        }

        .form-actions {
            display: flex;
            gap: 15px;
            margin-top: 30px;
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
            text-decoration: none;
            justify-content: center;
        }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(0, 212, 255, 0.4);
        }

        .btn-cancel {
            background: rgba(107, 114, 128, 0.2);
            color: #9ca3af;
            border: 1px solid rgba(107, 114, 128, 0.3);
        }

        .btn-cancel:hover {
            background: rgba(107, 114, 128, 0.3);
        }

        /* Switch Toggle */
        .switch {
            position: relative;
            display: inline-block;
            width: 60px;
            height: 34px;
        }

        .switch input {
            opacity: 0;
            width: 0;
            height: 0;
        }

        .slider {
            position: absolute;
            cursor: pointer;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: #374151;
            transition: .4s;
            border-radius: 34px;
        }

        .slider:before {
            position: absolute;
            content: "";
            height: 26px;
            width: 26px;
            left: 4px;
            bottom: 4px;
            background-color: white;
            transition: .4s;
            border-radius: 50%;
        }

        input:checked + .slider {
            background-color: #00d4ff;
        }

        input:checked + .slider:before {
            transform: translateX(26px);
        }

        /* Alert Messages */
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

        .status-text {
            font-weight: 600;
            color: #e4e9f0;
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
            <a href="${pageContext.request.contextPath}/admin/seat-types">💺 Quản lý loại ghế</a>
            <a href="${pageContext.request.contextPath}/views/admin/paymentManager.jsp">💳 Quản lý thanh toán</a>
        </nav>
        <a href="${pageContext.request.contextPath}/logout" class="logout">🚪 Đăng xuất</a>
    </div>

    <!-- Header -->
    <header>
        <h1>
            <c:choose>
                <c:when test="${not empty staff && viewMode}">👁️ Thông tin nhân viên</c:when>
                <c:when test="${not empty staff}">✏️ Chỉnh sửa nhân viên</c:when>
                <c:otherwise>➕ Thêm nhân viên mới</c:otherwise>
            </c:choose>
        </h1>
        <div class="header-right">
            <span>👤 Admin: Nguyễn Văn A</span>
            <span>⏰ <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %></span>
        </div>
    </header>

    <!-- Main content -->
    <div class="content">
        
        <!-- Success/Error Messages -->
        <c:if test="${not empty error}">
            <div class="alert alert-error">
                ❌ ${error}
            </div>
        </c:if>

        <div class="form-container">
            <form method="post" 
                  action="${pageContext.request.contextPath}/admin/staff?action=${not empty staff ? 'update' : 'create'}">
                
                <c:if test="${not empty staff}">
                    <input type="hidden" name="id" value="${staff.id}">
                </c:if>
                
                <div class="form-group">
                    <label for="email">📧 Email</label>
                    <input type="email" id="email" name="email" 
                           value="${staff.email}" 
                           <c:if test="${viewMode}">readonly</c:if>
                           required>
                </div>
                
                <div class="form-group">
                    <label for="phoneNumber">📞 Số điện thoại</label>
                    <input type="tel" id="phoneNumber" name="phoneNumber" 
                           value="${staff.phoneNumber}"
                           <c:if test="${viewMode}">readonly</c:if>>
                </div>
                
                <div class="form-group">
                    <label for="username">👤 Tên đăng nhập</label>
                    <input type="text" id="username" name="username" 
                           value="${staff.username}"
                           <c:if test="${viewMode}">readonly</c:if>
                           required>
                </div>
                
                <div class="form-group">
                    <label for="role">💼 Vị trí</label>
                    <select id="role" name="role" <c:if test="${viewMode}">disabled</c:if>>
                        <option value="staff" <c:if test="${staff.role == 'staff'}">selected</c:if>>Nhân viên</option>
                        <option value="manager" <c:if test="${staff.role == 'manager'}">selected</c:if>>Quản lý rạp</option>
                        <option value="support" <c:if test="${staff.role == 'support'}">selected</c:if>>Hỗ trợ KH</option>
                    </select>
                    <c:if test="${viewMode}">
                        <input type="hidden" name="role" value="${staff.role}">
                    </c:if>
                </div>
                
                <div class="form-group">
                    <label>📊 Trạng thái</label>
                    <div style="display: flex; align-items: center; gap: 15px; margin-top: 10px;">
                        <label class="switch">
                            <input type="checkbox" name="status" 
                                   <c:if test="${staff.status}">checked</c:if>
                                   <c:if test="${viewMode}">disabled</c:if>>
                            <span class="slider"></span>
                        </label>
                        <span class="status-text">
                            <c:choose>
                                <c:when test="${staff.status}">Đang hoạt động</c:when>
                                <c:otherwise>Ngừng hoạt động</c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                </div>
                
                <c:if test="${not viewMode}">
                    <div class="form-actions">
                        <button type="submit" class="btn">
                            <c:choose>
                                <c:when test="${not empty staff}">💾 Cập nhật</c:when>
                                <c:otherwise>➕ Thêm mới</c:otherwise>
                            </c:choose>
                        </button>
                        <a href="${pageContext.request.contextPath}/admin/staff" class="btn btn-cancel">↩️ Quay lại</a>
                    </div>
                </c:if>
                
                <c:if test="${viewMode}">
                    <div class="form-actions">
                        <a href="${pageContext.request.contextPath}/admin/staff?action=edit&id=${staff.id}" class="btn">✏️ Chỉnh sửa</a>
                        <a href="${pageContext.request.contextPath}/admin/staff" class="btn btn-cancel">↩️ Quay lại</a>
                    </div>
                </c:if>
            </form>
        </div>
    </div>

    <!-- Footer -->
    <footer>
        <p>© 2024 Cinema Booking System. All rights reserved.</p>
    </footer>

</body>
</html>