<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Forgot Password - Movie Box</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/user/css/web.css">
    <link rel="icon" href="${pageContext.request.contextPath}/assets/user/img/logo.png" type="image/x-icon"/>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.4/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/admin/css/mobiscroll.javascript.min.css">
    <script src="${pageContext.request.contextPath}/assets/admin/js/mobiscroll.javascript.min.js"></script>
    <style>
        body {
            background: #181818;
            color: #fff;
            font-family: 'Segoe UI', Arial, sans-serif;
            margin: 0;
            padding: 0;
        }
        .forgot-container {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .forgot-box {
            background: #232323;
            padding: 40px 30px 30px 30px;
            border-radius: 12px;
            box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
            width: 100%;
            max-width: 400px;
        }
        .forgot-box h1 {
            text-align: center;
            margin-bottom: 25px;
            font-size: 2em;
            color: #ff6b35;
        }
        .forgot-box .form-group {
            margin-bottom: 20px;
        }
        .forgot-box label {
            display: block;
            margin-bottom: 8px;
            color: #fff;
            font-weight: 500;
        }
        .forgot-box input[type="email"] {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid #444;
            border-radius: 6px;
            background: #181818;
            color: #fff;
            font-size: 1em;
            outline: none;
            transition: border 0.2s;
        }
        .forgot-box input[type="email"]:focus {
            border-color: #ff6b35;
        }
        .forgot-box button {
            width: 100%;
            padding: 12px;
            background: #ff6b35;
            color: #fff;
            border: none;
            border-radius: 6px;
            font-size: 1.1em;
            font-weight: bold;
            cursor: pointer;
            transition: background 0.2s;
        }
        .forgot-box button:hover {
            background: #ff914d;
        }
        .forgot-box .message {
            margin-bottom: 15px;
            padding: 10px;
            border-radius: 5px;
            background: #333;
            color: #ff6b35;
            text-align: center;
        }
        .forgot-box .back-link {
            display: block;
            text-align: center;
            margin-top: 18px;
            color: #ff6b35;
            text-decoration: none;
            font-weight: 500;
            transition: color 0.2s;
        }
        .forgot-box .back-link:hover {
            color: #fff;
            text-decoration: underline;
        }
        @media (max-width: 600px) {
            .forgot-box {
                padding: 25px 10px 20px 10px;
            }
        }
    </style>
</head>
<body>
    <jsp:include page="/views/layout/Header.jsp"/>

    <div class="forgot-container">
        <div class="forgot-box">
            <h1>Forgot Password</h1>
            <c:if test="${not empty message}">
                <div class="message">${message}</div>
            </c:if>
            <form action="${pageContext.request.contextPath}/forgot_password" method="post" autocomplete="off">
                <div class="form-group">
                    <label for="email">Enter your registered email address</label>
                    <input type="email" id="email" name="email" placeholder="example@email.com" required>
                </div>
                <button type="submit">Send Reset Code</button>
            </form>
            <a class="back-link" href="${pageContext.request.contextPath}/views/users/login.jsp">&larr; Back to Login</a>
        </div>
    </div>

    <jsp:include page="/views/layout/Footer.jsp"/>
</body>
</html>
