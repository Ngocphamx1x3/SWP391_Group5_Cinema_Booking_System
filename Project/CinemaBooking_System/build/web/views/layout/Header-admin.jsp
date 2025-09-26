<%@ page contentType="text/html;charset=UTF-8" %>
<header class="page-header">
    <nav>
        <a href="#" class="logo">
            <img src="${pageContext.request.contextPath}/assets/admin/imgLogo/logo_text.png"
                 alt="Admin Logo" width="230" height="200"/>
        </a>

        <ul class="admin-menu">
            <li class="menu-heading"><h3>Admin</h3></li>
            <li><a href="${pageContext.request.contextPath}/admin/home.jsp"><i class="bx bxs-home"></i> Trang chủ</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/service.jsp"><i class="bx bx-restaurant"></i> Dịch vụ</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/movie.jsp"><i class="bx bxs-camera-movie"></i> Quản lý phim</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/customer.jsp"><i class="bx bxs-group"></i> Quản lý khách hàng</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/cinema.jsp"><i class="bx bxs-store-alt"></i> Quản lý rạp</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/bill.jsp"><i class="bx bx-task"></i> Quản lý hóa đơn</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/promotion.jsp"><i class="bx bxs-discount"></i> Quản lý khuyến mãi</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/settings.jsp"><i class="bx bx-cog"></i> Cài đặt</a></li>
        </ul>
    </nav>
</header>

<!-- Scripts -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css"/>
<link href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css" rel="stylesheet"/>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.7.0/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/admin/js/index.js"></script>
