<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %> <%-- Added for date formatting --%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %> <%-- Added for string manipulation --%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Quản lý Người dùng | Cinema Booking</title>
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
                align-items: center;
            }

            .search-box input,
            .search-box select {
                background: #ffffff;
                border: 1px solid #ced4da;
                border-radius: 12px;
                padding: 12px 20px;
                color: #2d3748;
                font-size: 14px;
                outline: none;
                transition: all 0.3s ease;
                height: 44px; /* Consistent height */
            }
             .search-box input { flex: 1; }
             .search-box select option {
                 color: #333;
                 background-color: #fff;
             }

            .search-box input:focus,
            .search-box select:focus {
                border-color: #007bff;
                box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.25);
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
                display: inline-flex;
                align-items: center;
                gap: 8px;
                text-decoration: none;
                height: 44px; /* Match input height */
            }

            .btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 25px rgba(0, 123, 255, 0.3);
            }

            .btn-danger { /* For potentially dangerous actions like delete confirmation */
                background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
            }

            .btn-danger:hover {
                box-shadow: 0 8px 25px rgba(239, 68, 68, 0.4);
            }

            /* ===== Table Container (Light Theme) ===== */
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
                vertical-align: middle;
            }

            tr:hover td {
                background: #f8f9fa;
                color: #1a202c;
            }

            .user-avatar {
                width: 40px;
                height: 40px;
                border-radius: 50%;
                background: linear-gradient(135deg, #00d4ff 0%, #0099ff 100%);
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: 700;
                color: white;
            }

            .status-badge {
                padding: 6px 14px;
                border-radius: 20px;
                font-size: 12px;
                font-weight: 600;
                display: inline-block;
                border: 1px solid transparent;
            }

            .status-active { background: rgba(16, 185, 129, 0.1); color: #10b981; border-color: rgba(16, 185, 129, 0.3); }
            .status-inactive { background: rgba(239, 68, 68, 0.1); color: #dc3545; border-color: rgba(239, 68, 68, 0.3); } /* Using standard red */
            .status-locked { background: rgba(251, 146, 60, 0.1); color: #fd7e14; border-color: rgba(251, 146, 60, 0.3); } /* Using standard orange */


            .action-buttons {
                display: flex;
                gap: 8px;
            }

            .btn-small {
                padding: 8px 12px;
                font-size: 11px;
                border-radius: 8px;
                border: 1px solid;
                cursor: pointer;
                transition: all 0.3s ease;
                font-weight: 600;
                text-decoration: none;
                display: inline-flex;
                align-items: center;
                gap: 4px;
                text-align: center;
                 background: transparent;
            }

            /* Consistent light theme action buttons */
            .btn-edit { border-color: rgba(0, 123, 255, 0.3); color: #007bff; background: rgba(0, 123, 255, 0.1);}
            .btn-edit:hover { background: rgba(0, 123, 255, 0.2); transform: translateY(-2px); }

            .btn-lock { border-color: rgba(251, 146, 60, 0.3); color: #fb923c; background: rgba(251, 146, 60, 0.1); }
            .btn-lock:hover { background: rgba(251, 146, 60, 0.2); transform: translateY(-2px); }

            .btn-delete { border-color: rgba(239, 68, 68, 0.3); color: #ef4444; background: rgba(239, 68, 68, 0.1); }
            .btn-delete:hover { background: rgba(239, 68, 68, 0.2); transform: translateY(-2px); }

            /* ===== Pagination (Light Theme) ===== */
            .pagination {
                display: flex;
                justify-content: center;
                align-items: center;
                gap: 10px;
                margin-top: 30px;
            }

            .pagination button { /* Assuming buttons for pagination */
                background: #ffffff;
                border: 1px solid #dee2e6;
                color: #007bff;
                padding: 10px 16px;
                border-radius: 10px;
                cursor: pointer;
                font-weight: 600;
                transition: all 0.3s ease;
            }

            .pagination button:hover {
                background: #e6f7ff;
                border-color: #007bff;
                transform: translateY(-2px);
            }

            .pagination button.active {
                background: linear-gradient(135deg, #00d4ff 0%, #0099ff 100%);
                color: white;
                border-color: transparent;
            }
             .pagination button:disabled {
                 background-color: #e9ecef;
                 color: #6c757d;
                 border-color: #dee2e6;
                 cursor: not-allowed;
                 transform: none;
             }


            /* ===== Modal (Light Theme) ===== */
            .modal {
                display: none;
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(0, 0, 0, 0.5); /* Semi-transparent black overlay */
                backdrop-filter: blur(5px);
                z-index: 2000;
                justify-content: center;
                align-items: center;
            }

            .modal.active {
                display: flex;
            }

            .modal-content {
                background: #ffffff; /* White background */
                border: 1px solid #e2e8f0; /* Light gray border */
                border-radius: 20px;
                padding: 40px;
                max-width: 500px;
                width: 90%;
                max-height: 80vh;
                overflow-y: auto;
                box-shadow: 0 15px 30px rgba(0, 0, 0, 0.1);
            }

            .modal-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 30px;
                padding-bottom: 20px; /* Add padding for border */
                border-bottom: 1px solid #e2e8f0; /* Separator */
            }

            .modal-header h2 {
                font-size: 24px;
                color: #1a202c; /* Dark heading */
                 background: none;
                 -webkit-background-clip: unset;
                 -webkit-text-fill-color: unset;
                 margin: 0; /* Remove default margin */
            }

            .close-modal {
                background: #f8f9fa; /* Light gray background */
                border: 1px solid #dee2e6; /* Gray border */
                color: #6c757d; /* Gray icon */
                font-size: 20px;
                width: 35px;
                height: 35px;
                border-radius: 50%;
                cursor: pointer;
                transition: all 0.3s ease;
                display: flex; /* Center the 'X' */
                align-items: center;
                justify-content: center;
                line-height: 1;
            }

            .close-modal:hover {
                background: #e9ecef; /* Slightly darker gray */
                color: #dc3545; /* Red on hover */
                transform: rotate(90deg);
            }

            /* Re-use form styles within modal */
            .modal .form-group label { color: #4a5568; }
            .modal .form-group input,
            .modal .form-group select {
                background: #ffffff;
                border-color: #ced4da;
                color: #2d3748;
            }
             .modal .form-group select option {
                 color: #333;
                 background-color: #fff;
             }
            .modal .form-group input:focus,
            .modal .form-group select:focus {
                border-color: #007bff;
                box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.25);
            }
            .modal .form-actions { margin-top: 30px; border-top: 1px solid #e2e8f0; padding-top: 30px;}
             .modal .btn-cancel { /* Override default cancel button for modal context */
                background: #6c757d;
                color: #ffffff;
                border: 1px solid #6c757d;
             }
             .modal .btn-cancel:hover { background: #5a6268; }


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
                 <a href="${pageContext.request.contextPath}/views/admin/userManager.jsp" class="active">👥 Quản lý người dùng</a> <%-- Active link --%>
                 <a href="${pageContext.request.contextPath}/admin/staff">🧑‍💼 Quản lý nhân viên</a>
                 <a href="${pageContext.request.contextPath}/admin/cinemas">🏢 Quản lý rạp</a>
                 <a href="${pageContext.request.contextPath}/admin/movies">🎞️ Quản lý phim</a>
                 <a href="${pageContext.request.contextPath}/admin/seat-types">💺 Quản lý loại ghế</a>
                 <a href="${pageContext.request.contextPath}/views/admin/paymentManager.jsp">💳 Quản lý thanh toán</a>
            </nav>
            <a href="${pageContext.request.contextPath}/logout" class="logout">🚪 Đăng xuất</a>
        </div>

        <header>
            <h1>👥 Quản lý người dùng</h1>
            <div class="header-right">
                <span>👤 Admin: Nguyễn Văn A</span>
                <span>⏰ <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %></span>
            </div>
        </header>

        <div class="content">

            <div class="stats-container">
                <div class="stat-box">
                    <h3>👥 Tổng người dùng</h3>
                    <div class="stat-value">1,247</div> <%-- Placeholder --%>
                </div>
                <div class="stat-box">
                    <h3>✅ Đang hoạt động</h3>
                    <div class="stat-value">1,089</div> <%-- Placeholder --%>
                </div>
                <div class="stat-box">
                    <h3>🔒 Bị khóa</h3>
                    <div class="stat-value">15</div> <%-- Placeholder --%>
                </div>
                <div class="stat-box">
                    <h3>🆕 Mới trong tháng</h3>
                    <div class="stat-value">143</div> <%-- Placeholder --%>
                </div>
            </div>

            <div class="toolbar">
                <div class="search-box">
                    <input type="text" placeholder="🔍 Tìm kiếm theo tên, email, số điện thoại...">
                    <select>
                        <option value="">Tất cả trạng thái</option>
                        <option value="active">Đang hoạt động</option>
                        <option value="inactive">Không hoạt động</option>
                        <option value="locked">Bị khóa</option>
                    </select>
                     <button class="btn" style="padding: 12px 20px;">🔍 Tìm</button> <%-- Search button --%>
                </div>
                <button class="btn" onclick="openAddUserModal()">➕ Thêm người dùng</button>
            </div>

            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Người dùng</th>
                            <th>Email</th>
                            <th>SĐT</th>
                            <th>Ngày ĐK</th>
                            <th>Vé đã mua</th>
                            <th>Trạng thái</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%-- Example rows (replace with actual data using JSTL) --%>
                        <tr>
                            <td>#001</td>
                            <td>
                                <div style="display: flex; align-items: center; gap: 12px;">
                                    <div class="user-avatar">NA</div>
                                    <span>Nguyễn Văn An</span>
                                </div>
                            </td>
                            <td>nguyenvanan@gmail.com</td>
                            <td>0912345678</td>
                            <td>15/01/24</td>
                            <td>23</td>
                            <td><span class="status-badge status-active">Hoạt động</span></td>
                            <td>
                                <div class="action-buttons">
                                    <button class="btn-small btn-edit" onclick="editUser(1)">✏️ Sửa</button>
                                    <button class="btn-small btn-lock">🔒 Khóa</button>
                                    <button class="btn-small btn-delete">🗑️ Xóa</button>
                                </div>
                            </td>
                        </tr>
                         <tr>
                            <td>#002</td>
                            <td>
                                <div style="display: flex; align-items: center; gap: 12px;">
                                    <div class="user-avatar">TL</div>
                                    <span>Trần Thị Lan</span>
                                </div>
                            </td>
                            <td>tranthilan@gmail.com</td>
                            <td>0987654321</td>
                            <td>20/01/24</td>
                            <td>45</td>
                            <td><span class="status-badge status-active">Hoạt động</span></td>
                            <td>
                                <div class="action-buttons">
                                    <button class="btn-small btn-edit" onclick="editUser(2)">✏️ Sửa</button>
                                    <button class="btn-small btn-lock">🔒 Khóa</button>
                                    <button class="btn-small btn-delete">🗑️ Xóa</button>
                                </div>
                            </td>
                        </tr>
                         <tr>
                            <td>#003</td>
                            <td>
                                <div style="display: flex; align-items: center; gap: 12px;">
                                    <div class="user-avatar">LH</div>
                                    <span>Lê Văn Hùng</span>
                                </div>
                            </td>
                            <td>levanhung@gmail.com</td>
                            <td>0901234567</td>
                            <td>05/02/24</td>
                            <td>12</td>
                            <td><span class="status-badge status-locked">Bị khóa</span></td>
                            <td>
                                <div class="action-buttons">
                                    <button class="btn-small btn-edit" onclick="editUser(3)">✏️ Sửa</button>
                                    <button class="btn-small btn-lock" style="background: rgba(16, 185, 129, 0.1); color: #10b981; border-color: rgba(16, 185, 129, 0.3);">🔓 Mở</button> <%-- Unlock button styled differently --%>
                                    <button class="btn-small btn-delete">🗑️ Xóa</button>
                                </div>
                            </td>
                        </tr>
                         <tr>
                            <td>#004</td>
                            <td>
                                <div style="display: flex; align-items: center; gap: 12px;">
                                    <div class="user-avatar">PM</div>
                                    <span>Phạm Thị Mai</span>
                                </div>
                            </td>
                            <td>phamthimai@gmail.com</td>
                            <td>0923456789</td>
                            <td>10/02/24</td>
                            <td>8</td>
                            <td><span class="status-badge status-inactive">Không hoạt động</span></td>
                            <td>
                                <div class="action-buttons">
                                    <button class="btn-small btn-edit" onclick="editUser(4)">✏️ Sửa</button>
                                    <button class="btn-small btn-lock">🔒 Khóa</button>
                                    <button class="btn-small btn-delete">🗑️ Xóa</button>
                                </div>
                            </td>
                        </tr>
                        <%-- Add more rows as needed --%>
                    </tbody>
                </table>
                 <%-- Placeholder for empty table state --%>
                <%--
                <c:if test="${empty userList}">
                    <div style="text-align: center; padding: 40px; color: #6b7280;">
                        <p>📭 Không có người dùng nào được tìm thấy.</p>
                    </div>
                </c:if>
                --%>
            </div>

            <div class="pagination">
                <button disabled>&laquo; Trước</button> <%-- Example pagination --%>
                <button class="active">1</button>
                <button>2</button>
                <button>3</button>
                <button>Sau &raquo;</button>
            </div>
        </div>

        <div id="userModal" class="modal">
            <div class="modal-content">
                <div class="modal-header">
                    <h2 id="modalTitle">➕ Thêm người dùng mới</h2>
                    <button class="close-modal" onclick="closeModal('userModal')">&times;</button>
                </div>
                <form id="userForm"> <%-- Add form for submission later --%>
                    <input type="hidden" id="userId" name="userId">
                     <div class="form-group">
                         <label for="username">👤 Tên người dùng</label>
                         <input type="text" id="username" name="username" required>
                     </div>
                     <div class="form-group">
                         <label for="email">📧 Email</label>
                         <input type="email" id="email" name="email" required>
                     </div>
                      <div class="form-group" id="passwordGroup"> <%-- Hide for edit --%>
                         <label for="password">🔑 Mật khẩu</label>
                         <input type="password" id="password" name="password" required>
                     </div>
                     <div class="form-group">
                         <label for="phoneNumber">📞 Số điện thoại</label>
                         <input type="tel" id="phoneNumber" name="phoneNumber">
                     </div>
                     <div class="form-group">
                         <label for="role">🎭 Vai trò</label>
                         <select id="role" name="role">
                             <option value="user">Người dùng</option>
                             <option value="staff">Nhân viên</option>
                              <option value="manager">Quản lý rạp</option>
                               <option value="admin">Quản trị viên</option>
                         </select>
                     </div>
                     <div class="form-actions">
                         <button type="submit" class="btn">💾 Lưu</button>
                         <button type="button" class="btn btn-cancel" onclick="closeModal('userModal')">Hủy</button>
                     </div>
                 </form>
            </div>
        </div>


        <footer>
            © 2025 Cinema Booking System - Admin Panel | Powered by Modern Technology
        </footer>

        <script>
            function openAddUserModal() {
                document.getElementById('modalTitle').innerText = '➕ Thêm người dùng mới';
                document.getElementById('userForm').reset(); // Clear form
                document.getElementById('userId').value = ''; // Ensure ID is empty
                document.getElementById('passwordGroup').style.display = 'block'; // Show password field
                document.getElementById('userModal').classList.add('active');
            }

            function editUser(userId) {
                 // In a real application, you'd fetch user data via AJAX based on userId
                 // For now, let's just populate with dummy data for demonstration
                 document.getElementById('modalTitle').innerText = '✏️ Chỉnh sửa người dùng';
                 document.getElementById('userId').value = userId; // Set user ID for update
                 document.getElementById('username').value = 'User ' + userId; // Dummy data
                 document.getElementById('email').value = 'user' + userId + '@example.com'; // Dummy data
                 document.getElementById('phoneNumber').value = '090000000' + userId; // Dummy data
                 document.getElementById('role').value = 'user'; // Default role, adjust if needed
                 document.getElementById('passwordGroup').style.display = 'none'; // Hide password for edit
                 document.getElementById('userModal').classList.add('active');
            }


            function closeModal(modalId) {
                document.getElementById(modalId).classList.remove('active');
            }

             // Close modal if clicking outside the content
             window.onclick = function(event) {
                 const modal = document.getElementById('userModal');
                 if (event.target == modal) {
                     closeModal('userModal');
                 }
             }

             // Basic form submission simulation (replace with actual AJAX/form submit)
             document.getElementById('userForm').addEventListener('submit', function(e) {
                 e.preventDefault();
                 console.log('Form submitted (simulation)');
                 // Add your form submission logic here (e.g., AJAX request)
                 closeModal('userModal');
                 // Optionally show a success message
             });
        </script>

    </body>
</html>