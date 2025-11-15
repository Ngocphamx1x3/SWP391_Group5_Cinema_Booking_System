<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="model.UserProfile, model.Users" %>
<%
    Users user = (Users) session.getAttribute("account");
    UserProfile profile = (UserProfile) request.getAttribute("profile");
    
    // Lấy thông báo từ session
    String successMessage = (String) session.getAttribute("successMessage");
    String errorMessage = (String) session.getAttribute("errorMessage");
    
    // Xóa thông báo sau khi đã lấy
    session.removeAttribute("successMessage");
    session.removeAttribute("errorMessage");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Hồ Sơ Người Dùng</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/user/css/profile.css">
    <style>
        /* Các style giữ nguyên */
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
            border: 1px solid #c3e6cb;
        }

        .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
            white-space: pre-line;
        }

        .error-message {
            color: #dc3545;
            font-size: 14px;
            margin-top: 5px;
            display: none;
        }

        .is-invalid {
            border-color: #dc3545 !important;
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

        .btn-change-email {
            background-color: #17a2b8;
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

        .btn-change-email:hover {
            background-color: #138496;
            color: white;
            text-decoration: none;
            transform: translateY(-1px);
            box-shadow: 0 2px 5px rgba(0,0,0,0.2);
        }

        .btn-change-password::before {
            content: "";
            font-size: 16px;
        }

        .btn-change-email::before {
            content: "";
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
            
            .btn-change-password,
            .btn-change-email {
                width: 100%;
                justify-content: center;
            }
        }
    </style>
</head>
<body>

<div class="container-xl px-4 mt-4">
    <!-- Hiển thị thông báo -->
    <% if (successMessage != null) { %>
        <div class="alert alert-success"><%= successMessage %></div>
    <% } %>
    
    <% if (errorMessage != null) { %>
        <div class="alert alert-danger"><%= errorMessage %></div>
    <% } %>

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
                    <form id="profileForm" action="${pageContext.request.contextPath}/editProfile" method="post" enctype="multipart/form-data">
                        <input type="hidden" name="userId" value="<%= user.getId() %>">

                        <div class="mb-3">
                            <label>Email hiện tại</label>
                            <input class="form-control" type="email" value="<%= user.getEmail() %>" readonly disabled>
                            <small class="text-muted">Để thay đổi email, vui lòng sử dụng nút "Đổi Email" bên dưới</small>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Tên người dùng <span class="text-danger">*</span></label>
                            <input class="form-control" name="username" type="text" 
                                   value="<%= user.getUsername() %>" 
                                   pattern="^[a-zA-Z0-9_]{4,15}$"
                                   title="Username phải từ 4-15 ký tự, chỉ chứa chữ cái, số và dấu gạch dưới"
                                   required>
                            <div class="error-message" id="usernameError"></div>
                            <small class="text-muted">Username phải từ 4-15 ký tự, chỉ chứa chữ cái, số và dấu gạch dưới (_)</small>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Số điện thoại</label> <!-- Đã bỏ dấu * -->
                            <input class="form-control" name="phone" type="tel" 
                                   value="<%= user.getPhoneNumber() %>"
                                   pattern="^$|^0[0-9]{9}$" <!-- Cho phép chuỗi rỗng hoặc số điện thoại hợp lệ -->
                                   
                            <div class="error-message" id="phoneError"></div>
                            <small class="text-muted">Số điện thoại phải có 10 số và bắt đầu bằng số 0, hoặc để trống</small>
                        </div>

                        <div class="row gx-3 mb-3">
                            <div class="col-md-6">
                                <label class="form-label">Họ và tên</label>
                                <input class="form-control" name="fullName" type="text"
                                       value="<%= profile != null ? profile.getFullName() : "" %>"
                                       pattern="^[\p{L} ]{2,50}$"
                                       title="Họ và tên phải từ 2-50 ký tự">
                                <div class="error-message" id="fullNameError"></div>
                                <small class="text-muted">Họ và tên phải từ 2-50 ký tự</small>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Giới tính</label>
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
                                <label class="form-label">Ngày sinh</label>
                                <input class="form-control" name="birthday" type="date"
                                       value="<%= profile != null && profile.getBirthday() != null ? profile.getBirthday().toString() : "" %>">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Địa chỉ</label>
                                <input class="form-control" name="address" type="text"
                                       value="<%= profile != null ? profile.getAddress() : "" %>">
                            </div>
                        </div>

                        <div class="button-group">
                            <button class="btn btn-primary" type="submit" id="submitBtn">Lưu thay đổi</button>
                            <a href="${pageContext.request.contextPath}/changePassword" class="btn-change-password">
                                Đổi mật khẩu
                            </a>
                            <a href="${pageContext.request.contextPath}/changeEmail" class="btn-change-email">
                                Đổi Email
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
// Validation patterns
const USERNAME_REGEX = /^[a-zA-Z0-9_]{4,15}$/;
const PHONE_REGEX = /^$|^0[0-9]{9}$/; // Cho phép chuỗi rỗng hoặc số điện thoại hợp lệ
const FULLNAME_REGEX = /^[\p{L} ]{2,50}$/u;

// Form elements
const form = document.getElementById('profileForm');
const usernameInput = form.querySelector('input[name="username"]');
const phoneInput = form.querySelector('input[name="phone"]');
const fullNameInput = form.querySelector('input[name="fullName"]');
const submitBtn = document.getElementById('submitBtn');

// Error elements
const usernameError = document.getElementById('usernameError');
const phoneError = document.getElementById('phoneError');
const fullNameError = document.getElementById('fullNameError');

// Real-time validation
usernameInput.addEventListener('input', validateUsername);
phoneInput.addEventListener('input', validatePhone);
fullNameInput.addEventListener('input', validateFullName);

form.addEventListener('submit', function(e) {
    const isUsernameValid = validateUsername();
    const isPhoneValid = validatePhone();
    const isFullNameValid = validateFullName();
    
    if (!isUsernameValid || !isPhoneValid || !isFullNameValid) {
        e.preventDefault();
        showAlert('Vui lòng kiểm tra lại thông tin đã nhập', 'error');
    }
});

function validateUsername() {
    const value = usernameInput.value.trim();
    
    if (!value) {
        showError(usernameInput, usernameError, 'Username không được để trống');
        return false;
    }
    
    if (!USERNAME_REGEX.test(value)) {
        showError(usernameInput, usernameError, 'Username phải từ 4-15 ký tự, chỉ chứa chữ cái, số và dấu gạch dưới (_), không chứa khoảng trắng');
        return false;
    }
    
    hideError(usernameInput, usernameError);
    return true;
}

function validatePhone() {
    const value = phoneInput.value.trim();
    
    // Số điện thoại có thể để trống, nhưng nếu có thì phải đúng định dạng
    if (value && !PHONE_REGEX.test(value)) {
        showError(phoneInput, phoneError, 'Số điện thoại phải có 10 số và bắt đầu bằng số 0, hoặc để trống');
        return false;
    }
    
    hideError(phoneInput, phoneError);
    return true;
}

function validateFullName() {
    const value = fullNameInput.value.trim();
    
    // FullName là optional, nhưng nếu có giá trị thì phải validate
    if (value && !FULLNAME_REGEX.test(value)) {
        showError(fullNameInput, fullNameError, 'Họ và tên phải từ 2-50 ký tự');
        return false;
    }
    
    hideError(fullNameInput, fullNameError);
    return true;
}

function showError(input, errorElement, message) {
    input.classList.add('is-invalid');
    errorElement.textContent = message;
    errorElement.style.display = 'block';
}

function hideError(input, errorElement) {
    input.classList.remove('is-invalid');
    errorElement.style.display = 'none';
}

function showAlert(message, type) {
    // Tạo alert element nếu chưa có
    let alertDiv = document.querySelector('.alert-custom');
    if (!alertDiv) {
        alertDiv = document.createElement('div');
        alertDiv.className = 'alert alert-custom';
        form.parentNode.insertBefore(alertDiv, form);
    }
    
    alertDiv.textContent = message;
    alertDiv.className = `alert alert-custom alert-${type}`;
    alertDiv.style.display = 'block';
    
    // Tự động ẩn sau 5 giây
    setTimeout(() => {
        alertDiv.style.display = 'none';
    }, 5000);
}

// Avatar upload code (giữ nguyên từ code cũ)
document.getElementById('avatarUploadForm').addEventListener('submit', function(e) {
    e.preventDefault();
    
    const fileInput = document.getElementById('avatarFile');
    const statusDiv = document.getElementById('uploadStatus');
    const avatarPreview = document.getElementById('avatarPreview');
    
    if (!fileInput.files[0]) {
        showStatus('Vui lòng chọn ảnh để tải lên', 'error');
        return;
    }
    
    if (fileInput.files[0].size > 5 * 1024 * 1024) {
        showStatus('Kích thước ảnh không được vượt quá 5MB', 'error');
        return;
    }
    
    const formData = new FormData();
    formData.append('avatarFile', fileInput.files[0]);
    
    showStatus('Đang tải ảnh lên...', 'loading');
    
    const xhr = new XMLHttpRequest();
    xhr.open('POST', '${pageContext.request.contextPath}/uploadAvatar', true);
    
    xhr.onload = function() {
        if (xhr.status === 200) {
            try {
                const response = JSON.parse(xhr.responseText);
                if (response.success) {
                    showStatus('Tải ảnh lên thành công!', 'success');
                    avatarPreview.src = response.avatarUrl + '?t=' + new Date().getTime();
                    document.getElementById('avatarUploadForm').reset();
                    
                    sessionStorage.setItem('avatarUpdated', 'true');
                    sessionStorage.setItem('newAvatarUrl', response.avatarUrl);
                    
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