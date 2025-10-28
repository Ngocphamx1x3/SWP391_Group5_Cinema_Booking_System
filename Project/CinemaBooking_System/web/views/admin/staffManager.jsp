<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %> <%-- Added for date formatting --%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %> <%-- Added for string manipulation --%>

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
                background: #f4f7fa; /* Light background */
                color: #2d3748; /* Dark text */
                min-height: 100vh;
            }

            /* ===== Sidebar (Light Theme) ===== */
            .sidebar {
                position: fixed;
                top: 0;
                left: 0;
                width: 280px;
                height: 100vh;
                background: #ffffff; /* White background */
                border-right: 1px solid #e2e8f0; /* Light gray border */
                display: flex;
                flex-direction: column;
                padding: 30px 0;
                box-shadow: 2px 0 15px rgba(0, 0, 0, 0.05); /* Subtle shadow */
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
                color: #1a202c; /* Dark text for logo */
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
                color: #4a5568; /* Dark gray text for links */
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
                background: #e6f7ff; /* Light blue background */
                color: #007bff; /* Darker blue text */
                padding-left: 35px;
            }

            .sidebar a:hover::before {
                transform: scaleY(1);
            }

            .sidebar a.active {
                background: #e6f7ff; /* Light blue background */
                color: #007bff; /* Darker blue text */
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
                justify-content: center; /* Ensures content is centered */
            }

            .sidebar a.logout:hover {
                background: rgba(239, 68, 68, 0.2);
                padding-left: 30px; /* Reset padding for consistent centering */
            }

            /* ===== Header (Light Theme) ===== */
            header {
                margin-left: 280px;
                background: rgba(255, 255, 255, 0.8); /* Light transparent background */
                backdrop-filter: blur(10px);
                border-bottom: 1px solid #e2e8f0; /* Light gray border */
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
                color: #1a202c; /* Dark heading */
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
                color: #4a5568; /* Dark gray text */
                font-size: 14px;
                display: flex;
                align-items: center;
                gap: 8px;
            }

            /* ===== Content (Light Theme) ===== */
            .content {
                margin-left: 280px;
                padding: 40px;
            }

            /* ===== Stats Cards (Light Theme) ===== */
            .stats-container {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
                gap: 25px;
                margin-bottom: 40px;
            }

            .stat-box {
                background: #ffffff; /* White background */
                border: 1px solid #e2e8f0; /* Light gray border */
                border-radius: 20px;
                padding: 25px;
                position: relative;
                overflow: hidden;
                transition: all 0.3s ease;
                 box-shadow: 0 4px 10px rgba(0, 0, 0, 0.03);
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
                border-color: #007bff; /* Blue border on hover */
                box-shadow: 0 10px 20px rgba(0, 0, 0, 0.08); /* Slightly stronger shadow */
            }

            .stat-box:hover::before {
                transform: scaleX(1);
            }

            .stat-box h3 {
                color: #6b7280; /* Medium gray heading */
                font-size: 13px;
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: 1px;
                margin-bottom: 12px;
            }

            .stat-box .stat-value {
                font-size: 32px;
                font-weight: 700;
                color: #1a202c; /* Dark value text */
                 background: none;
                 -webkit-background-clip: unset;
                 -webkit-text-fill-color: unset;
            }

            /* ===== Toolbar (Light Theme) ===== */
            .toolbar {
                background: #ffffff; /* White background */
                border: 1px solid #e2e8f0; /* Light gray border */
                border-radius: 20px;
                padding: 25px 30px;
                margin-bottom: 30px;
                display: flex;
                justify-content: space-between;
                align-items: center;
                flex-wrap: wrap;
                gap: 20px;
                box-shadow: 0 10px 20px rgba(0, 0, 0, 0.05);
            }

            .search-box {
                display: flex;
                gap: 15px;
                flex: 1;
                min-width: 300px;
                align-items: center; /* Align items vertically */
            }

            .search-box input,
            .search-box select {
                background: #ffffff; /* White input background */
                border: 1px solid #ced4da; /* Gray border */
                border-radius: 12px;
                padding: 12px 20px;
                color: #2d3748; /* Dark text */
                font-size: 14px;
                outline: none;
                transition: all 0.3s ease;
                height: 44px; /* Consistent height */
            }
             .search-box input { flex: 1; } /* Allow input to grow */
             .search-box select option {
                 color: #333;
                 background-color: #fff;
             }

            .search-box input:focus,
            .search-box select:focus {
                border-color: #007bff; /* Blue border on focus */
                box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.25); /* Focus ring */
            }

            .search-box input::placeholder {
                color: #6b7280;
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
                display: inline-flex; /* Use inline-flex */
                align-items: center;
                gap: 8px;
                text-decoration: none;
                height: 44px; /* Match input height */
            }

            .btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 25px rgba(0, 123, 255, 0.3); /* Blue shadow */
            }

            /* ===== Table Container (Light Theme) ===== */
            .table-container {
                background: #ffffff; /* White background */
                border: 1px solid #e2e8f0; /* Light gray border */
                border-radius: 20px;
                padding: 30px;
                overflow-x: auto;
                box-shadow: 0 10px 20px rgba(0, 0, 0, 0.05);
            }

            table {
                width: 100%;
                border-collapse: collapse;
            }

            th {
                background: #f8f9fa; /* Lighter gray background */
                color: #4a5568; /* Dark gray text */
                font-weight: 600;
                text-transform: uppercase;
                font-size: 12px;
                letter-spacing: 1px;
                padding: 15px;
                text-align: left;
                border-bottom: 2px solid #dee2e6; /* Slightly darker border */
            }

            td {
                padding: 18px 15px;
                border-bottom: 1px solid #e2e8f0; /* Light gray border */
                color: #2d3748; /* Dark text */
                font-size: 14px;
                vertical-align: middle;
            }

            tr:hover td {
                background: #f8f9fa; /* Lighter hover */
                color: #1a202c; /* Darker text on hover */
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

            .role-badge, .status-badge {
                padding: 6px 14px;
                border-radius: 20px;
                font-size: 12px;
                font-weight: 600;
                display: inline-block;
                border: 1px solid transparent; /* Base border */
            }

            /* Role colors adapted for light theme if needed */
            .role-admin { background: rgba(239, 68, 68, 0.1); color: #dc3545; border-color: rgba(239, 68, 68, 0.3); }
            .role-manager { background: rgba(251, 146, 60, 0.1); color: #fd7e14; border-color: rgba(251, 146, 60, 0.3); }
            .role-staff { background: rgba(16, 185, 129, 0.1); color: #10b981; border-color: rgba(16, 185, 129, 0.3); }
            .role-support { background: rgba(59, 130, 246, 0.1); color: #0d6efd; border-color: rgba(59, 130, 246, 0.3); }

            /* Status colors */
            .status-active { background: rgba(16, 185, 129, 0.1); color: #10b981; border-color: rgba(16, 185, 129, 0.3); }
            .status-inactive { background: rgba(239, 68, 68, 0.1); color: #dc3545; border-color: rgba(239, 68, 68, 0.3); }


            .action-buttons {
                display: flex;
                gap: 8px;
                flex-wrap: wrap;
            }

            .btn-small {
                padding: 8px 12px;
                font-size: 11px;
                border-radius: 8px;
                border: 1px solid; /* Use border for consistency */
                cursor: pointer;
                transition: all 0.3s ease;
                font-weight: 600;
                text-decoration: none;
                display: inline-flex;
                align-items: center;
                gap: 4px;
                text-align: center;
                 background: transparent; /* Default transparent */
            }

            .btn-view { border-color: rgba(139, 92, 246, 0.3); color: #8b5cf6; background: rgba(139, 92, 246, 0.1);}
            .btn-view:hover { background: rgba(139, 92, 246, 0.2); transform: translateY(-2px); }

            .btn-edit { border-color: rgba(0, 123, 255, 0.3); color: #007bff; background: rgba(0, 123, 255, 0.1);}
            .btn-edit:hover { background: rgba(0, 123, 255, 0.2); transform: translateY(-2px); }

            .btn-delete { border-color: rgba(239, 68, 68, 0.3); color: #ef4444; background: rgba(239, 68, 68, 0.1); }
            .btn-delete:hover { background: rgba(239, 68, 68, 0.2); transform: translateY(-2px); }

             .btn-warning { border-color: rgba(251, 146, 60, 0.3); color: #fb923c; background: rgba(251, 146, 60, 0.1); }
            .btn-warning:hover { background: rgba(251, 146, 60, 0.2); transform: translateY(-2px); }

            .btn-success { border-color: rgba(16, 185, 129, 0.3); color: #10b981; background: rgba(16, 185, 129, 0.1); }
            .btn-success:hover { background: rgba(16, 185, 129, 0.2); transform: translateY(-2px); }

            .btn-primary { border-color: rgba(59, 130, 246, 0.3); color: #3b82f6; background: rgba(59, 130, 246, 0.1); }
            .btn-primary:hover { background: rgba(59, 130, 246, 0.2); transform: translateY(-2px); }


            /* ===== Success/Error Messages (Light Theme) ===== */
            .alert {
                padding: 15px 20px;
                border-radius: 12px;
                margin-bottom: 20px;
                font-weight: 500;
                border: 1px solid;
            }

            .alert-success { background: rgba(16, 185, 129, 0.1); color: #0f5132; border-color: rgba(16, 185, 129, 0.3); }
            .alert-error { background: rgba(239, 68, 68, 0.1); color: #842029; border-color: rgba(239, 68, 68, 0.3); }

            /* ===== Pagination (Light Theme) ===== */
            .pagination {
                display: flex;
                justify-content: center;
                align-items: center;
                gap: 10px;
                margin-top: 30px;
            }

            .pagination button, .pagination a { /* Style both buttons and potential links */
                background: #ffffff;
                border: 1px solid #dee2e6;
                color: #007bff;
                padding: 10px 16px;
                border-radius: 10px;
                cursor: pointer;
                font-weight: 600;
                transition: all 0.3s ease;
                text-decoration: none; /* For links */
            }

            .pagination button:hover, .pagination a:hover {
                background: #e6f7ff;
                border-color: #007bff;
                transform: translateY(-2px);
            }

            .pagination button.active, .pagination a.active {
                background: linear-gradient(135deg, #00d4ff 0%, #0099ff 100%);
                color: white;
                border-color: transparent;
            }
             .pagination button:disabled, .pagination a.disabled {
                 background-color: #e9ecef;
                 color: #6c757d;
                 border-color: #dee2e6;
                 cursor: not-allowed;
                 transform: none;
             }


            /* ===== Footer (Light Theme) ===== */
            footer {
                background: #ffffff; /* White background */
                border-top: 1px solid #e2e8f0; /* Light gray border */
                color: #6b7280;
                text-align: center;
                padding: 25px;
                margin-left: 280px; /* Keep consistent */
                margin-top: 40px;
                font-size: 14px;
            }
            .toolbar select option {
                 color: #333;
                 background-color: #fff;
            }
              /* Responsive */
             @media (max-width: 992px) { /* Adjust breakpoint if needed */
                  .sidebar { width: 100%; height: auto; position: relative; box-shadow: none; border-right: none; border-bottom: 1px solid #e2e8f0;}
                  header, .content, footer { margin-left: 0; }
             }
             @media (max-width: 768px) {
                 .stats-container { grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); }
                 .toolbar { flex-direction: column; align-items: stretch;}
                 .search-box { flex-direction: column; min-width: unset; }
                 .search-box select, .search-box button { width: 100%;}
                 th, td { padding: 12px 10px; font-size: 13px;}
                 .btn, .btn-small { padding: 10px 15px; font-size: 13px;}
                 .btn-small { padding: 6px 10px; font-size: 11px;}
                  header h1 { font-size: 24px;}
                  .content { padding: 25px;}
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
                <a href="${pageContext.request.contextPath}/admin/staff" class="active">🧑‍💼 Quản lý nhân viên</a>
                <a href="${pageContext.request.contextPath}/admin/cinemas">🏢 Quản lý rạp</a>
                <a href="${pageContext.request.contextPath}/admin/movies">🎞️ Quản lý phim</a>
                <a href="${pageContext.request.contextPath}/admin/seat-types">💺 Quản lý loại ghế</a>
                <a href="${pageContext.request.contextPath}/views/admin/paymentManager.jsp">💳 Quản lý thanh toán</a>
                <a href="${pageContext.request.contextPath}/admin/vouchers">🎫 Quản lý Voucher</a>
            </nav>
            <a href="${pageContext.request.contextPath}/logout" class="logout">🚪 Đăng xuất</a>
        </div>

        <header>
            <h1>🧑‍💼 Quản lý nhân viên</h1>
            <div class="header-right">
                <span>👤 Admin: Nguyễn Văn A</span>
                <span>⏰ <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %></span>
            </div>
        </header>

        <div class="content">

            <div class="stats-container">
                <div class="stat-box">
                    <h3>👥 Tổng nhân viên</h3>
                    <div class="stat-value">${fn:length(staffList)}</div> <%-- Use fn:length for list size --%>
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
                            <c:if test="${staff.hasCinemaAssignment()}"> <%-- Keep using method call --%>
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
                         <c:set var="currentMonth" value="<%= java.time.LocalDate.now().getMonthValue() %>" />
                         <c:set var="currentYear" value="<%= java.time.LocalDate.now().getYear() %>" />
                         <c:forEach var="staff" items="${staffList}">
                              <c:if test="${staff.createdAt != null}">
                                  <fmt:formatDate value="${staff.createdAt}" pattern="yyyy-MM" var="createdYearMonth" />
                                  <c:set var="createdYear" value="${fn:substring(createdYearMonth, 0, 4)}" />
                                  <c:set var="createdMonth" value="${fn:substring(createdYearMonth, 5, 7)}" />
                                   <%-- Convert createdMonth string to integer for comparison --%>
                                   <c:set var="createdMonthInt">
                                       <fmt:parseNumber integerOnly="true" type="number" value="${createdMonth}" />
                                   </c:set>

                                   <c:if test="${createdYear == currentYear && createdMonthInt == currentMonth}">
                                       <c:set var="newThisMonth" value="${newThisMonth + 1}" />
                                   </c:if>
                               </c:if>
                         </c:forEach>
                         ${newThisMonth}
                    </div>
                </div>
            </div>

            <c:if test="${not empty param.success}">
                <div class="alert alert-success">
                    <c:choose>
                        <c:when test="${param.success == 'create'}">✅ Thêm nhân viên thành công!</c:when>
                        <c:when test="${param.success == 'update'}">✅ Cập nhật nhân viên thành công!</c:when>
                        <c:when test="${param.success == 'delete'}">✅ Xóa nhân viên thành công!</c:when>
                        <c:when test="${param.success == 'status'}">✅ Cập nhật trạng thái thành công!</c:when>
                        <c:when test="${param.success == 'assign'}">✅ Phân công rạp thành công!</c:when>
                        <c:when test="${param.success == 'update-assignment'}">✅ Cập nhật phân công thành công!</c:when>
                         <c:otherwise>✅ Thao tác thành công!</c:otherwise> <%-- Generic success --%>
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
                        <c:otherwise>❌ Có lỗi xảy ra: ${param.error}</c:otherwise> <%-- Display specific error if provided --%>
                    </c:choose>
                </div>
            </c:if>


            <div class="toolbar">
                <form method="get" action="${pageContext.request.contextPath}/admin/staff" class="search-box">
                    <input type="text" name="search" placeholder="🔍 Tìm kiếm theo tên, email..."
                           value="${param.search}">
                    <select name="roleFilter">
                        <option value="">Tất cả vị trí</option>
                        <%-- Assuming roles are 'admin', 'manager', 'staff', 'support' --%>
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
                    <a href="${pageContext.request.contextPath}/admin/staff" class="btn btn-secondary">🔄 Reset</a>
                </form>
                <a href="${pageContext.request.contextPath}/admin/staff?action=add" class="btn">➕ Thêm nhân viên</a>
            </div>

            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Nhân viên</th>
                            <th>Email</th>
                            <th>SĐT</th>
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
                                            ${fn:toUpperCase(fn:substring(staff.username, 0, 1))}
                                        </div>
                                        <strong>${staff.username}</strong>
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
                                             <c:when test="${staff.role == 'admin'}">Quản trị</c:when>
                                             <c:when test="${staff.role == 'manager'}">QL Rạp</c:when>
                                             <c:when test="${staff.role == 'staff'}">Nhân viên</c:when>
                                             <c:otherwise>Hỗ trợ</c:otherwise>
                                         </c:choose>
                                    </span>
                                </td>
                                <td>${staff.cinemaInfo}</td> <%-- Assuming cinemaInfo is pre-formatted --%>
                                <td><fmt:formatDate value="${staff.createdAt}" pattern="dd/MM/yy HH:mm"/></td>
                                <td>
                                    <span class="status-badge ${staff.status ? 'status-active' : 'status-inactive'}">
                                        ${staff.status ? 'Hoạt động' : 'Ngừng'}
                                    </span>
                                </td>
                                <td>
                                    <div class="action-buttons">
                                        <a href="${pageContext.request.contextPath}/admin/staff?action=view&id=${staff.id}"
                                           class="btn-small btn-view" title="Xem chi tiết">👁️</a>

                                        <a href="${pageContext.request.contextPath}/admin/staff?action=edit&id=${staff.id}"
                                           class="btn-small btn-edit" title="Chỉnh sửa">✏️</a>

                                        <c:choose>
                                            <c:when test="${staff.status}">
                                                <a href="${pageContext.request.contextPath}/admin/staff?action=toggle-status&id=${staff.id}&status=false"
                                                   class="btn-small btn-warning" title="Vô hiệu hóa"
                                                   onclick="return confirm('Vô hiệu hóa nhân viên ${fn:escapeXml(staff.username)}?')">🚫</a>
                                            </c:when>
                                            <c:otherwise>
                                                <a href="${pageContext.request.contextPath}/admin/staff?action=toggle-status&id=${staff.id}&status=true"
                                                   class="btn-small btn-success" title="Kích hoạt"
                                                    onclick="return confirm('Kích hoạt lại nhân viên ${fn:escapeXml(staff.username)}?')">✅</a>
                                            </c:otherwise>
                                        </c:choose>

                                        <a href="${pageContext.request.contextPath}/admin/staff?action=delete&id=${staff.id}"
                                           class="btn-small btn-delete" title="Xóa"
                                           onclick="return confirm('Bạn có chắc muốn xóa nhân viên ${fn:escapeXml(staff.username)}? Hành động này không thể hoàn tác.')">🗑️</a>

                                        <%-- Replaced with link on cinema info or dedicated management page --%>
                                        <%--
                                        <a href="${pageContext.request.contextPath}/admin/staff?action=assign-cinema&staffId=${staff.id}"
                                           class="btn-small btn-primary" title="Phân công">🏢</a>
                                        --%>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>

                <c:if test="${empty staffList}">
                    <div style="text-align: center; padding: 40px; color: #6b7280;">
                        <p>📭 Không có nhân viên nào được tìm thấy khớp với tiêu chí tìm kiếm.</p>
                    </div>
                </c:if>
            </div>

            <%--
            <div class="pagination">
                 <button disabled>&laquo; Trước</button>
                 <button class="active">1</button>
                 <button>2</button>
                 <button>Sau &raquo;</button>
            </div>
            --%>
        </div>

        <footer>
            <p>© 2025 Cinema Booking System - Admin Panel | Powered by Modern Technology</p>
        </footer>

    </body>
</html>