<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

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
            justify-content: center;
        }

        .sidebar a.logout:hover {
            background: rgba(239, 68, 68, 0.2);
            padding-left: 30px; /* Keep consistent hover effect */
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

        .notification-badge {
            position: relative;
            cursor: pointer;
            color: #4a5568; /* Icon color */
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


        /* ===== Content (Light Theme) ===== */
        .content {
            margin-left: 280px;
            padding: 40px;
        }
        .section-title {
            font-size: 24px;
            font-weight: 700;
            margin-bottom: 25px;
            color: #1a202c; /* Dark title */
            background: none;
            -webkit-background-clip: unset;
            -webkit-text-fill-color: unset;
        }

        /* ===== Filter Bar (Light Theme) ===== */
        .filter-container {
            background: #ffffff; /* White background */
            border: 1px solid #e2e8f0; /* Light gray border */
            border-radius: 20px;
            padding: 25px;
            margin-bottom: 40px;
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
            align-items: flex-end;
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.05);
        }
        .filter-group {
            display: flex;
            flex-direction: column;
            gap: 8px;
            flex-grow: 1;
            min-width: 150px; /* Prevent shrinking too much */
        }
        .filter-group label {
            font-size: 13px;
            font-weight: 500;
            color: #4a5568; /* Dark gray label */
        }
        .filter-group input, .filter-group select {
            background: #ffffff; /* White input background */
            border: 1px solid #ced4da; /* Gray border */
            border-radius: 8px;
            padding: 10px 12px;
            color: #2d3748; /* Dark text */
            font-family: 'Inter', sans-serif;
            font-size: 14px;
            transition: border-color 0.3s, box-shadow 0.3s;
        }
         .filter-group select option { /* Style options for light theme */
            color: #333;
            background-color: #fff;
         }
        .filter-group input:focus, .filter-group select:focus {
            outline: none;
            border-color: #007bff; /* Blue border on focus */
            box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.25); /* Focus ring */
        }
        .filter-buttons {
            display: flex;
            gap: 10px; /* Add gap between buttons */
            align-items: flex-end; /* Align with input bottom */
            padding-bottom: 0; /* Align button bottom with input bottom */
            height: 40px; /* Match approximate input height */
        }
        .filter-buttons button {
            padding: 10px 20px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s ease;
            font-size: 14px;
            height: 100%; /* Make buttons fill the height */
        }
        .btn-filter {
            background: linear-gradient(135deg, #00d4ff 0%, #0099ff 100%);
            color: #ffffff; /* White text */
        }
        .btn-filter:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(0, 123, 255, 0.3);
        }
        .btn-clear {
            background: #6c757d; /* Gray background */
            color: #ffffff; /* White text */
        }
        .btn-clear:hover {
             background: #5a6268; /* Darker gray */
             transform: translateY(-2px);
        }

        /* ===== Table Section (Light Theme) ===== */
        .table-container {
            background: #ffffff; /* White background */
            border: 1px solid #e2e8f0; /* Light gray border */
            border-radius: 20px;
            padding: 0; /* Remove padding, apply to inner elements if needed */
            margin-bottom: 40px;
            overflow: hidden; /* Keep for border radius */
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
            padding: 18px 20px;
            text-align: left;
            border-bottom: 2px solid #dee2e6; /* Slightly darker border */
        }

        td {
            padding: 18px 20px;
            border-top: 1px solid #e2e8f0; /* Light gray border instead of dark */
            color: #2d3748; /* Dark text */
            font-size: 14px;
            vertical-align: middle;
        }
         tbody tr:first-child td {
             border-top: none; /* Remove top border for the first row */
         }

        tr:hover td {
            background: #f8f9fa; /* Lighter hover */
            color: #1a202c; /* Darker text on hover */
        }

        .status {
            padding: 5px 10px;
            border-radius: 12px;
            font-weight: 600;
            font-size: 12px;
            display: inline-block;
        }

        /* Status colors remain the same as they use light backgrounds */
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
            background: #ffffff; /* White background */
            border: 1px solid #ced4da; /* Gray border */
            color: #4a5568; /* Dark gray text */
            padding: 6px 12px;
            border-radius: 6px;
            cursor: pointer;
            margin-right: 8px;
            transition: all 0.3s ease;
            font-size: 13px; /* Slightly smaller */
            font-weight: 500;
        }
        .action-buttons button:hover {
            border-color: #007bff; /* Blue border */
            color: #007bff; /* Blue text */
            background: #e6f7ff; /* Light blue background */
        }
         /* Specific styling for refund button perhaps */
         .action-buttons button:last-child:hover {
            border-color: #dc3545; /* Red border */
            color: #dc3545; /* Red text */
            background: rgba(220, 53, 69, 0.1); /* Light red background */
         }


        /* ===== Pagination (Light Theme) ===== */
        .pagination-container {
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 25px 0;
        }
        .pagination a {
            color: #007bff; /* Blue text */
            padding: 8px 14px;
            text-decoration: none;
            transition: background-color .3s, border-color .3s, color .3s;
            border: 1px solid #dee2e6; /* Light gray border */
            margin: 0 4px;
            border-radius: 6px;
            background-color: #ffffff; /* White background */
        }
        .pagination a.active {
            background: linear-gradient(135deg, #00d4ff 0%, #0099ff 100%);
            color: #ffffff; /* White text */
            font-weight: 700;
            border-color: #007bff; /* Blue border */
        }
        .pagination a:hover:not(.active) {
            background-color: #e6f7ff; /* Light blue background */
            border-color: #007bff; /* Blue border */
            color: #0056b3; /* Darker blue text */
        }

        /* ===== Footer (Light Theme) ===== */
        footer {
            background: #ffffff; /* White background */
            border-top: 1px solid #e2e8f0; /* Light gray border */
            color: #6b7280;
            text-align: center;
            padding: 25px;
            margin-left: 280px;
            font-size: 14px;
        }
          /* Responsive */
         @media (max-width: 992px) { /* Adjust breakpoint if needed */
              .sidebar { width: 100%; height: auto; position: relative; box-shadow: none; border-right: none; border-bottom: 1px solid #e2e8f0;}
              header, .content, footer { margin-left: 0; }
         }
          @media (max-width: 768px) {
              .filter-container { padding: 15px; }
              .filter-group { min-width: calc(50% - 10px);} /* Two columns on smaller screens */
              th, td { padding: 12px 10px; font-size: 13px;}
              .action-buttons button { padding: 5px 10px; font-size: 12px;}
              header h1, .section-title { font-size: 22px;}
              .content { padding: 25px;}
              .pagination a { padding: 6px 10px; font-size: 13px;}
         }
          @media (max-width: 576px) {
               .filter-group { min-width: 100%;} /* Full width on extra small screens */
               .filter-buttons { width: 100%; justify-content: space-between;}
               .filter-buttons button { flex-grow: 1;}
               .filter-buttons .btn-clear { margin-left: 10px;}
          }
    </style>
</head>
<body>

    <div class="sidebar">
        <div class="sidebar-logo">
            <h2>CINEMA PRO</h2>
            <p>Admin Panel</p>
        </div>
        <nav>
            <a href="${pageContext.request.contextPath}/admindashboard">Bảng điều khiển</a>
            <a href="${pageContext.request.contextPath}/views/admin/userManager.jsp">Quản lý người dùng</a>
            <a href="${pageContext.request.contextPath}/admin/staff">Quản lý nhân viên</a>
            <a href="${pageContext.request.contextPath}/admin/cinemas">Quản lý rạp</a>
            <a href="${pageContext.request.contextPath}/admin/movies">Quản lý phim</a>
            <a href="${pageContext.request.contextPath}/admin/seat-types">Quản lý loại ghế</a>
            <a href="${pageContext.request.contextPath}/views/admin/paymentManager.jsp" class="active">Quản lý thanh toán</a>
            <a href="${pageContext.request.contextPath}/admin/vouchers">Quản lý Voucher</a>
        </nav>
        <a href="${pageContext.request.contextPath}/logout" class="logout">Đăng xuất</a>
    </div>

    <header>
        <h1>Quản lý thanh toán</h1>
        <div class="header-right">
            <span>Admin: Nguyễn Văn A</span>
            <span><%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %></span>
            <div class="notification-badge">
                <span>Thông báo</span>
                <span class="badge">3</span>
            </div>
        </div>
    </header>

    <div class="content">

        <h2 class="section-title">Lọc và tìm kiếm giao dịch</h2>
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


        <h2 class="section-title">Danh sách Giao dịch</h2>
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
                     <%-- Thêm các dòng khác nếu cần --%>
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