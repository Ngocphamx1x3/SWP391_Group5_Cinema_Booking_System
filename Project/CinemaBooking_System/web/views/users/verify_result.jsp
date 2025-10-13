<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Kết quả xác thực - CinemaBooking</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f5f5f5;
            margin: 0;
            padding: 20px;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }
        
        .result-container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            text-align: center;
            max-width: 500px;
            width: 100%;
        }
        
        .success {
            color: #28a745;
            border-left: 4px solid #28a745;
        }
        
        .error {
            color: #dc3545;
            border-left: 4px solid #dc3545;
        }
        
        .icon {
            font-size: 48px;
            margin-bottom: 20px;
        }
        
        h2 {
            margin-bottom: 15px;
        }
        
        .message {
            margin-bottom: 20px;
            line-height: 1.6;
        }
        
        .btn {
            display: inline-block;
            padding: 10px 20px;
            background-color: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            margin: 5px;
        }
        
        .btn-success {
            background-color: #28a745;
        }
        
        .btn-danger {
            background-color: #dc3545;
        }
        
        .auto-redirect {
            margin-top: 15px;
            font-size: 0.9em;
            color: #666;
        }
    </style>
    
    <c:if test="${autoRedirect}">
        <meta http-equiv="refresh" content="3;url=${redirectUrl}">
    </c:if>
</head>
<body>
    <div class="result-container ${success ? 'success' : 'error'}">
        <div class="icon">
            <c:choose>
                <c:when test="${success}">✅</c:when>
                <c:otherwise>❌</c:otherwise>
            </c:choose>
        </div>
        
        <h2>
            <c:choose>
                <c:when test="${success}">${message}</c:when>
                <c:otherwise>${error}</c:otherwise>
            </c:choose>
        </h2>
        
        <div class="message">
            <c:if test="${not empty subMessage}">
                <p>${subMessage}</p>
            </c:if>
            
            <c:if test="${not empty errorDetail}">
                <p><small>Chi tiết lỗi: ${errorDetail}</small></p>
            </c:if>
        </div>
        
        <div class="actions">
            <c:choose>
                <c:when test="${success}">
                    <a href="${redirectUrl}" class="btn btn-success">Đăng nhập ngay</a>
                    <c:if test="${autoRedirect}">
                        <div class="auto-redirect">
                            Tự động chuyển hướng sau <span id="countdown">3</span> giây...
                        </div>
                    </c:if>
                </c:when>
                <c:otherwise>
                    <a href="${retryUrl}" class="btn btn-danger">Thử lại</a>
                    <a href="${pageContext.request.contextPath}/" class="btn">Về trang chủ</a>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <c:if test="${autoRedirect}">
        <script>
            let seconds = 3;
            const countdownElement = document.getElementById('countdown');
            
            const countdown = setInterval(function() {
                seconds--;
                countdownElement.textContent = seconds;
                
                if (seconds <= 0) {
                    clearInterval(countdown);
                }
            }, 1000);
        </script>
    </c:if>
</body>
</html>