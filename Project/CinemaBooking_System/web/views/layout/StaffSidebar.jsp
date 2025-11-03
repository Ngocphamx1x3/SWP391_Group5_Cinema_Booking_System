<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%
    // Lấy activePage từ request attribute để highlight menu item tương ứng
    String activePage = (String) request.getAttribute("activePage");
    if (activePage == null) {
        activePage = request.getParameter("activePage");
    }
%>
<!-- Staff Sidebar -->
<div class="sidebar">
    <div class="sidebar-logo">
        <h2>🎬 CINEMA PRO</h2>
        <p>Staff Panel</p>
    </div>
    <nav>
        <a href="${pageContext.request.contextPath}/staffdashboard" 
           class="<%= "dashboard".equals(activePage) ? "active" : "" %>">🏢 Thông tin rạp của tôi</a>
        <a href="${pageContext.request.contextPath}/staff/rooms" 
           class="<%= "rooms".equals(activePage) ? "active" : "" %>">🎭 Quản lý phòng chiếu</a>
        <a href="${pageContext.request.contextPath}/staff/seat-design" 
           class="<%= "seat-design".equals(activePage) ? "active" : "" %>">💺 Thiết kế ghế trong phòng</a>
        <a href="${pageContext.request.contextPath}/staff/schedules" 
           class="<%= "schedules".equals(activePage) ? "active" : "" %>">📅 Quản lý lịch chiếu</a>
        <a href="${pageContext.request.contextPath}/views/staff/bookingManager.jsp" 
           class="<%= "bookings".equals(activePage) ? "active" : "" %>">🎫 Quản lý đặt vé</a>
        <a href="${pageContext.request.contextPath}/staff/food-items" 
           class="<%= "food-items".equals(activePage) ? "active" : "" %>">🍿 Quản lý món lẻ</a>
        <a href="${pageContext.request.contextPath}/staff/food-combos" 
           class="<%= "food-combos".equals(activePage) ? "active" : "" %>">🍔 Quản lý combo</a>
        <a href="${pageContext.request.contextPath}/views/staff/cinemaReports.jsp" 
           class="<%= "reports".equals(activePage) ? "active" : "" %>">📈 Báo cáo rạp của tôi</a>
    </nav>
    <a href="${pageContext.request.contextPath}/logout" class="logout">🚪 Đăng xuất</a>
</div>

