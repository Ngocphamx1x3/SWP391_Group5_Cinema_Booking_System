<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Login - Movie Box</title>

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

            .login-container {
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
                max-width: 400px;
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

            .login-images {
                display: flex;
                justify-content: space-around;
                margin-bottom: 30px;
                flex-wrap: wrap;
            }

            .login-images img {
                width: 60px;
                height: 60px;
                border-radius: 50%;
                border: 2px solid #ff6b35;
                box-shadow: 0 4px 8px rgba(255, 107, 53, 0.2);
                transition: transform 0.3s ease;
            }

            .login-images img:hover {
                transform: scale(1.1);
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

            /* Responsive Design */
            @media (max-width: 768px) {
                .movie-box {
                    padding: 20px;
                    margin: 10px;
                }

                .movie-box h1 {
                    font-size: 2em;
                }

                .login-images {
                    justify-content: center;
                }

                .login-images img {
                    width: 50px;
                    height: 50px;
                    margin: 0 10px;
                }
            }
        </style>
    </head>
    <body>

        <jsp:include page="/views/layout/Header.jsp"/>

        <div class="login-container">
            <div class="movie-box">
                <h1>Movie Box Login</h1>

                <!--             Images for login, register, and forgot password 
                            <div class="login-images">
                                <img src="${pageContext.request.contextPath}/assets/user/img/login-icon.png" alt="Login Icon" title="Secure Login">
                                <img src="${pageContext.request.contextPath}/assets/user/img/register-icon.png" alt="Register Icon" title="Create Account">
                                <img src="${pageContext.request.contextPath}/assets/user/img/forgot-password-icon.png" alt="Forgot Password Icon" title="Reset Password">
                            </div>-->

                <!-- Error Message -->
                <c:if test="${not empty error}">
                    <p class="error">${error}</p>
                </c:if>

                <!-- Login Form -->
                <form action="${pageContext.request.contextPath}/login" method="post">
                    <div class="form-group">
                        <label for="usernameOrEmail">Email or Username</label>
                        <input type="text" id="usernameOrEmail" name="usernameOrEmail" placeholder="Enter your email or username" required>
                    </div>

                    <div class="form-group">
                        <label for="password">Password</label>
                        <input type="password" id="password" name="password" placeholder="Enter your password" required>
                    </div>

                    <button type="submit">Login to Movie Box</button>
                </form>

                <!-- Link Section -->
                <div class="link-section">
                    <p>You don't have an account? <a href="${pageContext.request.contextPath}/register">Register</a></p>
                    <p>You forgot your <a href="${pageContext.request.contextPath}/views/users/forgot_password.jsp">password</a>?</p>
                </div>
            </div>
        </div>

        <jsp:include page="/views/layout/Footer.jsp"/>

    </body>
</html>