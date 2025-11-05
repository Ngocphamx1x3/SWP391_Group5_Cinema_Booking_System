<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<!DOCTYPE html>
<html lang="en">
    <head>
        <title>FILMBOOKING</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/user/css/web.css">
        <link rel="icon" href="${pageContext.request.contextPath}/assets/user/img/logo.png" type="image/x-icon"/>
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.4/jquery.min.js"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/admin/css/mobiscroll.javascript.min.css">
        <script src="${pageContext.request.contextPath}/assets/admin/js/mobiscroll.javascript.min.js"></script>
    </head>

    <body>
        <!-- Header -->
        <jsp:include page="/views/layout/Header.jsp"/>

        <!-- Banner/Slider -->
        <div class="slide-container">
            <div class="slide fade">
                <img src="${pageContext.request.contextPath}/assets/user/img/bannerphim1.jpg" style="width:100%;" alt="Slide 1">
            </div>
            <div class="slide fade">
                <img src="${pageContext.request.contextPath}/assets/user/img/bannerphim2.jpg" style="width:100%;" alt="Slide 2">
            </div>
            <div class="slide fade">
                <img src="${pageContext.request.contextPath}/assets/user/img/bannerphim3.jpg" style="width:100%;" alt="Slide 3">
            </div>
            <a class="prev" onclick="plusSlide(-1)">&#10094;</a>
            <a class="next" onclick="plusSlide(1)">&#10095;</a>
            <div class="dots">
                <span class="dot" onclick="currentSlide(1)"></span>
                <span class="dot" onclick="currentSlide(2)"></span>
                <span class="dot" onclick="currentSlide(3)"></span>
            </div>
        </div>

        <!-- Tabs phim -->
        <h2>FILMBOOKING</h2>
        <div class="warpper">
            <input class="radio" id="one" name="group" type="radio" checked>
            <input class="radio" id="two" name="group" type="radio">

            <div class="tabs">
                <label class="tab" id="one-tab" for="one">PHIM ĐANG CHIẾU</label>
                <label class="tab" id="two-tab" for="two">PHIM SẮP CHIẾU</label>
            </div>

            <div class="panels">
                <!-- PHIM ĐANG CHIẾU -->
                <div class="panel" id="one-panel">
                    <div class="khoi">
                        <c:forEach var="movie" items="${listmovie}">
                            <figure class="snip1208">
                                <!-- Thêm badge voucher nếu phim có voucher -->
                <c:if test="${movieVoucherStatus[movie.id]}">
                    <div class="voucher-badge">
                        <i class="fas fa-tag"></i> KHUYẾN MÃI
                    </div>
                </c:if>
                                <img src="${pageContext.request.contextPath}/assets/admin/img/img/${movie.image}"
                                     style="width: 100%; height: 459px">
                                <div class="date">
                                    <span class="day">${movie.ratedId} </span>
                                    <span class="month">Trailer</span>
                                </div>
                                <i class="myBtn" data-toggle="modal" data-target="#modal${movie.id}">Xem trailer</i>
                                <figcaption>
                                    <h3>
                                        <a href="${pageContext.request.contextPath}/detail?id=${movie.id}">
                                            ${movie.name}
                                        </a>
                                    </h3>
                                </figcaption>
                                <p>
                                    - Thể loại:
                                    <c:forEach var="type" items="${movie.movieTypes}" varStatus="loop">
                                        ${type.name}<c:if test="${!loop.last}">, </c:if>
                                    </c:forEach>
                                    <br>
                                    - Thời lượng: ${movie.movieDuration} phút <br>
                                    - Ngày khởi chiếu: ${movie.premiereDate} <br>
                                </p>
                                <c:if test="${empty customer}">
                                    <button data-toggle="modal" data-target="#myModalll">Đặt vé</button>
                                </c:if>
                                <c:if test="${not empty customer}">
                                    <button><a href="show/cinema?movieId=${movie.id}">Mua Vé</a></button>
                                </c:if>
                                </figcaption>
                            </figure>

                            <!-- Modal trailer phim đang chiếu -->
                            <div id="modal${movie.id}" class="modal">
                                <div class="modal-content">
                                    <span class="close" data-dismiss="modal">&times;</span>
                                    <h2>TRAILER - ${movie.name}</h2>
                                    <hr style="margin-top: 20px; opacity: 0.5">
                                    <div class="embed-responsive embed-responsive-16by9 video">
                                        <iframe width="80%" height="315" src="${movie.trailer}"
                                                title="YouTube video player" frameborder="0"
                                                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                                                allowfullscreen></iframe>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <!-- PHIM SẮP CHIẾU -->
                <div class="panel" id="two-panel">
                    <div class="khoi">
                        <c:forEach var="movie1" items="${listmovie1}">
                            <figure class="snip1208">
                                <img src="${pageContext.request.contextPath}/assets/admin/img/img/${movie1.image}"
                                     style="width: 100%; height: 459px">
                                <div class="date">
                                    <span class="day">${movie1.ratedId} </span>
                                    <span class="month">Trailer</span>
                                </div>
                                <i class="myBtnn" data-toggle="modal" data-target="#modalUpcoming${movie1.id}">Xem trailer</i>
                                <figcaption>
                                    <h3>
                                        <a href="detail?id=${movie1.id}">${movie1.name}</a>
                                    </h3>
                                    <p>
                                        - Thể loại:
                                        <c:forEach var="type" items="${movie1.movieTypes}" varStatus="loop">
                                            ${type.name}<c:if test="${!loop.last}">, </c:if>
                                        </c:forEach><br>
                                        - Thời lượng: ${movie1.movieDuration} phút<br>
                                        - Ngày khởi chiếu: ${movie1.premiereDate}
                                    </p>
                                </figcaption>
                            </figure>

                            <!-- Modal trailer phim sắp chiếu -->
                            <div id="modalUpcoming${movie1.id}" class="modal">
                                <div class="modal-content">
                                    <span class="closee" data-dismiss="modal">&times;</span>
                                    <h2>TRAILER - ${movie1.name}</h2>
                                    <hr style="margin-top: 20px; opacity: 0.5">
                                    <div class="embed-responsive embed-responsive-16by9 video">
                                        <iframe width="80%" height="315" src="${movie1.trailer}"
                                                title="YouTube video player" frameborder="0"
                                                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                                                allowfullscreen></iframe>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </div>
        </div>

        <!-- Modal khi chưa đăng nhập -->
        <div class="modal" id="myModalll">
            <div class="Mes ">
                <h2 class="Modal-InText">
                    Khách hàng cần đăng nhập khi đặt vé !!
                </h2>
                <button class="Modal-InBtn Btn-Right">
                    <a style="text-decoration: none; color: #000000" href="login">OK</a>
                </button>
                <button class="Modal-InBtn Btn-Left" data-dismiss="modal">HỦY</button>
            </div>
        </div>

        <!-- Khuyến mãi -->
        <section class="khuyenmai">
            <h3>KHUYẾN MÃI</h3>
            <div class="khoi1">
                <div class="card">
                    <div class="header">
                        <img src="${pageContext.request.contextPath}/assets/user/img/khuyenmai.jpg" alt="sample66"/>
                    </div>
                    <div class="info">
                        <span class="title">CHƯƠNG TRÌNH PHIM HÈ 2023 (Từ 26/5/2023 đến 30/6/2023) </span>
                    </div>
                </div>
                <!-- thêm các card khuyến mãi khác nếu cần -->
            </div>
        </section>

        <!-- Footer -->
        <jsp:include page="/views/layout/Footer.jsp"/>

        <!-- Scripts -->
        <script src="https://tudongchat.com/js/chatbox.js"></script>
        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script>
                    const tudong_chatbox = new TuDongChat("C1tWgbGRbc6iYpd-oBqPI");
                    tudong_chatbox.initial();
                    mobiscroll.setOptions({
                        locale: mobiscroll.localeEn,
                        theme: "ios",
                        themeVariant: "light",
                    });
        </script>
        <script src="https://unpkg.com/ionicons@5.4.0/dist/ionicons.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.14.0/js/all.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/user/js/web.js"></script>
        <script>
            // Kiểm tra nếu có avatar mới được cập nhật
document.addEventListener('DOMContentLoaded', function() {
    const avatarUpdated = sessionStorage.getItem('avatarUpdated');
    const newAvatarUrl = sessionStorage.getItem('newAvatarUrl');
    
    if (avatarUpdated === 'true' && newAvatarUrl) {
        // Cập nhật avatar trong navigation
        const avatarImg = document.querySelector('.user-avatar');
        if (avatarImg) {
            avatarImg.src = newAvatarUrl + '?t=' + new Date().getTime();
        }
        
        // Xóa thông tin từ session storage
        sessionStorage.removeItem('avatarUpdated');
        sessionStorage.removeItem('newAvatarUrl');
    }
});
        </script>
    </body>
</html>
