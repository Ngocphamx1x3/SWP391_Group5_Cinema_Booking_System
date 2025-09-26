<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!doctype html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
         <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/user/css/web.css">
        <link rel="icon" href="${pageContext.request.contextPath}/assets/user/img/logo.png" type="image/x-icon"/>
        <title>Chi tiết phim</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet"
              integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN" crossorigin="anonymous">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css"/>
        <link href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css" rel="stylesheet"/>
    </head>
    <body>
        <jsp:include page="/views/layout/Header.jsp"/>
        <div class="detail_movie_all container mt-4">
            <div class="row">
                <!-- Poster -->
                <div class="col-5">
                    <div class="item_movie_detail">
                        <img src="${pageContext.request.contextPath}/assets/admin/img/img/${movie.image}" alt="${movie.name}" width="400" height="600"/>
                    </div>
                </div>

                <!-- Thông tin chi tiết -->
                <div class="col-7">
                    <div class="text_movie_detail">
                        <h3>${movie.name}</h3>
                        <p>${movie.description}</p>

                        <dl class="movie-meta">
                            <dt>ĐẠO DIỄN:</dt>
                            <dd>
                                <c:forEach var="d" items="${movie.directors}" varStatus="st">
                                    ${d.name}<c:if test="${!st.last}">, </c:if>
                                </c:forEach>
                            </dd>

                            <dt>DIỄN VIÊN:</dt>
                            <dd>
                                <c:forEach var="p" items="${movie.performers}" varStatus="st">
                                    ${p.name}<c:if test="${!st.last}">, </c:if>
                                </c:forEach>
                            </dd>

                            <dt>THỂ LOẠI:</dt>
                            <dd>
                                <c:forEach var="t" items="${movie.movieTypes}" varStatus="st">
                                    ${t.name}<c:if test="${!st.last}">, </c:if>
                                </c:forEach>
                            </dd>

                            <dt>THỜI LƯỢNG PHIM:</dt>
                            <dd>${movie.movieDuration} phút</dd>

                            <dt>NGÔN NGỮ:</dt>
                            <dd>
                                <c:forEach var="l" items="${movie.languages}" varStatus="st">
                                    ${l.name}<c:if test="${!st.last}">, </c:if>
                                </c:forEach>
                            </dd>

                            <dt>NGÀY KHỞI CHIẾU:</dt>
                            <dd><fmt:formatDate value="${movie.premiereDate}" pattern="dd/MM/yyyy"/></dd>

                            <dt>NGÀY KẾT THÚC:</dt>
                            <dd><fmt:formatDate value="${movie.endDate}" pattern="dd/MM/yyyy"/></dd>

                            <dt>TRẠNG THÁI:</dt>
                            <dd>${movie.status}</dd>
                        </dl>
                    </div>
                </div>
            </div>

            <hr class="hr-movie">

            <!-- Trailer -->
            <div class="trailer_detail_movie mt-4">
                <iframe width="100%" height="600" src="${movie.trailer}"
                        title="YouTube video player" frameborder="0"
                        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                        allowfullscreen></iframe>
            </div>
        </div>

        <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.7.0/jquery.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/user/js/web.js"></script>

    </body>
</html>
