<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý Phim | Cinema Booking</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        /* ========== CORE STYLES (Light Theme) ========== */
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Inter', sans-serif;
            background: #f4f7fa; /* Light background */
            color: #2d3748; /* Dark text */
            min-height: 100vh;
        }
        .sidebar {
            position: fixed; top: 0; left: 0; width: 280px; height: 100vh;
            background: #ffffff; /* White background */
            border-right: 1px solid #e2e8f0; /* Light gray border */
            display: flex; flex-direction: column; padding: 30px 0;
            box-shadow: 2px 0 15px rgba(0, 0, 0, 0.05); /* Subtle shadow */
            z-index: 1000;
        }
        .sidebar-logo { text-align: center; margin-bottom: 50px; padding: 0 25px; }
        .sidebar-logo h2 {
            font-size: 26px; font-weight: 700;
            color: #1a202c; /* Dark text for logo */
            background: none;
            -webkit-background-clip: unset; -webkit-text-fill-color: unset;
        }
         .sidebar-logo p { font-size:11px; color:#6b7280; margin-top:5px; text-transform:uppercase; letter-spacing:2px; }
        .sidebar nav { flex:1; overflow-y:auto; }
        .sidebar nav a {
            color: #4a5568; /* Dark gray text for links */
            text-decoration: none;
            display: flex; /* Use flex for icon alignment if needed */
            align-items: center;
            gap: 15px;
            padding: 16px 30px;
            transition: 0.3s;
            position: relative;
            font-size: 15px;
            font-weight: 500;
        }
         .sidebar nav a::before {
            content: ''; position: absolute; left: 0; top: 0; height: 100%; width: 4px;
            background: linear-gradient(180deg, #00d4ff 0%, #0099ff 100%);
            transform: scaleY(0); transition: transform 0.3s ease;
         }
        .sidebar nav a:hover, .sidebar nav a.active {
            background: #e6f7ff; /* Light blue background */
            color: #007bff; /* Darker blue text */
            padding-left: 35px;
        }
         .sidebar nav a:hover::before, .sidebar nav a.active::before {
             transform: scaleY(1);
         }
        .sidebar a.logout {
            margin-top: auto; color: #ef4444; text-align: center;
            background: rgba(239,68,68,0.1); border-radius: 12px; margin: 20px;
            padding: 12px 0; display: block; text-decoration: none; font-weight: 500;
             transition: 0.3s;
        }
         .sidebar a.logout:hover {
              background: rgba(239, 68, 68, 0.2);
         }
        header {
            margin-left: 280px; padding: 20px 40px;
            background: rgba(255,255,255,0.8); /* Light transparent background */
            backdrop-filter: blur(10px);
            border-bottom: 1px solid #e2e8f0; /* Light gray border */
            display: flex; justify-content: space-between; align-items: center;
            position: sticky; top: 0; z-index: 100;
        }
         header h1 {
              font-size: 28px; font-weight: 700; color: #1a202c; /* Dark heading */
              background: none; -webkit-background-clip: unset; -webkit-text-fill-color: unset;
         }
         .header-right { display:flex; align-items:center; gap:35px; }
         .header-right span { font-weight:500; color:#4a5568; font-size:14px; display:flex; align-items:center; gap:8px; }

        .content { margin-left: 280px; padding: 40px; }
        .section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; flex-wrap: wrap; gap: 20px;}
        .section-title {
            font-size: 24px; font-weight: 700;
            color: #1a202c; /* Dark title */
             background: none; -webkit-background-clip: unset; -webkit-text-fill-color: unset;
        }
        .table-container {
             background: #ffffff; /* White background */
             border: 1px solid #e2e8f0; /* Light gray border */
             border-radius: 20px;
             padding: 30px;
             overflow-x: auto;
             box-shadow: 0 10px 20px rgba(0, 0, 0, 0.05);
        }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 18px 15px; border-bottom: 1px solid #e2e8f0; /* Light gray border */ text-align: left; vertical-align: middle;}
        th {
            background: #f8f9fa; /* Lighter gray background */
            color: #4a5568; /* Dark gray text */
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 1px;
             border-bottom-width: 2px;
             border-color: #dee2e6; /* Slightly darker border */
        }
        td { color: #2d3748; font-size: 14px; }
        tr:hover td { background: #f8f9fa; color: #1a202c; } /* Lighter hover */
        .poster-img { width: 50px; height: 75px; border-radius: 6px; object-fit: cover; border: 1px solid #e2e8f0;}
        .status { padding: 6px 14px; border-radius: 20px; font-size: 12px; font-weight: 600; display: inline-block; }
        .status-showing { background: rgba(16,185,129,0.2); color: #10b981; border: 1px solid rgba(16, 185, 129, 0.3); }
        .status-upcoming { background: rgba(245,158,11,0.2); color: #f59e0b; border: 1px solid rgba(245, 158, 11, 0.3); }
        .btn {
            padding: 12px 28px; /* Consistent padding */
            border: none;
            border-radius: 12px; /* Consistent radius */
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-flex; /* Use inline-flex for button with icon */
            align-items: center;
            gap: 8px;
        }
        .btn-primary {
            background: linear-gradient(135deg, #00d4ff 0%, #0099ff 100%);
            color: #ffffff; /* White text on gradient */
        }
         .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(0, 123, 255, 0.3);
         }
        .action-buttons a {
            display: inline-block;
            margin-right: 10px;
            color: #007bff; /* Blue for edit */
            text-decoration: none;
            font-size: 18px; /* Make icons slightly larger */
             transition: color 0.3s ease;
        }
         .action-buttons a:last-child { margin-right: 0;}
         .action-buttons a[href*="delete"] { color: #dc3545; } /* Red for delete */
         .action-buttons a:hover { color: #0056b3; } /* Darker blue on hover */
         .action-buttons a[href*="delete"]:hover { color: #c82333; } /* Darker red on hover */

        footer {
            background: #ffffff; /* White background */
            border-top: 1px solid #e2e8f0; /* Light gray border */
            text-align: center; padding: 25px; margin-left: 280px; color: #6b7280;
            margin-top: 40px; font-size: 14px;
        }
         /* Responsive */
         @media (max-width: 992px) { /* Adjust breakpoint if needed */
              .sidebar { width: 100%; height: auto; position: relative; box-shadow: none; border-right: none; border-bottom: 1px solid #e2e8f0;}
              header, .content, footer { margin-left: 0; }
         }
         @media (max-width: 768px) {
              th, td { padding: 12px 10px; font-size: 13px;}
              .poster-img { width: 40px; height: 60px;}
              .btn { padding: 10px 20px; font-size: 13px; }
              header h1, .section-title { font-size: 22px;}
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
            <a href="${pageContext.request.contextPath}/admin/staff">🧑‍💼 Quản lý nhân viên</a>
            <a href="${pageContext.request.contextPath}/admin/cinemas">🏢 Quản lý rạp</a>
            <a href="${pageContext.request.contextPath}/admin/movies" class="active">🎞️ Quản lý phim</a>
            <a href="${pageContext.request.contextPath}/admin/seat-types">💺 Quản lý loại ghế</a>
            <a href="${pageContext.request.contextPath}/views/admin/paymentManager.jsp">💳 Quản lý thanh toán</a>
        </nav>
        <a href="${pageContext.request.contextPath}/logout" class="logout">🚪 Đăng xuất</a>
    </div>

    <header>
        <h1>Quản lý phim</h1>
        <div class="header-right">
            <span>👤 Admin: Nguyễn Văn A</span>
            <span>⏰ <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %></span>
        </div>
    </header>

    <div class="content">
        <div class="section-header">
            <h2 class="section-title">🎞️ Danh sách phim</h2>
            <button class="btn btn-primary" id="addMovieBtn"
                    onclick="window.location.href='${pageContext.request.contextPath}/admin/movies?action=addForm'">
                ➕ Thêm phim mới
            </button>
        </div>

        <%-- Display messages --%>
        <c:if test="${not empty successMessage}">
            <div style="padding: 15px 20px; border-radius: 12px; margin-bottom: 25px; font-weight: 600; background: rgba(16, 185, 129, 0.2); color: #10b981; border: 1px solid rgba(16, 185, 129, 0.3);">
                ✅ ${successMessage}
            </div>
        </c:if>
         <c:if test="${not empty errorMessage}">
            <div style="padding: 15px 20px; border-radius: 12px; margin-bottom: 25px; font-weight: 600; background: rgba(239, 68, 68, 0.2); color: #ef4444; border: 1px solid rgba(239, 68, 68, 0.3);">
                ❌ ${errorMessage}
            </div>
        </c:if>


        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Poster</th>
                        <th>Tên phim</th>
                        <th>Thời lượng</th>
                        <th>Ngày KC</th>
                        <th>Trạng thái</th>
                        <th>Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="m" items="${movieList}">
                        <tr>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty m.image}">
                                        <img src="${pageContext.request.contextPath}/assets/admin/img/img/${m.image}"
                                             alt="${m.name}" class="poster-img"
                                             onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/assets/admin/img/img/default.jpg';"> <%-- Fallback image --%>
                                    </c:when>
                                    <c:otherwise>
                                         <img src="${pageContext.request.contextPath}/assets/admin/img/img/default.jpg"
                                             alt="Poster mặc định" class="poster-img"> <%-- Default image --%>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td><strong>${m.name}</strong></td>
                            <td>${m.movieDuration} phút</td>
                            <td><fmt:formatDate value="${m.premiereDate}" pattern="dd/MM/yy"/></td> <%-- Shortened date --%>
                            <td>
                                <span class="status ${m.status == 'Đang chiếu' ? 'status-showing' : 'status-upcoming'}">
                                    ${m.status}
                                </span>
                            </td>
                            <td>
                                <div class="action-buttons">
                                    <a href="${pageContext.request.contextPath}/admin/movies?action=edit&id=${m.id}" title="Chỉnh sửa">✏️</a>
                                    <a href="${pageContext.request.contextPath}/admin/movies?action=delete&id=${m.id}" title="Xóa" onclick="return confirm('Bạn có chắc chắn muốn xóa phim \'${fn:escapeXml(m.name)}\'? Hành động này không thể hoàn tác.')">🗑️</a>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty movieList}">
                        <tr>
                            <td colspan="6" style="text-align:center; color:#6b7280; padding: 40px;">Không có phim nào được tìm thấy.</td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>

    <footer>
        © 2025 Cinema Booking System - Admin Panel | Powered by Modern Technology
    </footer>
</body>
</html>