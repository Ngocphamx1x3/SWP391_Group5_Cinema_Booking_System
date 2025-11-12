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

        /* ===== Form Container (Light Theme) ===== */
        .form-container {
            background: #ffffff; /* White background */
            border: 1px solid #e2e8f0; /* Light gray border */
            border-radius: 20px;
            padding: 40px;
            max-width: 600px;
            margin: 0 auto;
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.05); /* Subtle shadow */
        }

        .form-group {
            margin-bottom: 25px;
        }

        .form-group label {
            display: block;
            color: #4a5568; /* Dark gray label */
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 8px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .form-group input,
        .form-group select {
            width: 100%;
            background: #ffffff; /* White input background */
            border: 1px solid #ced4da; /* Gray border */
            border-radius: 12px;
            padding: 14px 16px;
            color: #2d3748; /* Dark text */
            font-size: 15px;
            outline: none;
            transition: all 0.3s ease;
            font-family: 'Inter', sans-serif;
        }
        
         .form-group select option { /* Style options for light theme */
            color: #333;
            background-color: #fff;
         }

        .form-group input:focus,
        .form-group select:focus {
            border-color: #007bff; /* Blue border on focus */
            box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.25); /* Focus ring */
        }

        .form-group input:read-only,
        .form-group select:disabled { /* Style disabled select */
            background: #e9ecef; /* Lighter gray background */
            color: #6c757d; /* Gray text */
            cursor: not-allowed;
            border-color: #ced4da; /* Ensure border is consistent */
        }
         .form-group select:disabled { /* Specific styling for disabled select appearance */
             -webkit-appearance: none;
             -moz-appearance: none;
             appearance: none;
         }

        .form-actions {
            display: flex;
            gap: 15px;
            margin-top: 30px;
            padding-top: 30px; /* Add padding top for separation */
            border-top: 1px solid #e2e8f0; /* Light gray border */
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
            flex: 1; /* Make buttons take equal space */
        }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(0, 123, 255, 0.3); /* Blue shadow */
        }

        .btn-cancel {
            background: #6c757d; /* Gray background */
            color: #ffffff; /* White text */
            border: 1px solid #6c757d;
        }

        .btn-cancel:hover {
            background: #5a6268; /* Darker gray */
            transform: translateY(-2px); /* Consistent hover effect */
             box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }

        /* Switch Toggle (Light Theme) */
        .switch {
            position: relative;
            display: inline-block;
            width: 50px; /* Slightly smaller */
            height: 28px; /* Slightly smaller */
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
            background-color: #ced4da; /* Gray background when off */
            transition: .4s;
            border-radius: 28px; /* Rounded */
        }

        .slider:before {
            position: absolute;
            content: "";
            height: 20px; /* Smaller circle */
            width: 20px; /* Smaller circle */
            left: 4px;
            bottom: 4px;
            background-color: white;
            transition: .4s;
            border-radius: 50%;
        }

        input:checked + .slider {
            background-color: #007bff; /* Blue background when on */
        }

        input:checked + .slider:before {
            transform: translateX(22px); /* Adjust translation */
        }
         input:disabled + .slider { /* Style for disabled switch */
            cursor: not-allowed;
            background-color: #e9ecef;
         }
         input:disabled + .slider:before {
             background-color: #adb5bd;
         }


        /* Alert Messages (Light Theme) */
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

        /* ===== Footer (Light Theme) ===== */
        footer {
            background: #ffffff; /* White background */
            border-top: 1px solid #e2e8f0; /* Light gray border */
            color: #6b7280;
            text-align: center;
            padding: 25px;
            margin-left: 280px; /* Keep consistent with header/content */
            margin-top: 40px;
            font-size: 14px;
        }
        .toolbar select option {
             color: #333;
             background-color: #fff;
        }

        .status-text {
            font-weight: 600;
            color: #2d3748; /* Dark text for status */
        }
         /* Responsive */
         @media (max-width: 992px) { /* Adjust breakpoint if needed */
              .sidebar { width: 100%; height: auto; position: relative; box-shadow: none; border-right: none; border-bottom: 1px solid #e2e8f0;}
              header, .content, footer { margin-left: 0; }
         }
         @media (max-width: 768px) {
             .content { padding: 25px;}
              header h1 { font-size: 24px;}
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
            <a href="${pageContext.request.contextPath}/admin/seat-types">💺 Quản lý loại ghế</a>
            <a href="${pageContext.request.contextPath}/views/admin/paymentManager.jsp">💳 Quản lý thanh toán</a>
            <a href="${pageContext.request.contextPath}/admin/vouchers">🎫 Quản lý Voucher</a>
        </nav>
        <a href="${pageContext.request.contextPath}/logout" class="logout">🚪 Đăng xuất</a>
    </div>

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

    <div class="content">

        <c:if test="${not empty error}">
            <div class="alert alert-error">
                ❌ ${error}
            </div>
        </c:if>
         <c:if test="${not empty success}"> <%-- Assuming success message passed as 'success' --%>
            <div class="alert alert-success">
                ✅ ${success}
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
                           <c:if test="${viewMode or not empty staff}">readonly</c:if> <%-- Username readonly if editing/viewing --%>
                           required>
                </div>

                 <%-- Password field only for adding new staff --%>
                <c:if test="${empty staff}">
                    <div class="form-group">
                        <label for="password">🔑 Mật khẩu</label>
                        <input type="password" id="password" name="password" required>
                    </div>
                </c:if>

                <div class="form-group">
                    <label for="role">💼 Vị trí</label>
                    <select id="role" name="role" <c:if test="${viewMode}">disabled</c:if>>
                        <option value="staff" <c:if test="${staff.role == 'staff'}">selected</c:if>>Nhân viên</option>
                        <option value="manager" <c:if test="${staff.role == 'manager'}">selected</c:if>>Quản lý rạp</option>
                        <option value="support" <c:if test="${staff.role == 'support'}">selected</c:if>>Hỗ trợ KH</option>
                    </select>
                    <c:if test="${viewMode}">
                        <input type="hidden" name="role" value="${staff.role}"> <%-- Send role value even if disabled --%>
                    </c:if>
                </div>

                <div class="form-group">
                    <label>📊 Trạng thái</label>
                    <div style="display: flex; align-items: center; gap: 15px; margin-top: 10px;">
                        <label class="switch">
                            <input type="checkbox" name="status" value="true" <%-- Send 'true' when checked --%>
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
                         <c:if test="${viewMode}"> <%-- Send status value even if disabled --%>
                            <input type="hidden" name="status" value="${staff.status}">
                         </c:if>
                          <%-- If checkbox is unchecked, no 'status' parameter is sent. Need a hidden field for false case during update/create --%>
                          <c:if test="${not viewMode}">
                               <input type="hidden" name="_status" value="on"> <%-- Helper field for Spring MVC/Servlet --%>
                          </c:if>
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

    <footer>
        <p>© 2025 Cinema Booking System - Admin Panel | Powered by Modern Technology</p> <%-- Updated year --%>
    </footer>

     <script>
         // Optional: Add JS to update status text dynamically if needed, though JSP handles initial state
         const statusCheckbox = document.querySelector('input[name="status"]');
         const statusTextSpan = document.querySelector('.status-text');

         if (statusCheckbox && statusTextSpan && !statusCheckbox.disabled) {
             statusCheckbox.addEventListener('change', function() {
                 statusTextSpan.textContent = this.checked ? 'Đang hoạt động' : 'Ngừng hoạt động';
             });
             // Initial text set by JSTL/JSP
         }
    </script>

</body>
</html>