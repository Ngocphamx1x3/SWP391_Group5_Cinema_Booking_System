<%-- views/admin/voucherManager.jsp --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Quản lý Voucher | Cinema Booking</title>
        <!-- Sử dụng cùng CSS với voucherForm.jsp -->
        <style>
            /* Copy toàn bộ CSS từ voucherForm.jsp vào đây */
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
                letter-spacing: 1px;
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

            .sidebar a:hover {
                background: #e6f7ff;
                color: #007bff;
                padding-left: 35px;
            }

            .sidebar a.active {
                background: #e6f7ff;
                color: #007bff;
                padding-left: 35px;
            }

            .sidebar a.logout {
                margin-top: auto;
                background: rgba(239, 68, 68, 0.1);
                color: #ef4444;
                margin: 20px 20px 0;
                border-radius: 12px;
                justify-content: center;
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
            }

            header h1 {
                font-size: 28px;
                font-weight: 700;
                color: #1a202c;
            }

            .header-right {
                display: flex;
                align-items: center;
                gap: 20px;
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
            }

            .alert {
                padding: 12px 16px;
                border-radius: 8px;
                margin-bottom: 20px;
            }

            .alert-success {
                background: #d1fae5;
                color: #065f46;
                border: 1px solid #a7f3d0;
            }

            .btn {
                padding: 12px 24px;
                border: none;
                border-radius: 8px;
                font-weight: 500;
                cursor: pointer;
                transition: all 0.3s;
                text-decoration: none;
                display: inline-block;
                text-align: center;
            }

            .btn-primary {
                background: #007bff;
                color: white;
            }

            .btn-primary:hover {
                background: #0056b3;
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
                <a href="${pageContext.request.contextPath}/admin/movies">🎞️ Quản lý phim</a>
                <a href="${pageContext.request.contextPath}/admin/seat-types">💺 Quản lý loại ghế</a>
                <a href="${pageContext.request.contextPath}/admin/vouchers" class="active">🎫 Quản lý Voucher</a>
                <a href="${pageContext.request.contextPath}/views/admin/paymentManager.jsp">💳 Quản lý thanh toán</a>
            </nav>
            <a href="${pageContext.request.contextPath}/logout" class="logout">🚪 Đăng xuất</a>
        </div>

        <header>
            <h1>Quản lý Voucher</h1>
            <%-- Trong cả voucherForm.jsp và voucherManager.jsp --%>
            <div class="header-right">
                <span>👤 Admin: 
                    <c:choose>
                        <%-- Ưu tiên username, nếu không có thì dùng email --%>
                        <c:when test="${not empty sessionScope.account.username}">
                            ${sessionScope.account.username}
                        </c:when>
                        <c:when test="${not empty sessionScope.account.email}">
                            ${sessionScope.account.email}
                        </c:when>
                        <c:otherwise>
                            Admin User
                        </c:otherwise>
                    </c:choose>
                </span>
                <span>⏰ 
                    <jsp:useBean id="now" class="java.util.Date" />
                    <fmt:formatDate value="${now}" pattern="dd/MM/yyyy HH:mm" />
                </span>
            </div>
        </header>

        <div class="content">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px;">
                <h1 style="margin: 0;">🎫 Quản lý Voucher</h1>
                <a href="${pageContext.request.contextPath}/admin/vouchers/create" class="btn btn-primary">
                    ➕ Tạo Voucher Mới
                </a>
            </div>

            <c:if test="${not empty success}">
                <div class="alert alert-success">${success}</div>
            </c:if>

            <div class="table-container">
                <table>
                    <%-- Trong voucherManager.jsp, cập nhật phần thead và tbody --%>
                    <thead>
                        <tr>
                            <th>Mã Voucher</th>
                            <th>Tên</th>
                            <th>Loại</th>
                            <th>Giá trị</th>
                            <th>Số lượng</th>
                            <th>Ngày bắt đầu</th>
                            <th>Ngày kết thúc</th>
                            <th>Trạng thái</th>
                            <th>Thao tác</th> <%-- Thêm cột mới --%>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="voucher" items="${vouchers}">
                            <tr>
                                <td><strong>${voucher.code}</strong></td>
                                <td>${voucher.name}</td>
                                <td>${voucher.discountType == 1 ? 'Phần trăm' : 'Số tiền'}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${voucher.discountType == 1}">
                                            ${voucher.discountValue}%
                                        </c:when>
                                        <c:otherwise>
                                            <fmt:formatNumber value="${voucher.discountValue}" pattern="#,###"/>₫
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${voucher.quantity - voucher.usedQuantity}/${voucher.quantity}</td>
                                <td><fmt:formatDate value="${voucher.startDate}" pattern="dd/MM/yyyy HH:mm"/></td>
                                <td><fmt:formatDate value="${voucher.endDate}" pattern="dd/MM/yyyy HH:mm"/></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${voucher.isActive}">
                                            <span style="color: #10b981;">● Đang hoạt động</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="color: #ef4444;">● Ngừng hoạt động</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <div style="display: flex; gap: 8px;">
                                        <a href="${pageContext.request.contextPath}/admin/vouchers/detail/${voucher.id}" 
                                           style="background: #17a2b8; color: white; padding: 6px 12px; border-radius: 4px; text-decoration: none; font-size: 12px;">
                                            👁️
                                        </a>
                                        <a href="${pageContext.request.contextPath}/admin/vouchers/edit/${voucher.id}" 
                                           style="background: #007bff; color: white; padding: 6px 12px; border-radius: 4px; text-decoration: none; font-size: 12px;">
                                            ✏️
                                        </a>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty vouchers}">
                            <tr>
                                <td colspan="9" style="text-align: center; padding: 40px;"> <%-- Cập nhật colspan thành 9 --%>
                                    Chưa có voucher nào. <a href="${pageContext.request.contextPath}/admin/vouchers/create">Tạo voucher đầu tiên</a>
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </body>
</html>