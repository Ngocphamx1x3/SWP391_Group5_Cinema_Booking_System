<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<nav class="navbar fixed">
    <div class="menu-icon">
        <span></span><span></span><span></span>
    </div>

    <div class="logo">
        <img src="${pageContext.request.contextPath}/assets/user/img/logo.png" alt="Logo">
    </div>

    <ul class="nav-links">
        <li><a href="${pageContext.request.contextPath}/home">TRANG CHỦ</a></li>
        <li><a href="${pageContext.request.contextPath}/views/users/phim.jsp">PHIM CHIẾU</a></li>
        <li><a href="${pageContext.request.contextPath}/lichchieu.jsp">LỊCH CHIẾU</a></li>
        <li><a href="${pageContext.request.contextPath}/gia-ve.jsp">THÀNH VIÊN & GIÁ VÉ</a></li>

        <!-- Nếu chưa đăng nhập -->
        <c:if test="${empty sessionScope.account}">
            <li><a href="${pageContext.request.contextPath}/login">ĐĂNG NHẬP</a></li>
            <li><a href="${pageContext.request.contextPath}/views/users/register.jsp">ĐĂNG KÝ</a></li>
        </c:if>

        <!-- Nếu đã đăng nhập -->
        <c:if test="${not empty sessionScope.account}">
            <li class="dropdown">
                <a href="#">👋 Xin chào, ${sessionScope.account.username}</a>
                <div class="dropdown-content">
                    <a href="${pageContext.request.contextPath}/userProfile">THÔNG TIN CÁ NHÂN</a>
                    <a href="${pageContext.request.contextPath}/logout">Đăng xuất</a>
                </div>
            </li>
        </c:if>
    </ul>
</nav>
