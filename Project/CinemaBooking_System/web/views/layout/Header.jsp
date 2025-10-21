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
        <li><a href="${pageContext.request.contextPath}/phim.jsp">PHIM CHIẾU</a></li>
        <li><a href="${pageContext.request.contextPath}/lichchieu.jsp">LỊCH CHIẾU</a></li>
        <li><a href="${pageContext.request.contextPath}/gia-ve.jsp">THÀNH VIÊN & GIÁ VÉ</a></li>

        <!-- Nếu chưa đăng nhập -->
        <c:if test="${empty sessionScope.account}">
            <li><a href="${pageContext.request.contextPath}/login">ĐĂNG NHẬP</a></li>
            <li><a href="${pageContext.request.contextPath}/register">ĐĂNG KÝ</a></li>
        </c:if>

        <!-- Nếu đã đăng nhập -->
        <c:if test="${not empty sessionScope.account}">
            <li class="dropdown">
                <a href="#" class="dropdown-toggle avatar-dropdown">
                    <img src="${sessionScope.avatarUrl != null ? sessionScope.avatarUrl : pageContext.request.contextPath.concat('/assets/user/img/default-avatar.png')}" 
                         alt="Avatar" class="user-avatar">
                </a>
                <div class="dropdown-content">
                    <a href="${pageContext.request.contextPath}/userProfile">👤 Thông tin cá nhân</a>
                    <a href="${pageContext.request.contextPath}/changePassword">🔒 Đổi mật khẩu</a>
                    <hr class="dropdown-divider">
                    <a href="${pageContext.request.contextPath}/logout" class="logout-btn">🚪 Đăng xuất</a>
                </div>
            </li>
        </c:if>
    </ul>
</nav>

<style>
.user-avatar {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    object-fit: cover;
    border: 2px solid #fff;
    transition: all 0.3s ease;
}

.avatar-dropdown {
    display: flex;
    align-items: center;
    padding: 5px 10px !important;
}

.avatar-dropdown:hover .user-avatar {
    border-color: #007bff;
    transform: scale(1.05);
}

.dropdown-content {
    display: none;
    position: absolute;
    right: 0;
    background-color: black;
    min-width: 200px;
    box-shadow: 0 8px 16px rgba(0,0,0,0.1);
    border-radius: 8px;
    z-index: 1000;
    padding: 8px 0;
}

.dropdown:hover .dropdown-content {
    display: block;
}

.dropdown-content a {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 10px 16px;
    text-decoration: none;
    color: #333;
    transition: background-color 0.3s;
}

.dropdown-content a:hover {
    background-color: #f8f9fa;
}

.dropdown-divider {
    margin: 5px 0;
    border: none;
    border-top: 1px solid #e9ecef;
}

.logout-btn {
    color: #dc3545 !important;
    font-weight: 500;
}
</style>