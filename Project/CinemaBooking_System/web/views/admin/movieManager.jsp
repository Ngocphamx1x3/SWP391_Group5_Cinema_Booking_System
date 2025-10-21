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
        /* ========== CORE STYLES (tinh gọn lại cho ngắn gọn hơn) ========== */
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #0a0e27 0%, #1a1f3a 100%);
            color: #e4e9f0;
            min-height: 100vh;
        }
        .sidebar {
            position: fixed; top: 0; left: 0; width: 280px; height: 100vh;
            background: linear-gradient(180deg, #0f1419 0%, #1a1f2e 100%);
            border-right: 1px solid rgba(0, 255, 255, 0.1);
            display: flex; flex-direction: column; padding: 30px 0;
        }
        .sidebar-logo { text-align: center; margin-bottom: 50px; }
        .sidebar-logo h2 {
            font-size: 26px; font-weight: 700;
            background: linear-gradient(135deg, #00d4ff 0%, #0099ff 100%);
            -webkit-background-clip: text; -webkit-text-fill-color: transparent;
        }
        .sidebar nav a {
            color: #94a3b8; text-decoration: none; display: block;
            padding: 16px 30px; transition: 0.3s;
        }
        .sidebar nav a:hover, .sidebar nav a.active {
            background: rgba(0,212,255,0.1); color: #00d4ff;
        }
        .sidebar a.logout {
            margin-top: auto; color: #ef4444; text-align: center;
            background: rgba(239,68,68,0.1); border-radius: 12px; margin: 20px;
            padding: 12px 0;
        }
        header {
            margin-left: 280px; padding: 20px 40px;
            background: rgba(15,20,25,0.8); border-bottom: 1px solid rgba(0,255,255,0.1);
            display: flex; justify-content: space-between; align-items: center;
        }
        .content { margin-left: 280px; padding: 40px; }
        .section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
        .section-title {
            font-size: 24px; font-weight: 700;
            background: linear-gradient(135deg, #ffffff 0%, #00d4ff 100%);
            -webkit-background-clip: text; -webkit-text-fill-color: transparent;
        }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 15px; border-bottom: 1px solid rgba(255,255,255,0.05); }
        th { color: #00d4ff; font-size: 13px; text-transform: uppercase; }
        td { color: #94a3b8; font-size: 14px; }
        tr:hover td { background: rgba(0,212,255,0.05); color: #fff; }
        .poster-img { width: 50px; height: 75px; border-radius: 6px; object-fit: cover; }
        .status { padding: 5px 12px; border-radius: 12px; font-size: 12px; font-weight: 600; }
        .status-showing { background: rgba(16,185,129,0.1); color: #10b981; }
        .status-upcoming { background: rgba(245,158,11,0.1); color: #f59e0b; }
        .btn { padding: 10px 20px; border: none; border-radius: 10px; cursor: pointer; }
        .btn-primary {
            background: linear-gradient(135deg, #00d4ff 0%, #0099ff 100%);
            color: #0f1419; font-weight: 600;
        }
        footer {
            background: rgba(15,20,25,0.9); border-top: 1px solid rgba(0,255,255,0.1);
            text-align: center; padding: 25px; margin-left: 280px; color: #6b7280;
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
            <a href="${pageContext.request.contextPath}/views/admin/staffManager.jsp">🧑‍💼 Quản lý nhân viên</a>
            <a href="${pageContext.request.contextPath}/views/admin/cinemaManager.jsp">🏢 Quản lý rạp</a>
            <a href="${pageContext.request.contextPath}/admin/movies" class="active">🎞️ Quản lý phim</a>
            <a href="${pageContext.request.contextPath}/admin/seat-types">💺 Quản lý loại ghế</a>
            <a href="${pageContext.request.contextPath}/views/admin/paymentManager.jsp">💳 Quản lý thanh toán</a>
        </nav>
        <a href="${pageContext.request.contextPath}/logout" class="logout">🚪 Đăng xuất</a>
    </div>

    <!-- Header -->
    <header>
        <h1>Quản lý phim</h1>
        <div class="header-right">
            <span>👤 Admin: Nguyễn Văn A</span>
            <span>⏰ <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %></span>
        </div>
    </header>

    <!-- Main content -->
    <div class="content">
        <div class="section-header">
            <h2 class="section-title">🎞️ Danh sách phim</h2>
            <button class="btn btn-primary" id="addMovieBtn">➕ Thêm phim mới</button>
        </div>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Poster</th>
                        <th>Tên phim</th>
                        <th>Thể loại</th>
                        <th>Thời lượng</th>
                        <th>Ngày phát hành</th>
                        <th>Trạng thái</th>
                        <th>Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <!-- Hiển thị nếu có danh sách phim -->
                    <c:forEach var="m" items="${movieList}">
                        <tr>
<td>
    <c:choose>
        <c:when test="${not empty m.image}">
            <img src="${pageContext.request.contextPath}/assets/admin/img/img/${m.image}" 
                 alt="${m.name}" class="poster-img">
        </c:when>
        <c:otherwise>
            <span>Poster ?</span>
        </c:otherwise>
    </c:choose>
</td>

                            <td>${m.name}</td>
                            <td>${m.status}</td>
                            <td>${m.movieDuration} phút</td>
                            <td><fmt:formatDate value="${m.premiereDate}" pattern="dd/MM/yyyy"/></td>
                            <td>
                                <span class="status ${m.status == 'Đang chiếu' ? 'status-showing' : 'status-upcoming'}">
                                    ${m.status}
                                </span>
                            </td>
                            <td>
                                <a href="${pageContext.request.contextPath}/admin/movies?action=edit&id=${m.id}">✏️</a>
                                <a href="${pageContext.request.contextPath}/admin/movies?action=delete&id=${m.id}" onclick="return confirm('Xóa phim này?')">🗑️</a>
                            </td>
                        </tr>
                    </c:forEach>

                    <!-- Nếu danh sách rỗng -->
                    <c:if test="${empty movieList}">
                        <tr>
                            <td colspan="7" style="text-align:center; color:#6b7280;">Không có phim nào được tìm thấy.</td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Footer -->
    <footer>
        © 2025 Cinema Booking System - Admin Panel | Powered by Modern Technology
    </footer>

    <script>
        // Modal thêm phim (demo)
        document.getElementById('addMovieBtn').addEventListener('click', function() {
            alert('Chức năng thêm phim sẽ được mở ở đây!');
        });
    </script>
</body>
</html>
