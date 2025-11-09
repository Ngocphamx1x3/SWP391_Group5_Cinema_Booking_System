<%-- 
    Document   : bookingManager
    Created on : Nov 6, 2025, 6:49:44 PM
    Author     : admin
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Quản lý Đặt Vé | Cinema Booking</title>
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

            /* ===== Toolbar ===== */
            .toolbar {
                background: #ffffff;
                border: 1px solid #e2e8f0;
                border-radius: 20px;
                padding: 25px 30px;
                margin-bottom: 30px;
                box-shadow: 0 10px 20px rgba(0, 0, 0, 0.05);
            }

            .toolbar form {
                width: 100%;
            }

            .search-filter-container {
                display: flex;
                align-items: flex-end;
                gap: 20px;
                flex-wrap: wrap;
                width: 100%;
            }

            .search-box {
                display: flex;
                flex: 1;
                min-width: 300px;
                align-items: flex-end;
            }

            .search-box input {
                flex: 1;
                background: #ffffff;
                border: 1px solid #ced4da;
                border-radius: 12px;
                padding: 12px 20px;
                color: #2d3748;
                font-size: 14px;
                outline: none;
                transition: all 0.3s ease;
                min-height: 44px;
            }

            .search-box input:focus {
                border-color: #007bff;
                box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.25);
            }

            .search-box input::placeholder {
                color: #6b7280;
            }

            .filter-section {
                display: flex;
                gap: 15px;
                align-items: flex-end;
                flex-wrap: wrap;
                flex: 2;
            }

            .filter-group {
                display: flex;
                flex-direction: column;
                gap: 5px;
                min-width: 150px;
            }

            .filter-group label {
                font-size: 12px;
                color: #6b7280;
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: 1px;
                white-space: nowrap;
            }

            .filter-group select,
            .filter-group input {
                background: #ffffff;
                border: 1px solid #ced4da;
                border-radius: 8px;
                padding: 10px 12px;
                color: #2d3748;
                font-size: 14px;
                outline: none;
                min-width: 150px;
                min-height: 44px;
            }

            .button-group {
                display: flex;
                gap: 10px;
                align-items: flex-end;
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
                min-height: 44px;
                white-space: nowrap;
            }

            .btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 25px rgba(0, 123, 255, 0.3);
            }

            .btn-secondary {
                background: #6c757d;
                color: #ffffff;
                border: 1px solid #6c757d;
            }

            .btn-secondary:hover {
                background: #5a6268;
                transform: translateY(-2px);
            }

            /* ===== Table Container ===== */
            .table-container {
                background: #ffffff;
                border: 1px solid #e2e8f0;
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

            .status-pending {
                background: rgba(255, 193, 7, 0.2);
                color: #ffc107;
                border: 1px solid rgba(255, 193, 7, 0.3);
            }

            .status-inactive {
                background: rgba(239, 68, 68, 0.2);
                color: #ef4444;
                border: 1px solid rgba(239, 68, 68, 0.3);
            }

            .status-completed {
                background: rgba(59, 130, 246, 0.2);
                color: #3b82f6;
                border: 1px solid rgba(59, 130, 246, 0.3);
            }

            .time-badge {
                background: rgba(59, 130, 246, 0.2);
                color: #3b82f6;
                padding: 4px 10px;
                border-radius: 8px;
                font-size: 11px;
                font-weight: 600;
                display: inline-block;
                margin: 2px 0;
            }

            .action-buttons {
                display: flex;
                gap: 8px;
                flex-wrap: wrap;
            }

            .btn-small {
                padding: 8px 16px;
                font-size: 12px;
                border-radius: 8px;
                border: none;
                cursor: pointer;
                transition: all 0.3s ease;
                font-weight: 600;
                text-decoration: none;
                display: inline-block;
            }

            .btn-edit {
                background: rgba(0, 123, 255, 0.2);
                color: #007bff;
                border: 1px solid rgba(0, 123, 255, 0.3);
            }

            .btn-edit:hover {
                background: rgba(0, 123, 255, 0.3);
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

            /* ===== Phân trang ===== */
            .pagination {
                background: #ffffff;
                border: 1px solid #e2e8f0;
                border-radius: 12px;
                padding: 20px;
                margin-top: 20px;
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
                display: flex;
                justify-content: space-between;
                align-items: center;
                flex-wrap: wrap;
                gap: 15px;
            }

            .pagination-info {
                color: #6b7280;
                font-size: 14px;
                font-weight: 500;
            }

            .pagination-controls {
                display: flex;
                gap: 8px;
                align-items: center;
                flex-wrap: wrap;
            }

            .page-numbers {
                display: flex;
                gap: 5px;
            }

            .page-size-selector {
                display: flex;
                align-items: center;
                gap: 8px;
            }

            .page-size-selector select {
                padding: 6px 10px;
                border-radius: 6px;
                border: 1px solid #ced4da;
                font-size: 14px;
                outline: none;
            }

            .btn-disabled {
                background: #f8f9fa !important;
                color: #6c757d !important;
                border-color: #dee2e6 !important;
                cursor: not-allowed !important;
                opacity: 0.6;
            }

            .pagination-controls .btn-small {
                min-width: 40px;
                text-align: center;
                padding: 6px 10px;
            }

            /* ===== Footer ===== */
            footer {
                background: #ffffff;
                border-top: 1px solid #e2e8f0;
                color: #6b7280;
                text-align: center;
                padding: 25px;
                margin-left: 280px;
                margin-top: 40px;
                font-size: 14px;
            }

            /* ===== Responsive ===== */
            @media (max-width: 1024px) {
                .search-filter-container {
                    flex-direction: column;
                    align-items: stretch;
                }

                .search-box {
                    min-width: 100%;
                }

                .filter-section {
                    flex: 1;
                }
            }

            @media (max-width: 768px) {
                .sidebar {
                    width: 100%;
                    height: auto;
                    position: relative;
                }

                header, .content, footer {
                    margin-left: 0;
                }

                .content {
                    padding: 20px;
                }

                .search-filter-container {
                    gap: 15px;
                }

                .filter-section {
                    flex-direction: column;
                    align-items: stretch;
                    gap: 15px;
                }

                .filter-group {
                    min-width: 100%;
                }

                .button-group {
                    width: 100%;
                    justify-content: stretch;
                }

                .button-group .btn {
                    flex: 1;
                    justify-content: center;
                }

                .action-buttons {
                    flex-direction: column;
                }

                .pagination {
                    flex-direction: column;
                    text-align: center;
                    gap: 15px;
                }

                .pagination-controls {
                    justify-content: center;
                }

                .page-size-selector {
                    justify-content: center;
                }
            }

            @media (max-width: 480px) {
                header {
                    padding: 15px 20px;
                    flex-direction: column;
                    gap: 15px;
                    align-items: flex-start;
                }

                .header-right {
                    gap: 15px;
                    flex-wrap: wrap;
                }

                .toolbar {
                    padding: 20px;
                }

                .table-container {
                    padding: 15px;
                }

                th, td {
                    padding: 10px 8px;
                    font-size: 12px;
                }
            }
        </style>
    </head>
    <body>

        <div class="sidebar">
            <div class="sidebar-logo">
                <h2>🎬 CINEMA PRO</h2>
                <p>Staff Panel</p>
            </div>
            <nav>
                <a href="${pageContext.request.contextPath}/staffdashboard">📊 Bảng điều khiển</a>
                <a href="${pageContext.request.contextPath}/staff/rooms">🏢 Quản lý phòng chiếu</a>
                <a href="${pageContext.request.contextPath}/staff/seat-design">💺 Thiết kế ghế trong phòng</a>
                <a href="${pageContext.request.contextPath}/staff/schedules">🎭 Quản lý lịch chiếu</a>
                <a href="${pageContext.request.contextPath}/staff/bookings" class="active">🎫 Quản lý đặt vé</a>
                <a href="${pageContext.request.contextPath}/staff/reports">📈 Báo cáo doanh thu</a>
            </nav>
            <a href="${pageContext.request.contextPath}/logout" class="logout">🚪 Đăng xuất</a>
        </div>

        <header>
            <h1>🎫 Quản lý Đặt Vé</h1>
            <div class="header-right">
                <c:if test="${not empty staffUser}">
                    <span>👤 ${staffUser.username} (${staffUser.role})</span>
                </c:if>
                <span>⏰ <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %></span>
            </div>
        </header>

        <div class="content">

            <div class="toolbar">
                <form method="GET" action="${pageContext.request.contextPath}/staff/bookings">
                    <div class="search-filter-container">
                        <!-- Phần tìm kiếm -->
                        <div class="search-box">
                            <input type="text" name="search" placeholder="🔍 Tìm kiếm theo mã vé, tên khách hàng, email, phim..." 
                                   value="${param.search}">
                        </div>

                        <!-- Phần filter -->
                        <div class="filter-section">
                            <div class="filter-group">
                                <label>Trạng thái</label>
                                <select name="status">
                                    <option value="ALL" ${param.status == 'ALL' or empty param.status ? 'selected' : ''}>ALL status</option>
                                    <option value="PENDING" ${param.status == 'PENDING' ? 'selected' : ''}>PENDING</option>
                                    <option value="PAID" ${param.status == 'PAID' ? 'selected' : ''}>PAID</option>
                                </select>
                            </div>

                            <div class="filter-group">
                                <label>Ngày đặt</label>
                                <input type="date" name="date" value="${param.date}">
                            </div>

                            <!-- Nút hành động -->
                            <div class="button-group">
                                <button type="submit" class="btn">🔍 Tìm kiếm</button>
                                <a href="${pageContext.request.contextPath}/staff/bookings" class="btn btn-secondary">🔄 Reset</a>
                            </div>
                        </div>
                    </div>
                </form>
            </div>

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
                            <th>Ngày đặt</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty bookings}">
                                <c:forEach var="booking" items="${bookings}">
                                    <tr>
                                        <td><strong>${booking.ticketCode}</strong></td>
                                        <td>
                                            <strong>${booking.customerName}</strong><br>
                                            <small style="color: #6b7280;">${booking.customerEmail}</small><br>
                                            <small style="color: #6b7280;">${booking.customerPhone}</small>
                                        </td>
                                        <td>
                                            <strong>${booking.movieName}</strong><br>
                                            <small style="color: #6b7280;">${booking.roomName} - ${booking.cinemaName}</small>
                                        </td>
                                        <td>
                                            <c:if test="${not empty booking.showtime}">
                                                <div class="time-badge">
                                                    <fmt:formatDate value="${booking.showtime}" pattern="HH:mm dd/MM/yyyy" />
                                                </div>
                                            </c:if>
                                        </td>
                                        <td>${booking.seatsFormatted}</td>
                                        <td><strong>${booking.totalAmountFormatted}</strong></td>
                                        <td>
                                            <span class="status-badge ${booking.statusBadgeClass}">
                                                ${booking.statusFormatted}
                                            </span>
                                        </td>
                                        <td>
                                            <c:if test="${not empty booking.orderDate}">
                                                <fmt:formatDate value="${booking.orderDate}" pattern="dd/MM/yyyy HH:mm" />
                                            </c:if>
                                        </td>
                                        <td>
                                            <div class="action-buttons">
                                                <button class="btn-small btn-edit" onclick="viewBookingDetails('${booking.ticketCode}')">
                                                    👁️ Chi tiết
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="9" style="text-align: center; color: #6b7280; padding: 40px;">
                                        📭 Không tìm thấy đặt vé nào.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>

                <!-- PHÂN TRANG -->
                <c:if test="${not empty bookings and totalPages > 1}">
                    <div class="pagination">

                        <!-- Thông tin trang -->
                        <div class="pagination-info">
                            Hiển thị ${(currentPage-1)*pageSize + 1} - 
                            ${currentPage * pageSize > totalRecords ? totalRecords : currentPage * pageSize} của ${totalRecords} đặt vé
                        </div>

                        <!-- Nút phân trang -->
                        <div class="pagination-controls">

                            <!-- Nút đầu trang -->
                            <a href="${pageContext.request.contextPath}/staff/bookings?page=1&pageSize=${pageSize}&search=${param.search}&status=${param.status}&date=${param.date}" 
                               class="btn-small ${currentPage == 1 ? 'btn-disabled' : 'btn-edit'}"
                               ${currentPage == 1 ? 'onclick="return false;"' : ''}>
                                ⏮️
                            </a>

                            <!-- Nút trang trước -->
                            <a href="${pageContext.request.contextPath}/staff/bookings?page=${currentPage - 1}&pageSize=${pageSize}&search=${param.search}&status=${param.status}&date=${param.date}" 
                               class="btn-small ${currentPage == 1 ? 'btn-disabled' : 'btn-edit'}"
                               ${currentPage == 1 ? 'onclick="return false;"' : ''}>
                                ◀️
                            </a>

                            <!-- Các trang -->
                            <div class="page-numbers">
                                <c:set var="startPage" value="${currentPage - 2 > 0 ? currentPage - 2 : 1}" />
                                <c:set var="endPage" value="${currentPage + 2 > totalPages ? totalPages : currentPage + 2}" />

                                <c:forEach begin="${startPage}" end="${endPage}" var="i">
                                    <a href="${pageContext.request.contextPath}/staff/bookings?page=${i}&pageSize=${pageSize}&search=${param.search}&status=${param.status}&date=${param.date}" 
                                       class="btn-small ${i == currentPage ? 'btn-primary' : 'btn-edit'}"
                                       style="${i == currentPage ? 'background: #007bff; color: white;' : ''}">
                                        ${i}
                                    </a>
                                </c:forEach>
                            </div>

                            <!-- Nút trang sau -->
                            <a href="${pageContext.request.contextPath}/staff/bookings?page=${currentPage + 1}&pageSize=${pageSize}&search=${param.search}&status=${param.status}&date=${param.date}" 
                               class="btn-small ${currentPage == totalPages ? 'btn-disabled' : 'btn-edit'}"
                               ${currentPage == totalPages ? 'onclick="return false;"' : ''}>
                                ▶️
                            </a>

                            <!-- Nút cuối trang -->
                            <a href="${pageContext.request.contextPath}/staff/bookings?page=${totalPages}&pageSize=${pageSize}&search=${param.search}&status=${param.status}&date=${param.date}" 
                               class="btn-small ${currentPage == totalPages ? 'btn-disabled' : 'btn-edit'}"
                               ${currentPage == totalPages ? 'onclick="return false;"' : ''}>
                                ⏭️
                            </a>

                        </div>

                        <!-- Chọn số item mỗi trang -->
                        <div class="page-size-selector">
                            <label style="font-size: 14px; color: #6b7280;">Hiển thị:</label>
                            <select onchange="changePageSize(this.value)" style="padding: 5px; border-radius: 5px; border: 1px solid #ced4da;">
                                <option value="5" ${pageSize == 5 ? 'selected' : ''}>5</option>
                                <option value="10" ${pageSize == 10 ? 'selected' : ''}>10</option>
                                <option value="20" ${pageSize == 20 ? 'selected' : ''}>20</option>
                                <option value="50" ${pageSize == 50 ? 'selected' : ''}>50</option>
                            </select>
                        </div>
                    </div>
                </c:if>
            </div>
        </div>

        <footer>
            © 2025 Cinema Booking System - Staff Panel | Powered by Modern Technology
        </footer>

        <script>
            function changePageSize(pageSize) {
                const url = new URL(window.location.href);
                url.searchParams.set('pageSize', pageSize);
                url.searchParams.set('page', '1');
                window.location.href = url.toString();
            }

            function viewBookingDetails(ticketCode) {
                // Mở cửa sổ mới với kích thước phù hợp
                const width = 900;
                const height = 700;
                const left = (screen.width - width) / 2;
                const top = (screen.height - height) / 2;

                window.open('${pageContext.request.contextPath}/staff/booking-details?ticketCode=' + ticketCode,
                        'bookingDetails',
                        `width=${width},height=${height},left=${left},top=${top},resizable=yes,scrollbars=yes`);
            }

            function confirmBooking(ticketCode) {
                if (confirm('Bạn có chắc chắn muốn xác nhận vé ' + ticketCode + '?')) {
                    // TODO: Implement confirm booking
                    alert('Đã xác nhận vé: ' + ticketCode);
                }
            }

            function cancelBooking(ticketCode) {
                if (confirm('Bạn có chắc chắn muốn hủy vé ' + ticketCode + '?')) {
                    // TODO: Implement cancel booking
                    alert('Đã hủy vé: ' + ticketCode);
                }
            }

            function viewBookingDetails(ticketCode) {
                // Mở modal hoặc chuyển trang xem chi tiết
                window.open('${pageContext.request.contextPath}/staff/booking-details?ticketCode=' + ticketCode,
                        '_blank', 'width=800,height=600');

                // Hoặc chuyển hướng đến trang chi tiết
                // window.location.href = '${pageContext.request.contextPath}/staff/booking-details?ticketCode=' + ticketCode;
            }
        </script>

    </body>
</html>