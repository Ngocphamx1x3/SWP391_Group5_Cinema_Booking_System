<%-- 
    Document   : userProfile
    Created on : Oct 13, 2025, 8:56:48 PM
    Author     : admin
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="model.UserProfile, model.Users" %>
<%
    Users user = (Users) session.getAttribute("account");
    UserProfile profile = (UserProfile) request.getAttribute("profile");
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Hồ Sơ Người Dùng</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/user/css/profile.css">

    </head>
    <body>
        <div class="container-xl px-4 mt-4">
            <c:if test="${not empty message}">
                <div class="alert alert-success text-center" role="alert" style="margin: 20px;">
                    ${message}
                </div>
            </c:if>

            <div class="d-flex justify-content-between align-items-center mb-3">
                <a href="${pageContext.request.contextPath}/home" 
                   class="btn btn-outline-primary" 
                   style="font-weight: 500; text-decoration: none;">
                    ← Quay lại Trang chủ
                </a>

            </div>

            <hr class="mt-0 mb-4">

            <div class="row">
                <div class="col-xl-4">
                    <div class="card mb-4 mb-xl-0">
                        <div class="card-header">Ảnh đại diện</div>
                        <div class="card-body text-center">
                            <img class="img-account-profile rounded-circle mb-2"
                                 src="<c:out value='${profile.avatarUrl != null ? profile.avatarUrl : "https://via.placeholder.com/150"}'/>"
                                 alt="Ảnh đại diện" id="avatarPreview">
                            <div class="small font-italic text-muted mb-4">JPG hoặc PNG không lớn hơn 5 MB</div>
                            <form action="${pageContext.request.contextPath}/uploadAvatar" method="post" enctype="multipart/form-data">


                                <input type="file" name="avatarFile" accept="image/*" class="form-control mb-2">
                                <button class="btn btn-primary" type="submit">Tải ảnh lên</button>
                            </form>
                        </div>
                    </div>
                </div>

                <div class="col-xl-8">
                    <div class="card mb-4">
                        <div class="card-header">Chi tiết tài khoản</div>
                        <div class="card-body">
                            <form action="${pageContext.request.contextPath}/editProfile" method="post" enctype="multipart/form-data">

                                <input type="hidden" name="userId" value="<%= user.getId() %>">

                                <div class="mb-3">
                                    <label class="small mb-1" for="inputUsername">Tên người dùng</label>
                                    <input class="form-control" id="inputUsername" name="username" type="text"
                                           value="<%= user.getUsername() %>" required>
                                </div>

                                <div class="mb-3">
                                    <label class="small mb-1" for="inputPhoneNumber">Số điện thoại</label>
                                    <input class="form-control" id="inputPhoneNumber" name="phone" type="tel"
                                           value="<%= user.getPhoneNumber() %>" required>
                                </div>

                                <div class="row gx-3 mb-3">
                                    <div class="col-md-6">
                                        <label class="small mb-1" for="inputFullName">Họ và tên</label>
                                        <input class="form-control" id="inputFullName" name="fullName" type="text"
                                               value="<%= profile != null ? profile.getFullName() : "" %>">
                                    </div>
                                    <div class="col-md-6">
                                        <label class="small mb-1" for="inputGender">Giới tính</label>
                                        <select class="form-control" id="inputGender" name="gender">
                                            <option value="" <%= (profile == null || profile.getGender() == null) ? "selected" : "" %>>Chọn</option>
                                            <option value="Nam" <%= (profile != null && "Nam".equals(profile.getGender())) ? "selected" : "" %>>Nam</option>
                                            <option value="Nữ" <%= (profile != null && "Nữ".equals(profile.getGender())) ? "selected" : "" %>>Nữ</option>
                                            <option value="Khác" <%= (profile != null && "Khác".equals(profile.getGender())) ? "selected" : "" %>>Khác</option>
                                        </select>
                                    </div>
                                </div>

                                <div class="row gx-3 mb-3">
                                    <div class="col-md-6">
                                        <label class="small mb-1" for="inputBirthday">Ngày sinh</label>
                                        <input class="form-control" id="inputBirthday" name="birthday" type="date"
                                               value="<%= profile != null && profile.getBirthday() != null ? profile.getBirthday().toString() : "" %>">
                                    </div>
                                    <div class="col-md-6">
                                        <label class="small mb-1" for="inputAddress">Địa chỉ</label>
                                        <input class="form-control" id="inputAddress" name="address" type="text"
                                               value="<%= profile != null ? profile.getAddress() : "" %>">
                                    </div>
                                </div>

                                <button class="btn btn-primary" type="submit">Lưu thay đổi</button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <script src="${pageContext.request.contextPath}/assets/user/js/alert-handler.js"></script>
    </body>
</html>

