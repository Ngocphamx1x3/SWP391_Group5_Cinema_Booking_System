<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <title>ĐĂNG KÝ FILMBOOKING</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/user/css/dangky.css">
    <link rel="icon" href="${pageContext.request.contextPath}/assets/user/img/logo.png" type="image/x-icon"/>

    <style>
        /* General styles */
        .text-danger { color: red; font-size: 0.9em; margin-top: 2px; }
        .alert-success { 
            color: green; 
            margin-bottom: 15px; 
            font-weight: bold; 
            text-align: center;
            background-color: #d4edda;
            border: 1px solid #c3e6cb;
            padding: 10px;
            border-radius: 4px;
        }
        .alert-error { 
            color: red; 
            margin-bottom: 15px; 
            font-weight: bold; 
            text-align: center;
            background-color: #f8d7da;
            border: 1px solid #f5c6cb;
            padding: 10px;
            border-radius: 4px;
        }

        /* Main container - smaller width for single column */
        #login-box {
            max-width: 500px; /* Thu hẹp lại cho layout 1 cột */
            margin: 0 auto;
            padding: 20px;
        }

        /* Input fields */
        input {
            width: 100%;
            padding: 10px;
            margin: 6px 0 12px 0;
            box-sizing: border-box;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        
        /* Register button */
        input[type="submit"] {
            cursor: pointer;
            padding: 12px 18px;
            background-color: orange;
            color: white;
            border: none;
            font-weight: bold;
            font-size: 1em;
        }

        /* Login prompt section */
        .login-prompt {
            text-align: center;
            margin-top: 25px;
            font-size: 1em;
            color: #555;
        }

        /* Login link style */
        .login-link {
            color: green;
            font-weight: bold;
            text-decoration: none; /* Bỏ gạch chân cho đẹp */
        }
        .login-link:hover {
            text-decoration: underline; /* Thêm lại gạch chân khi di chuột vào */
        }

        /* Verification section */
        .verification-section {
            margin-top: 20px;
            padding: 15px;
            background-color: #f8f9fa;
            border-radius: 5px;
            border-left: 4px solid #007bff;
        }
        
        .verification-input {
            display: flex;
            gap: 10px;
            margin-top: 10px;
        }
        
        .verification-input input {
            flex: 1;
        }
        
        .verification-btn {
            background-color: #28a745 !important;
            padding: 10px 15px;
        }
        
        .verification-note {
            font-size: 0.9em;
            color: #666;
            margin-top: 10px;
        }
        
        .password-requirements {
            font-size: 0.8em;
            color: #666;
            margin: 5px 0 10px 0;
        }

    </style>
</head>
<body>

<jsp:include page="/views/layout/Header.jsp"/>
<br>

<div id="login-box">
    <h1>ĐĂNG KÝ</h1>
    
    <c:if test="${not empty successMessage}">
        <div class="alert-success">${successMessage}</div>
        
        <!-- Form xác thực mã code (chỉ hiển thị khi đăng ký thành công) -->
        <div class="verification-section">
            <h3>🔐 Xác thực tài khoản</h3>
            <p>Vui lòng nhập mã xác thực 6 số đã được gửi đến email của bạn:</p>
            
            <form method="get" action="${pageContext.request.contextPath}/verify">
                <div class="verification-input">
                    <input type="email" name="email" value="${fn:escapeXml(param.email)}" placeholder="Email của bạn" required/>
                    <input type="text" name="code" maxlength="6" placeholder="Mã xác thực (6 số)" required pattern="[0-9]{6}" title="Vui lòng nhập đúng 6 chữ số"/>
                </div>
                <div style="margin-top:10px;">
                    <input type="submit" value="XÁC THỰC" class="verification-btn"/>
                </div>
            </form>
            
            <div class="verification-note">
                <p><strong>Lưu ý:</strong></p>
                <ul>
                    <li>Mã xác thực có hiệu lực trong 24 giờ</li>
                    <li>Kiểm tra hộp thư spam nếu không thấy email</li>
                    <li>Liên hệ quản trị viên nếu có vấn đề</li>
                </ul>
            </div>
        </div>
    </c:if>
    
    <c:if test="${not empty error}">
        <div class="alert-error">${error}</div>
    </c:if>

    <!-- Form đăng ký chính -->
    <form method="post" role="form" action="${pageContext.request.contextPath}/register" onsubmit="return validateForm()">
        <div>
            <label for="name">Họ và tên *</label><br/>
            <input type="text" name="name" id="name" placeholder="Họ và tên"
                   value="${fn:escapeXml(param.name)}" required/>
            <div class="password-requirements">(2-50 ký tự)</div>
        </div>

        <div>
            <label for="username">Tên đăng nhập (username)</label><br/>
            <input type="text" name="username" id="username" placeholder="Tên đăng nhập (tùy chọn)"
                   value="${fn:escapeXml(param.username)}"/>
            <div class="password-requirements">(4-15 ký tự, chỉ chữ, số và dấu gạch dưới)</div>
        </div>

        <div>
            <label for="email">E-mail *</label><br/>
            <input type="email" name="email" id="email" placeholder="E-mail"
                   value="${fn:escapeXml(param.email)}" required/>
        </div>

        <div>
            <label for="phoneNumber">Số điện thoại</label><br/>
            <input type="text" name="phoneNumber" id="phoneNumber" placeholder="Số điện thoại"
                   value="${fn:escapeXml(param.phoneNumber)}" pattern="0[0-9]{9}" title="Số điện thoại phải có 10 số và bắt đầu bằng 0"/>
            <div class="password-requirements">(10 số, bắt đầu bằng 0)</div>
        </div>

        <div>
            <label for="password">Mật khẩu *</label><br/>
            <input type="password" name="password" id="password" placeholder="Mật khẩu" required/>
            <div class="password-requirements">(8-12 ký tự, bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt)</div>
        </div>

        <div>
            <label for="confirmPassword">Xác nhận mật khẩu *</label><br/>
            <input type="password" name="confirmPassword" id="confirmPassword" placeholder="Xác nhận mật khẩu" required/>
            <div id="passwordMatch" class="text-danger"></div>
        </div>

        <div style="margin-top:10px;">
            <input type="submit" value="ĐĂNG KÝ"/>
        </div>
    </form>
    
    <div class="login-prompt">
        Nếu bạn đã có tài khoản, ấn vào đây để 
        <a href="${pageContext.request.contextPath}/login" class="login-link">Đăng nhập</a>
    </div>
</div>

<br>
<jsp:include page="/views/layout/Footer.jsp"/>

<script src="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.14.0/js/all.min.js"></script>
<script>
    function validateForm() {
        const password = document.getElementById('password').value;
        const confirmPassword = document.getElementById('confirmPassword').value;
        const passwordMatch = document.getElementById('passwordMatch');
        
        if (password !== confirmPassword) {
            passwordMatch.textContent = 'Mật khẩu xác nhận không khớp';
            return false;
        } else {
            passwordMatch.textContent = '';
        }
        return true;
    }

    // Real-time password match validation
    document.getElementById('confirmPassword').addEventListener('input', function() {
        const password = document.getElementById('password').value;
        const confirmPassword = this.value;
        const passwordMatch = document.getElementById('passwordMatch');
        
        if (confirmPassword && password !== confirmPassword) {
            passwordMatch.textContent = 'Mật khẩu xác nhận không khớp';
        } else {
            passwordMatch.textContent = '';
        }
    });
</script>
</body>
</html>