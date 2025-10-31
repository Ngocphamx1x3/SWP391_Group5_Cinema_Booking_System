<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<!DOCTYPE html>
<html class="no-js" lang="en">

    <head>
        <title>Phim chiếu</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/user/css/web.css">
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.4/jquery.min.js"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>
        <link rel="icon" href="${pageContext.request.contextPath}/assets/user/img/logo.png" type="image/x-icon"/>
    </head>

    <body>
        <jsp:include page="../layout/Header.jsp"/>

        <h2>FILMBOOKING</h2>
        <div class="warpper">
            <input class="radio" id="one" name="group" type="radio" checked>
            <input class="radio" id="two" name="group" type="radio">
            <input class="radio" id="three" name="group" type="radio">
            <div class="tabs">
                <label class="tab" id="one-tab" for="one">PHIM ĐANG CHIẾU</label>
                <label class="tab" id="two-tab" for="two">PHIM SẮP CHIẾU</label>
            </div>

            <div class="panels">
                <!-- Phim đang chiếu -->
                <div class="panel" id="one-panel">
                    <div class="khoi">
                        <c:forEach var="movie" items="${listmovie}">
                            <figure class="snip1208">
                                <img src="${pageContext.request.contextPath}/assets/admin/img/img/${movie.image}" 
                                     style="width:100%; height:459px;" />
                                <div class="date">
                                    <span class="day">${movie.ratedId}</span>
                                    <span class="month">Trailer</span>
                                </div>
                                <i class="myBtn" data-toggle="modal" data-target="#modal${movie.id}">Xem trailer</i>
                                <figcaption>
                                    <h3>
                                        <a href="${pageContext.request.contextPath}/filmbooking/movie/edit/${movie.id}">
                                            ${movie.name}
                                        </a>
                                    </h3>
                                    <p>
                                        - Thể loại:
                                        <c:forEach var="type" items="${movie.movieTypes}" varStatus="loop">
                                            ${type.name}<c:if test="${!loop.last}">, </c:if>
                                        </c:forEach>
                                        <br>
                                        - Thời lượng: ${movie.movieDuration} phút <br>
                                        - Ngày khởi chiếu: ${movie.premiereDate}
                                    </p>

                                    <c:choose>
                                        <c:when test="${empty customer}">
                                            <button data-toggle="modal" data-target="#myModalll">Đặt vé</button>
                                        </c:when>
                                        <c:otherwise>
                                            <button><a href="${pageContext.request.contextPath}/show/cinema?movieId=${movie.id}">Mua Vé</a></button>
                                        </c:otherwise>
                                    </c:choose>
                                </figcaption>
                            </figure>
                        </c:forEach>
                    </div>
                </div>

                <!-- Phim sắp chiếu -->
                <div class="panel" id="two-panel">
                    <div class="khoi">
                        <c:forEach var="movie1" items="${listmovie1}">
                            <figure class="snip1208">
                                <img src="${pageContext.request.contextPath}/assets/admin/assets/img/img/${movie1.image}"
                                     style="width: 100%; height: 459px"/>
                                <div class="date">
                                    <span class="day">${movie1.ratedId}</span>
                                    <span class="month">Trailer</span>
                                </div>
                                <i class="myBtnn" data-toggle="modal" data-target="#modalUpcoming${movie1.id}">Xem trailer</i>
                                <figcaption>
                                    <h3>
                                        <a href="${pageContext.request.contextPath}/filmbooking/movie/edit/${movie1.id}">
                                            ${movie1.name}
                                        </a>
                                    </h3>
                                    <p>
                                        - Thể loại:
                                        <c:forEach var="type" items="${movie1.movieTypes}" varStatus="loop">
                                            ${type.name}<c:if test="${!loop.last}">, </c:if>
                                        </c:forEach>
                                        <br>
                                        - Thời lượng: ${movie1.movieDuration} phút <br>
                                        - Ngày khởi chiếu: ${movie1.premiereDate}
                                    </p>
                                </figcaption>
                            </figure>
                        </c:forEach>
                    </div>
                </div>
            </div>
        </div>

        <!-- Trailer modal cho phim đang chiếu -->
        <c:forEach var="movie" items="${listmovie}">
            <div id="modal${movie.id}" class="modal">
                <div class="modal-content">
                    <span class="close" data-dismiss="modal">&times;</span>
                    <h2>TRAILER - ${movie.name}</h2>
                    <hr style="margin-top: 20px; opacity: 0.5">
                    <div class="embed-responsive embed-responsive-16by9 video">
                        <iframe width="80%" height="315" src="${movie.trailer}" frameborder="0"
                                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                                allowfullscreen
                                referrerpolicy="strict-origin-when-cross-origin"> 
                        </iframe>
                    </div>
                </div>
            </div>
        </c:forEach>

        <!-- Trailer modal cho phim sắp chiếu -->
        <c:forEach var="movie1" items="${listmovie1}">
            <div id="modalUpcoming${movie1.id}" class="modal">
                <div class="modal-content">
                    <span class="closee" data-dismiss="modal">&times;</span>
                    <h2>TRAILER - ${movie1.name}</h2>
                    <hr style="margin-top: 20px; opacity: 0.5">
                    <div class="embed-responsive embed-responsive-16by9 video">
                        <iframe width="80%" height="315" src="${movie1.trailer}" frameborder="0"
                                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                                allowfullscreen></iframe>
                    </div>
                </div>
            </div>
        </c:forEach>

        <!-- Modal khi chưa đăng nhập -->
        <div class="modal" id="myModalll">
            <div class="Mes">
                <h2 class="Modal-InText">Khách hàng cần đăng nhập khi đặt vé !!</h2>
                <button class="Modal-InBtn Btn-Right">
                    <a style="text-decoration: none; color: #000000" href="${pageContext.request.contextPath}/filmbooking/login">OK</a>
                </button>
                <button class="Modal-InBtn Btn-Left" data-dismiss="modal">HỦY</button>
            </div>
        </div>

        <jsp:include page="../layout/Footer.jsp"/>

    </body>
    <script src="https://unpkg.com/ionicons@5.4.0/dist/ionicons.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.14.0/js/all.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/user/js/web.js"></script>
</html>
