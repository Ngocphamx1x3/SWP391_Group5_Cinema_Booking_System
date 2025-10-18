<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - Movie Box</title>

    <!-- Provided CSS and JS links -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/user/css/web.css">
    <link rel="icon" href="${pageContext.request.contextPath}/assets/user/img/logo.png" type="image/x-icon"/>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.4/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/admin/css/mobiscroll.javascript.min.css">
    <script src="${pageContext.request.contextPath}/assets/admin/js/mobiscroll.javascript.min.js"></script>

    <!-- Custom CSS for Movie Box Theme -->
    <style>
        body {
            font-family: 'Arial', sans-serif;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
            color: #fff;
            margin: 0;
            padding: 0;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .register-container {
            max-width: 1200px;
            margin: 10px auto 10px auto;
            padding: 20px;
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .movie-box {
            background: rgba(0, 0, 0, 0.8);
            border: 2px solid #ff6b35;
            border-radius: 15px;
            padding: 40px;
            box-shadow: 0 10px 30px rgba(255, 107, 53, 0.3);
            text-align: center;
            max-width: 500px;
            width: 100%;
            position: relative;
            overflow: hidden;
        }

        .movie-box::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><pattern id="grain" width="100" height="100" patternUnits="userSpaceOnUse"><circle cx="25" cy="25" r="1" fill="white" opacity="0.1"/><circle cx="75" cy="75" r="1" fill="white" opacity="0.1"/><circle cx="50" cy="10" r="0.5" fill="white" opacity="0.05"/></pattern></defs><rect width="100" height="100" fill="url(%23grain)"/></svg>') repeat;
            animation: grain 0.2s steps(10) infinite;
            pointer-events: none;
        }

        @keyframes grain {
            0%, 100% {
                transform: translate(0, 0);
            }
            10% {
                transform: translate(-5%, -5%);
            }
            20% {
                transform: translate(-10%, 5%);
            }
            30% {
                transform: translate(5%, -10%);
            }
            40% {
                transform: translate(-5%, 10%);
            }
            50% {
                transform: translate(10%, -5%);
            }
            60% {
                transform: translate(-10%, 10%);
            }
            70% {
                transform: translate(5%, 5%);
            }
            80% {
                transform: translate(-5%, -10%);
            }
            90% {
                transform: translate(10%, 5%);
            }
        }

        .movie-box h1 {
            color: #ff6b35;
            margin-bottom: 20px;
            font-size: 2.5em;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.5);
        }

        .form-group {
            margin-bottom: 20px;
            text-align: left;
        }

        .form-group label {
            display: block;
            color: #ff6b35;
            font-weight: bold;
            margin-bottom: 5px;
        }

        .form-group input {
            width: 100%;
            padding: 12px;
            border: 1px solid #ff6b35;
            border-radius: 8px;
            background: rgba(255, 255, 255, 0.1);
            color: #fff;
            font-size: 16px;
            box-sizing: border-box;
        }

        .form-group input::placeholder {
            color: rgba(255, 255, 255, 0.7);
        }

        .form-group input:focus {
            outline: none;
            border-color: #fff;
            box-shadow: 0 0 10px rgba(255, 107, 53, 0.5);
        }

        button[type="submit"] {
            width: 100%;
            padding: 15px;
            background: linear-gradient(45deg, #ff6b35, #f7931e);
            color: #fff;
            border: none;
            border-radius: 8px;
            font-size: 18px;
            font-weight: bold;
            cursor: pointer;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        button[type="submit"]:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(255, 107, 53, 0.4);
        }

        .error {
            color: #ff4757;
            background: rgba(255, 71, 87, 0.1);
            border: 1px solid #ff4757;
            border-radius: 8px;
            padding: 10px;
            margin-bottom: 20px;
        }

        .success {
            color: #2ed573;
            background: rgba(46, 213, 115, 0.1);
            border: 1px solid #2ed573;
            border-radius: 8px;
            padding: 10px;
            margin-bottom: 20px;
        }

        .link-section {
            margin-top: 30px;
            text-align: center;
        }

        .link-section p {
            margin: 10px 0;
            font-size: 16px;
        }

        .link-section a {
            color: #ff6b35;
            text-decoration: none;
            font-weight: bold;
            transition: color 0.3s ease;
        }

        .link-section a:hover {
            color: #fff;
            text-decoration: underline;
        }

        .password-requirements {
            font-size: 0.8em;
            color: rgba(255, 255, 255, 0.7);
            margin: 5px 0 10px 0;
        }

        .verification-section {
            margin-top: 20px;
            padding: 15px;
            background-color: rgba(255, 107, 53, 0.1);
            border-radius: 8px;
            border-left: 4px solid #ff6b35;
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
            background: linear-gradient(45deg, #2ed573, #1e90ff) !important;
            padding: 10px 15px;
            margin-top: 10px;
        }
        
        .verification-note {
            font-size: 0.9em;
            color: rgba(255, 255, 255, 0.7);
            margin-top: 10px;
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .movie-box {
                padding: 20px;
                margin: 10px;
            }

            .movie-box h1 {
                font-size: 2em;
            }

            .verification-input {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>

    <jsp:include page="/views/layout/Header.jsp"/>

    <div class="register-container">
        <div class="movie-box">
            <h1>Movie Box Register</h1>

            <!-- Success Message -->
            <c:if test="${not empty successMessage}">
                <div class="success">${successMessage}</div>
                
                <!-- Form xác thực mã code (chỉ hiển thị khi đăng ký thành công) -->
                <div class="verification-section">
                    <h3 style="color: #ff6b35; margin-top: 0;">🔐 Xác thực tài khoản</h3>
                    <p>Vui lòng nhập mã xác thực 6 số đã được gửi đến email của bạn:</p>
                    
                    <form method="get" action="${pageContext.request.contextPath}/verify">
                        <div class="form-group">
                            <input type="email" name="email" value="${fn:escapeXml(param.email)}" placeholder="Email của bạn" required/>
                        </div>
                        <div class="form-group">
                            <input type="text" name="code" maxlength="6" placeholder="Mã xác thực (6 số)" required pattern="[0-9]{6}" title="Vui lòng nhập đúng 6 chữ số"/>
                        </div>
                        <div>
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
            
            <!-- Error Message -->
            <c:if test="${not empty error}">
                <div class="error">${error}</div>
            </c:if>

            <!-- Form đăng ký chính -->
            <form method="post" role="form" action="${pageContext.request.contextPath}/register" onsubmit="return validateForm()">
                <div class="form-group">
                    <label for="name">Họ và tên *</label>
                    <input type="text" name="name" id="name" placeholder="Họ và tên"
                           value="${fn:escapeXml(param.name)}" required/>
                </div>

                <div class="form-group">
                    <label for="username">Tên đăng nhập (username)</label>
                    <input type="text" name="username" id="username" placeholder="Tên đăng nhập (tùy chọn)"
                           value="${fn:escapeXml(param.username)}"/>
                </div>

                <div class="form-group">
                    <label for="email">E-mail *</label>
                    <input type="email" name="email" id="email" placeholder="E-mail"
                           value="${fn:escapeXml(param.email)}" required/>
                </div>

                <div class="form-group">
                    <label for="phoneNumber">Số điện thoại</label>
                    <input type="text" name="phoneNumber" id="phoneNumber" placeholder="Số điện thoại"
                           value="${fn:escapeXml(param.phoneNumber)}" pattern="0[0-9]{9}" title="Số điện thoại phải có 10 số và bắt đầu bằng 0"/>
                </div>

                <div class="form-group">
                    <label for="password">Mật khẩu *</label>
                    <input type="password" name="password" id="password" placeholder="Mật khẩu" required/>
                </div>

                <div class="form-group">
                    <label for="confirmPassword">Xác nhận mật khẩu *</label>
                    <input type="password" name="confirmPassword" id="confirmPassword" placeholder="Xác nhận mật khẩu" required/>
                    <div id="passwordMatch" style="color: #ff4757; font-size: 0.9em; margin-top: 2px;"></div>
                </div>

                <button type="submit">Đăng ký tài khoản</button>
            </form>
            
            <!-- Link Section -->
            <div class="link-section">
                <p>Nếu bạn đã có tài khoản, <a href="${pageContext.request.contextPath}/login">Đăng nhập</a></p>
            </div>
        </div>
    </div>

    <jsp:include page="/views/layout/Footer.jsp"/>

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