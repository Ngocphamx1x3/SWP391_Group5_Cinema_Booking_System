<%-- 
    Document   : voucherDetail
    Created on : Oct 28, 2025, 11:21:57 AM
    Author     : admin
--%>

<%-- views/admin/voucherDetail.jsp --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chi tiết Voucher | Cinema Booking</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
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

        .detail-container {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 20px;
            padding: 40px;
            max-width: 800px;
            margin: 0 auto;
        }

        .detail-title {
            font-size: 24px;
            font-weight: 700;
            margin-bottom: 30px;
            color: #1a202c;
            text-align: center;
        }

        .detail-section {
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid #e2e8f0;
        }

        .detail-section:last-child {
            border-bottom: none;
        }

        .detail-section h3 {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 15px;
            color: #374151;
        }

        .detail-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }

        .detail-item {
            margin-bottom: 12px;
        }

        .detail-label {
            font-weight: 500;
            color: #6b7280;
            margin-bottom: 4px;
        }

        .detail-value {
            font-weight: 600;
            color: #1a202c;
        }

        .status-active {
            color: #10b981;
            font-weight: 600;
        }

        .status-inactive {
            color: #ef4444;
            font-weight: 600;
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

        .btn-secondary {
            background: #6b7280;
            color: white;
        }

        .btn-secondary:hover {
            background: #4b5563;
        }

        .form-actions {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-top: 30px;
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
            <a href="${pageContext.request.contextPath}/views/admin/paymentManager.jsp">💳 Quản lý thanh toán</a>
            <a href="${pageContext.request.contextPath}/admin/vouchers" class="active">🎫 Quản lý Voucher</a>
        </nav>
        <a href="${pageContext.request.contextPath}/logout" class="logout">🚪 Đăng xuất</a>
    </div>

    <header>
        <h1>Chi tiết Voucher</h1>
        <div class="header-right">
            <span>👤 Admin: 
                <c:choose>
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
        <div class="detail-container">
            <h2 class="detail-title">👁️ Chi tiết Voucher: ${voucher.code}</h2>

            <div class="detail-section">
                <h3>📋 Thông tin cơ bản</h3>
                <div class="detail-grid">
                    <div class="detail-item">
                        <div class="detail-label">Mã Voucher</div>
                        <div class="detail-value">${voucher.code}</div>
                    </div>
                    <div class="detail-item">
                        <div class="detail-label">Tên Voucher</div>
                        <div class="detail-value">${voucher.name}</div>
                    </div>
                    <div class="detail-item">
                        <div class="detail-label">Trạng thái</div>
                        <div class="detail-value ${voucher.isActive ? 'status-active' : 'status-inactive'}">
                            ${voucher.isActive ? '● Đang hoạt động' : '● Ngừng hoạt động'}
                        </div>
                    </div>
                    <div class="detail-item">
                        <div class="detail-label">Ngày tạo</div>
                        <div class="detail-value"><fmt:formatDate value="${voucher.createdAt}" pattern="dd/MM/yyyy HH:mm" /></div>
                    </div>
                </div>
            </div>

            <div class="detail-section">
                <h3>💰 Thông tin giảm giá</h3>
                <div class="detail-grid">
                    <div class="detail-item">
                        <div class="detail-label">Loại giảm giá</div>
                        <div class="detail-value">${voucher.discountType == 1 ? 'Phần trăm (%)' : 'Số tiền cố định (VND)'}</div>
                    </div>
                    <div class="detail-item">
                        <div class="detail-label">Giá trị giảm giá</div>
                        <div class="detail-value">
                            <c:choose>
                                <c:when test="${voucher.discountType == 1}">
                                    ${voucher.discountValue}%
                                </c:when>
                                <c:otherwise>
                                    <fmt:formatNumber value="${voucher.discountValue}" pattern="#,###"/>₫
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="detail-item">
                        <div class="detail-label">Đơn hàng tối thiểu</div>
                        <div class="detail-value"><fmt:formatNumber value="${voucher.minOrderAmount}" pattern="#,###"/>₫</div>
                    </div>
                    <c:if test="${voucher.discountType == 1 && voucher.maxDiscountAmount > 0}">
                        <div class="detail-item">
                            <div class="detail-label">Giảm tối đa</div>
                            <div class="detail-value"><fmt:formatNumber value="${voucher.maxDiscountAmount}" pattern="#,###"/>₫</div>
                        </div>
                    </c:if>
                </div>
            </div>

            <div class="detail-section">
                <h3>📊 Thống kê sử dụng</h3>
                <div class="detail-grid">
                    <div class="detail-item">
                        <div class="detail-label">Tổng số lượng</div>
                        <div class="detail-value">${voucher.quantity}</div>
                    </div>
                    <div class="detail-item">
                        <div class="detail-label">Đã sử dụng</div>
                        <div class="detail-value">${voucher.usedQuantity}</div>
                    </div>
                    <div class="detail-item">
                        <div class="detail-label">Còn lại</div>
                        <div class="detail-value">${voucher.quantity - voucher.usedQuantity}</div>
                    </div>
                    <div class="detail-item">
                        <div class="detail-label">Tỷ lệ sử dụng</div>
                        <div class="detail-value">
                            <c:choose>
                                <c:when test="${voucher.quantity > 0}">
                                    <fmt:formatNumber value="${(voucher.usedQuantity / voucher.quantity) * 100}" maxFractionDigits="1"/>%
                                </c:when>
                                <c:otherwise>
                                    0%
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>

            <div class="detail-section">
                <h3>⏰ Thời gian hiệu lực</h3>
                <div class="detail-grid">
                    <div class="detail-item">
                        <div class="detail-label">Ngày bắt đầu</div>
                        <div class="detail-value"><fmt:formatDate value="${voucher.startDate}" pattern="dd/MM/yyyy HH:mm" /></div>
                    </div>
                    <div class="detail-item">
                        <div class="detail-label">Ngày kết thúc</div>
                        <div class="detail-value"><fmt:formatDate value="${voucher.endDate}" pattern="dd/MM/yyyy HH:mm" /></div>
                    </div>
                    <div class="detail-item">
                        <div class="detail-label">Thời gian còn lại</div>
                        <div class="detail-value">
                            <c:set var="now" value="<%= new java.util.Date() %>" />
                            <c:choose>
                                <c:when test="${voucher.endDate.time lt now.time}">
                                    <span style="color: #ef4444;">Đã hết hạn</span>
                                </c:when>
                                <c:when test="${voucher.startDate.time gt now.time}">
                                    <span style="color: #f59e0b;">Chưa bắt đầu</span>
                                </c:when>
                                <c:otherwise>
                                    <span style="color: #10b981;">Đang hoạt động</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>

            <c:if test="${not empty voucher.description}">
                <div class="detail-section">
                    <h3>📝 Mô tả</h3>
                    <div class="detail-item">
                        <div class="detail-value">${voucher.description}</div>
                    </div>
                </div>
            </c:if>
  <div class="detail-section">
    <h3>🎬 Phim áp dụng</h3>
    <div class="detail-item">
        <div class="detail-label">Danh sách phim</div>
        <div class="detail-value">
            <c:choose>
                <c:when test="${empty appliedMovies}">
                    <em>Áp dụng cho tất cả phim</em>
                </c:when>
                <c:otherwise>
                    <c:forEach var="movie" items="${appliedMovies}" varStatus="status">
                        ${movie.name}<c:if test="${not status.last}">, </c:if>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

            <div class="form-actions">
                <a href="${pageContext.request.contextPath}/admin/vouchers/edit/${voucher.id}" class="btn btn-primary">✏️ Chỉnh sửa</a>
                <a href="${pageContext.request.contextPath}/admin/vouchers" class="btn btn-secondary">← Quay lại danh sách</a>
            </div>

</body>
</html>
