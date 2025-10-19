<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đổi Email - Movie Box</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #0f0c29 0%, #302b63 50%, #24243e 100%);
            color: #fff;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            position: relative;
            overflow-x: hidden;
        }

        body::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: 
                radial-gradient(circle at 20% 50%, rgba(23, 162, 184, 0.1) 0%, transparent 50%),
                radial-gradient(circle at 80% 80%, rgba(23, 162, 184, 0.15) 0%, transparent 50%);
            pointer-events: none;
            z-index: 0;
        }

        .change-email-container {
            max-width: 1200px;
            margin: 20px auto;
            padding: 20px;
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
            z-index: 1;
        }

        .movie-box {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(23, 162, 184, 0.3);
            border-radius: 20px;
            padding: 50px 40px;
            box-shadow: 
                0 8px 32px 0 rgba(23, 162, 184, 0.2),
                inset 0 1px 0 0 rgba(255, 255, 255, 0.1);
            text-align: center;
            max-width: 550px;
            width: 100%;
            position: relative;
            animation: fadeInUp 0.6s ease-out;
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .movie-box::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, #17a2b8, #20c997, #17a2b8);
            background-size: 200% 100%;
            animation: gradientShift 3s ease infinite;
            border-radius: 20px 20px 0 0;
        }

        @keyframes gradientShift {
            0%, 100% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
        }

        .movie-box h1 {
            color: #17a2b8;
            margin-bottom: 30px;
            font-size: 2.2em;
            font-weight: 700;
            text-shadow: 0 0 20px rgba(23, 162, 184, 0.5);
            letter-spacing: 1px;
        }

        .form-group {
            margin-bottom: 25px;
            text-align: left;
        }

        .form-group label {
            display: block;
            color: #17a2b8;
            font-weight: 600;
            margin-bottom: 8px;
            font-size: 0.95em;
            letter-spacing: 0.5px;
        }

        .form-group input {
            width: 100%;
            padding: 14px 16px;
            border: 1px solid rgba(23, 162, 184, 0.4);
            border-radius: 12px;
            background: rgba(255, 255, 255, 0.08);
            color: #fff;
            font-size: 15px;
            transition: all 0.3s ease;
        }

        .form-group input::placeholder {
            color: rgba(255, 255, 255, 0.5);
        }

        .form-group input:focus {
            outline: none;
            border-color: #17a2b8;
            background: rgba(255, 255, 255, 0.12);
            box-shadow: 0 0 0 4px rgba(23, 162, 184, 0.1);
            transform: translateY(-2px);
        }

        .form-group small {
            display: block;
            margin-top: 6px;
            color: rgba(255, 255, 255, 0.6);
            font-size: 0.85em;
        }

        button {
            padding: 14px 32px;
            background: linear-gradient(135deg, #17a2b8, #138496);
            color: #fff;
            border: none;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            margin: 8px 5px;
            box-shadow: 0 4px 15px rgba(23, 162, 184, 0.3);
            position: relative;
            overflow: hidden;
        }

        button::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.2);
            transform: translate(-50%, -50%);
            transition: width 0.6s, height 0.6s;
        }

        button:hover::before {
            width: 300px;
            height: 300px;
        }

        button:hover {
            transform: translateY(-3px);
            box-shadow: 0 6px 20px rgba(23, 162, 184, 0.4);
        }

        button:active {
            transform: translateY(-1px);
        }

        button:disabled {
            background: linear-gradient(135deg, #6c757d, #5a6268);
            cursor: not-allowed;
            transform: none;
            box-shadow: none;
            opacity: 0.7;
        }

        .error {
            color: #ff6b6b;
            background: rgba(255, 107, 107, 0.15);
            border: 1px solid rgba(255, 107, 107, 0.4);
            border-left: 4px solid #ff6b6b;
            border-radius: 10px;
            padding: 15px 18px;
            margin-bottom: 25px;
            animation: shake 0.5s ease;
        }

        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25% { transform: translateX(-10px); }
            75% { transform: translateX(10px); }
        }

        .success {
            color: #51cf66;
            background: rgba(81, 207, 102, 0.15);
            border: 1px solid rgba(81, 207, 102, 0.4);
            border-left: 4px solid #51cf66;
            border-radius: 10px;
            padding: 15px 18px;
            margin-bottom: 25px;
            animation: slideIn 0.5s ease;
        }

        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateX(-20px);
            }
            to {
                opacity: 1;
                transform: translateX(0);
            }
        }

        .verification-section {
            margin-top: 25px;
            padding: 25px;
            background: rgba(23, 162, 184, 0.08);
            border-radius: 15px;
            border-left: 4px solid #17a2b8;
            animation: fadeIn 0.6s ease;
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        .verification-section h3 {
            color: #17a2b8;
            margin-top: 0;
            margin-bottom: 15px;
            font-size: 1.4em;
        }

        .verification-section p {
            margin-bottom: 20px;
            line-height: 1.6;
        }

        .verification-section ul {
            text-align: left;
            padding-left: 25px;
            line-height: 1.8;
        }

        .verification-section ul li {
            margin-bottom: 8px;
        }

        .back-link {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            margin-top: 20px;
            padding: 12px 24px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(23, 162, 184, 0.3);
            border-radius: 12px;
            color: #17a2b8;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
            backdrop-filter: blur(5px);
        }

        .back-link:hover {
            background: rgba(23, 162, 184, 0.15);
            border-color: #17a2b8;
            transform: translateX(-5px);
            box-shadow: 0 4px 15px rgba(23, 162, 184, 0.2);
        }

        .back-link::before {
            content: '←';
            font-size: 1.2em;
            transition: transform 0.3s ease;
        }

        .back-link:hover::before {
            transform: translateX(-3px);
        }

        .countdown {
            color: #ffa94d;
            font-weight: 700;
        }

        @media (max-width: 768px) {
            .movie-box {
                padding: 30px 20px;
                margin: 10px;
            }

            .movie-box h1 {
                font-size: 1.8em;
            }

            button {
                padding: 12px 24px;
                font-size: 15px;
            }

            .verification-section {
                padding: 20px 15px;
            }
        }

        @media (max-width: 480px) {
            .movie-box h1 {
                font-size: 1.5em;
            }

            .form-group input {
                padding: 12px 14px;
            }
        }
    </style>
</head>
<body>

    <div class="change-email-container">
        <div class="movie-box">
            <h1>🔐 Đổi Email</h1>

            <!-- Error Message -->
            <c:if test="${not empty error}">
                <div class="error">${error}</div>
            </c:if>

            <!-- Success Message -->
            <c:if test="${not empty successMessage}">
                <div class="success">${successMessage}</div>
            </c:if>

            <!-- Form nhập email mới -->
            <c:if test="${empty verificationSent}">
                <form method="post" action="${pageContext.request.contextPath}/changeEmail" id="emailForm">
                    <div class="form-group">
                        <label for="newEmail">Email mới *</label>
                        <input type="email" name="newEmail" id="newEmail" 
                               placeholder="Nhập email mới của bạn" 
                               value="${fn:escapeXml(param.newEmail)}" required/>
                        <small>Chúng tôi sẽ gửi mã xác thực đến email này</small>
                    </div>

                    <div class="form-group">
                        <label for="password">Mật khẩu hiện tại *</label>
                        <input type="password" name="password" id="password" 
                               placeholder="Nhập mật khẩu hiện tại" required/>
                    </div>

                    <button type="submit" id="sendCodeBtn">Gửi mã xác thực</button>
                    
                    <a href="${pageContext.request.contextPath}/userProfile" class="back-link">
                        Quay lại hồ sơ
                    </a>
                </form>
            </c:if>

            <!-- Form xác thực mã code -->
            <c:if test="${not empty verificationSent}">
                <div class="verification-section">
                    <h3>📧 Xác thực Email mới</h3>
                    <p>Chúng tôi đã gửi mã xác thực 6 số đến: <strong>${fn:escapeXml(newEmail)}</strong></p>
                    
                    <form method="post" action="${pageContext.request.contextPath}/verifyEmailChange">
                        <input type="hidden" name="newEmail" value="${fn:escapeXml(newEmail)}">
                        
                        <div class="form-group">
                            <label for="verificationCode">Mã xác thực *</label>
                            <input type="text" name="verificationCode" id="verificationCode" 
                                   maxlength="6" placeholder="Nhập mã 6 số" 
                                   required pattern="[0-9]{6}" 
                                   title="Vui lòng nhập đúng 6 chữ số"/>
                        </div>

                        <button type="submit" id="verifyBtn">Xác thực và Đổi Email</button>
                        
                        <div style="margin-top: 15px;">
                            <button type="button" onclick="resendCode()" id="resendBtn" disabled>
                                Gửi lại mã (<span id="countdown">60</span>s)
                            </button>
                        </div>
                    </form>
                    
                    <div style="margin-top: 20px; font-size: 0.9em; color: rgba(255,255,255,0.7);">
                        <p><strong>Lưu ý:</strong></p>
                        <ul>
                            <li>Mã xác thực có hiệu lực trong 24 giờ</li>
                            <li>Kiểm tra hộp thư spam nếu không thấy email</li>
                            <li>Email sẽ được thay đổi sau khi xác thực thành công</li>
                        </ul>
                    </div>
                </div>
            </c:if>
        </div>
    </div>

    <script>
        // Countdown cho nút gửi lại mã
        function startCountdown() {
            let seconds = 60;
            const countdownElement = document.getElementById('countdown');
            const resendBtn = document.getElementById('resendBtn');
            
            const countdown = setInterval(function() {
                seconds--;
                countdownElement.textContent = seconds;
                
                if (seconds <= 0) {
                    clearInterval(countdown);
                    resendBtn.disabled = false;
                    resendBtn.textContent = 'Gửi lại mã';
                    countdownElement.textContent = '';
                }
            }, 1000);
        }

        function resendCode() {
            const form = document.getElementById('emailForm');
            const formData = new FormData(form);
            
            fetch('${pageContext.request.contextPath}/changeEmail', {
                method: 'POST',
                body: formData
            }).then(response => {
                if (response.ok) {
                    alert('Mã xác thực đã được gửi lại!');
                    startCountdown();
                } else {
                    alert('Có lỗi xảy ra khi gửi lại mã!');
                }
            });
        }

        // Validate email form
        document.getElementById('emailForm')?.addEventListener('submit', function(e) {
            const email = document.getElementById('newEmail').value;
            const currentEmail = '<%= session.getAttribute("account") != null ? ((model.Users)session.getAttribute("account")).getEmail() : "" %>';
            
            if (email === currentEmail) {
                e.preventDefault();
                alert('Email mới phải khác email hiện tại!');
                return false;
            }
            
            const btn = document.getElementById('sendCodeBtn');
            btn.disabled = true;
            btn.textContent = 'Đang gửi...';
        });

        // Validate verification code form
        document.getElementById('verificationCode')?.addEventListener('input', function(e) {
            this.value = this.value.replace(/[^0-9]/g, '');
        });

        // Hiển thị loading khi submit form xác thực
        document.getElementById('verifyForm')?.addEventListener('submit', function(e) {
            const btn = document.getElementById('verifyBtn');
            btn.disabled = true;
            btn.textContent = 'Đang xác thực...';
        });

        // Bắt đầu countdown khi trang load
        window.addEventListener('load', function() {
            if (document.getElementById('countdown')) {
                startCountdown();
            }
        });
    </script>
</body>
</html>