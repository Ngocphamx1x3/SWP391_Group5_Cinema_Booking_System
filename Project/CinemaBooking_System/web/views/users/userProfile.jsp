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
    <title>Hồ Sơ Người Dùng</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/user/css/profile.css">
    <style>
        .alert {
            padding: 10px;
            margin: 20px 0;
            border-radius: 5px;
            font-weight: bold;
            text-align: center;
        }

        .alert-success {
            background-color: #d4edda;
            color: #155724;
        }

        .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
        }

        .btn {
            font-weight: 500;
        }

        .btn-change-password {
            background-color: #6c757d;
            color: white;
            border: none;
            padding: 8px 20px;
            border-radius: 5px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s ease;
        }

        .btn-change-password:hover {
            background-color: #5a6268;
            color: white;
            text-decoration: none;
            transform: translateY(-1px);
            box-shadow: 0 2px 5px rgba(0,0,0,0.2);
        }

        .btn-change-password::before {
            content: "🔒";
            font-size: 16px;
        }

        .button-group {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }

        .upload-status {
            margin-top: 10px;
            font-size: 14px;
        }

        @media (max-width: 576px) {
            .button-group {
                flex-direction: column;
            }
            
            .btn-change-password {
                width: 100%;
                justify-content: center;
            }
        }
    </style>
</head>
<body>

<div class="container-xl px-4 mt-4">
    <!-- Hiển thị thông báo thành công nếu có -->
    <c:if test="${not empty message}">
        <div class="alert alert-success">${message}</div>
    </c:if>

    <div class="d-flex justify-content-between align-items-center mb-3">
        <a href="${pageContext.request.contextPath}/home" class="btn btn-outline-primary">
            ← Quay lại Trang chủ
        </a>
    </div>

    <hr class="mt-0 mb-4">

    <div class="row">
        <!-- Cột trái: Ảnh đại diện -->
        <div class="col-xl-4">
            <div class="card mb-4 mb-xl-0">
                <div class="card-header">Ảnh đại diện</div>
                <div class="card-body text-center">
                    <img class="img-account-profile rounded-circle mb-2"
                         src="<c:out value='${profile.avatarUrl != null ? profile.avatarUrl : "https://via.placeholder.com/150"}'/>"
                         alt="Ảnh đại diện" id="avatarPreview" style="width: 150px; height: 150px; object-fit: cover;">
                    <div class="small font-italic text-muted mb-4">JPG hoặc PNG không lớn hơn 5 MB</div>
                    
                    <!-- Form upload avatar với AJAX -->
                    <form id="avatarUploadForm" enctype="multipart/form-data">
                        <input type="file" name="avatarFile" id="avatarFile" accept="image/*" class="form-control mb-2" required>
                        <button class="btn btn-primary" type="submit">Tải ảnh lên</button>
                    </form>
                    <div id="uploadStatus" class="upload-status"></div>
                </div>
            </div>
        </div>

        <!-- Cột phải: Form thông tin -->
        <div class="col-xl-8">
            <div class="card mb-4">
                <div class="card-header">Chi tiết tài khoản</div>
                <div class="card-body">
                    <form action="${pageContext.request.contextPath}/editProfile" method="post" enctype="multipart/form-data">
                        <input type="hidden" name="userId" value="<%= user.getId() %>">

                        <div class="mb-3">
                            <label>Tên người dùng</label>
                            <input class="form-control" name="username" type="text" value="<%= user.getUsername() %>" required>
                        </div>

                        <div class="mb-3">
                            <label>Số điện thoại</label>
                            <input class="form-control" name="phone" type="tel" value="<%= user.getPhoneNumber() %>" required>
                        </div>

                        <div class="row gx-3 mb-3">
                            <div class="col-md-6">
                                <label>Họ và tên</label>
                                <input class="form-control" name="fullName" type="text"
                                       value="<%= profile != null ? profile.getFullName() : "" %>">
                            </div>
                            <div class="col-md-6">
                                <label>Giới tính</label>
                                <select class="form-control" name="gender">
                                    <option value="" <%= (profile == null || profile.getGender() == null) ? "selected" : "" %>>Chọn</option>
                                    <option value="Nam" <%= (profile != null && "Nam".equals(profile.getGender())) ? "selected" : "" %>>Nam</option>
                                    <option value="Nữ" <%= (profile != null && "Nữ".equals(profile.getGender())) ? "selected" : "" %>>Nữ</option>
                                    <option value="Khác" <%= (profile != null && "Khác".equals(profile.getGender())) ? "selected" : "" %>>Khác</option>
                                </select>
                            </div>
                        </div>

                        <div class="row gx-3 mb-3">
                            <div class="col-md-6">
                                <label>Ngày sinh</label>
                                <input class="form-control" name="birthday" type="date"
                                       value="<%= profile != null && profile.getBirthday() != null ? profile.getBirthday().toString() : "" %>">
                            </div>
                            <div class="col-md-6">
                                <label>Địa chỉ</label>
                                <input class="form-control" name="address" type="text"
                                       value="<%= profile != null ? profile.getAddress() : "" %>">
                            </div>
                        </div>

                        <div class="button-group">
                            <button class="btn btn-primary" type="submit">Lưu thay đổi</button>
                            <a href="${pageContext.request.contextPath}/changePassword" class="btn-change-password">
                                Đổi mật khẩu
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
document.getElementById('avatarUploadForm').addEventListener('submit', function(e) {
    e.preventDefault();
    
    const fileInput = document.getElementById('avatarFile');
    const statusDiv = document.getElementById('uploadStatus');
    const avatarPreview = document.getElementById('avatarPreview');
    
    if (!fileInput.files[0]) {
        showStatus('Vui lòng chọn ảnh để tải lên', 'error');
        return;
    }
    
    // Kiểm tra kích thước file (5MB)
    if (fileInput.files[0].size > 5 * 1024 * 1024) {
        showStatus('Kích thước ảnh không được vượt quá 5MB', 'error');
        return;
    }
    
    const formData = new FormData();
    formData.append('avatarFile', fileInput.files[0]);
    
    showStatus('Đang tải ảnh lên...', 'loading');
    
    // Gửi request AJAX
    const xhr = new XMLHttpRequest();
    xhr.open('POST', '${pageContext.request.contextPath}/uploadAvatar', true);
    
    xhr.onload = function() {
        if (xhr.status === 200) {
            try {
                const response = JSON.parse(xhr.responseText);
                if (response.success) {
                    showStatus('Tải ảnh lên thành công!', 'success');
                    // Cập nhật ảnh preview
                    avatarPreview.src = response.avatarUrl + '?t=' + new Date().getTime();
                    // Reset form
                    document.getElementById('avatarUploadForm').reset();
                } else {
                    showStatus(response.message || 'Có lỗi xảy ra', 'error');
                }
            } catch (e) {
                showStatus('Lỗi xử lý phản hồi từ server', 'error');
            }
        } else {
            showStatus('Lỗi kết nối server', 'error');
        }
    };
    
    xhr.onerror = function() {
        showStatus('Lỗi kết nối', 'error');
    };
    
    xhr.send(formData);
});

function showStatus(message, type) {
    const statusDiv = document.getElementById('uploadStatus');
    statusDiv.textContent = message;
    statusDiv.className = 'upload-status';
    
    switch(type) {
        case 'success':
            statusDiv.style.color = 'green';
            break;
        case 'error':
            statusDiv.style.color = 'red';
            break;
        case 'loading':
            statusDiv.style.color = 'blue';
            break;
        default:
            statusDiv.style.color = 'black';
    }
}
</script>

</body>
</html>