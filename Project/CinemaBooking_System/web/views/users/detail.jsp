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
        <title>${movie.name} - FILMBOOKING</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet"
              integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN" crossorigin="anonymous">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css"/>
        <link href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css" rel="stylesheet"/>
        <style>
            /* Schedule Section Styles */
            .schedule-section {
                background: #f8f9fa;
                border-radius: 15px;
                padding: 30px;
                margin-top: 40px;
            }

            .schedule-header h3 {
                color: #e71a0f;
                font-weight: bold;
                font-size: 28px;
            }

            /* Date Selector Styles */
            .date-selector-container {
                background: white;
                border-radius: 10px;
                padding: 20px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                margin-bottom: 20px;
            }

            .date-scroll-wrapper {
                overflow-x: auto;
                padding: 10px 0;
            }

            .date-list {
                display: flex;
                gap: 15px;
                min-width: max-content;
            }

            .date-item {
                flex: 0 0 auto;
                width: 80px;
                height: 90px;
                border: 2px solid #e0e0e0;
                border-radius: 10px;
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                cursor: pointer;
                transition: all 0.3s ease;
                background: white;
                text-align: center;
            }

            .date-item:hover {
                border-color: #e71a0f;
                transform: translateY(-2px);
            }

            .date-item.active {
                border-color: #e71a0f;
                background: #e71a0f;
                color: white;
            }

            .date-day {
                font-size: 24px;
                font-weight: bold;
                margin-bottom: 2px;
            }

            .date-month {
                font-size: 14px;
                margin-bottom: 5px;
            }

            .date-weekday {
                font-size: 12px;
                text-transform: capitalize;
            }

            /* Cinema Schedule Styles */
            .cinema-schedule-container {
                min-height: 200px;
                background: white;
                border-radius: 10px;
                padding: 20px;
            }

            .cinema-item {
                border-bottom: 1px solid #eee;
                padding: 20px 0;
            }

            .cinema-item:last-child {
                border-bottom: none;
            }

            .cinema-name {
                font-weight: bold;
                color: #333;
                font-size: 18px;
                margin-bottom: 5px;
            }

            .cinema-address {
                color: #666;
                font-size: 14px;
                margin-bottom: 15px;
            }

            .showtime-list {
                display: flex;
                flex-wrap: wrap;
                gap: 10px;
            }

            .showtime-item {
                background: #f8f9fa;
                border: 1px solid #ddd;
                border-radius: 5px;
                padding: 8px 15px;
                cursor: pointer;
                transition: all 0.3s ease;
                text-decoration: none;
                color: #333;
                display: inline-block;
            }

            .showtime-item:hover {
                background: #e71a0f;
                color: white;
                border-color: #e71a0f;
                text-decoration: none;
            }

            .showtime-time {
                font-weight: bold;
            }

            .showtime-price {
                font-size: 12px;
                color: #666;
            }

            .showtime-item:hover .showtime-price {
                color: white;
            }

            .no-schedule {
                text-align: center;
                padding: 40px;
                color: #666;
            }

            .hr-movie {
                margin: 40px 0;
                border: 0;
                border-top: 2px solid #eee;
            }

            .movie-meta dt {
                font-weight: bold;
                color: #333;
                margin-top: 10px;
            }

            .movie-meta dd {
                margin-left: 0;
                color: #666;
            }

            .book-now-btn {
                background: #e71a0f;
                color: white;
                border: none;
                padding: 12px 30px;
                border-radius: 25px;
                font-weight: bold;
                font-size: 16px;
                transition: all 0.3s ease;
                text-decoration: none;
                display: inline-block;
            }

            .book-now-btn:hover {
                background: #c4160d;
                color: white;
                transform: translateY(-2px);
            }
            /* Container chính */
            .schedule-container {
                max-width: 1200px;
                margin: 0 auto;
                padding: 20px;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: #f8f9fa;
            }

            /* Phần ngày */
            .date-selector {
                display: flex;
                gap: 12px;
                overflow-x: auto;
                padding: 20px 0;
                margin-bottom: 30px;
                border-bottom: 1px solid #dee2e6;
            }

            .date-item {
                min-width: 85px;
                text-align: center;
                padding: 15px 12px;
                border-radius: 12px;
                cursor: pointer;
                transition: all 0.3s ease;
                background: white;
                border: 2px solid #e9ecef;
            }

            .date-item.active {
                background: #007bff;
                color: white;
                border-color: #007bff;
                box-shadow: 0 4px 12px rgba(0,123,255,0.3);
            }

            .date-item:hover:not(.active) {
                border-color: #007bff;
                transform: translateY(-2px);
            }

            .date-day {
                font-size: 26px;
                font-weight: bold;
                display: block;
                line-height: 1;
            }

            .date-month {
                font-size: 14px;
                color: #6c757d;
                display: block;
                margin: 4px 0;
            }

            .date-item.active .date-month {
                color: rgba(255,255,255,0.9);
            }

            .date-weekday {
                font-size: 12px;
                font-weight: 500;
                display: block;
            }

            /* Cinema item - CLEAN VERSION */
            .cinema-item {
                background: white;
                border-radius: 12px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.08);
                margin-bottom: 25px;
                border: 1px solid #e9ecef;
                overflow: hidden;
            }

            .cinema-header {
                background: white;
                padding: 20px;
                border-bottom: 1px solid #e9ecef;
            }

            .cinema-name {
                font-size: 20px;
                font-weight: 600;
                margin: 0 0 8px 0;
                color: #212529;
                display: flex;
                align-items: center;
                gap: 10px;
            }

            .cinema-address {
                font-size: 14px;
                color: #6c757d;
                display: flex;
                align-items: center;
                gap: 8px;
                line-height: 1.4;
            }

            /* Room section */
            .room-section {
                padding: 20px;
                border-bottom: 1px solid #f8f9fa;
            }

            .room-section:last-child {
                border-bottom: none;
            }

            .room-header {
                margin-bottom: 15px;
            }

            .room-name {
                font-size: 16px;
                font-weight: 600;
                color: #495057;
                margin: 0 0 8px 0;
                display: flex;
                align-items: center;
                gap: 8px;
            }

            .room-description {
                font-size: 13px;
                color: #6c757d;
                margin: 0;
                line-height: 1.5;
                background: #f8f9fa;
                padding: 10px 12px;
                border-radius: 6px;
                border-left: 3px solid #007bff;
            }

            /* Showtime list */
            .showtime-list {
                display: flex;
                flex-wrap: wrap;
                gap: 10px;
            }

            .showtime-item {
                display: inline-block;
                padding: 12px 18px;
                background: #28a745;
                color: white;
                text-decoration: none;
                border-radius: 8px;
                font-weight: 500;
                transition: all 0.3s ease;
                text-align: center;
                min-width: 110px;
                border: none;
                cursor: pointer;
                font-size: 14px;
            }

            .showtime-item:hover {
                background: #218838;
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(40,167,69,0.3);
                color: white;
                text-decoration: none;
            }

            /* Icons */
            .fas {
                color: #007bff;
            }

            .cinema-name .fas {
                color: #dc3545; /* Màu đỏ cho icon rạp phim */
            }

            .room-name .fas {
                color: #28a745; /* Màu xanh cho icon phòng */
            }

            /* Responsive */
            @media (max-width: 768px) {
                .schedule-container {
                    padding: 15px;
                }

                .date-item {
                    min-width: 75px;
                    padding: 12px 8px;
                }

                .date-day {
                    font-size: 22px;
                }

                .showtime-item {
                    min-width: 95px;
                    padding: 10px 12px;
                    font-size: 13px;
                }

                .cinema-header {
                    padding: 15px;
                }

                .room-section {
                    padding: 15px;
                }
            }
        </style>
    </head>
    <body>
        <jsp:include page="/views/layout/Header.jsp"/>

        <div class="detail_movie_all container mt-4">
            <div class="row">
                <!-- Poster -->
                <div class="col-md-5">
                    <div class="item_movie_detail">
                        <img src="${pageContext.request.contextPath}/assets/admin/img/img/${movie.image}" 
                             alt="${movie.name}" 
                             class="img-fluid rounded" 
                             style="max-height: 600px; object-fit: cover;">
                    </div>
                </div>

                <!-- Thông tin chi tiết -->
                <div class="col-md-7">
                    <div class="text_movie_detail">
                        <h1 class="mb-3">${movie.name}</h1>
                        <p class="lead">${movie.description}</p>

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
                            <dd>
                                <span class="badge ${movie.status == 'Đang chiếu' ? 'bg-success' : 'bg-warning'}">
                                    ${movie.status}
                                </span>
                            </dd>
                        </dl>

                        <!-- Nút đặt vé nhanh -->
                        <c:if test="${movie.status == 'Đang chiếu'}">
                            <div class="mt-4">
                                <a href="#schedule-section" class="book-now-btn">
                                    <i class="fas fa-ticket-alt me-2"></i>ĐẶT VÉ NGAY
                                </a>
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>

            <!-- Phần Lịch chiếu - ĐƯA LÊN TRÊN TRAILER -->
            <c:if test="${movie.status == 'Đang chiếu'}">
                <div id="schedule-section" class="schedule-section mt-5">
                    <div class="schedule-header">
                        <h3 class="text-center mb-4">
                            <i class="fas fa-calendar-alt me-2"></i>LỊCH CHIẾU - ${movie.name}
                        </h3>

                        <!-- Thanh chọn ngày -->
                        <div class="date-selector-container">
                            <div class="date-scroll-wrapper">
                                <div class="date-list" id="dateList">
                                    <c:forEach var="dateOption" items="${dateOptions}" varStatus="status">
                                        <div class="date-item ${status.index == 0 ? 'active' : ''}" 
                                             data-date="${dateOption.databaseDate}">
                                            <div class="date-day">${dateOption.day}</div>
                                            <div class="date-month">Th${dateOption.month}</div>
                                            <div class="date-weekday">
                                                <c:choose>
                                                    <%-- SỬA Ở ĐÂY: dùng dateOption.today --%>
                                                    <c:when test="${dateOption.today}">Hôm nay</c:when>
                                                    <c:otherwise>${dateOption.dayOfWeek}</c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Phần hiển thị rạp và suất chiếu -->
                    <div class="cinema-schedule-container mt-4">
                        <div id="scheduleContent" class="text-center text-muted py-5">
                            <i class="fas fa-film fa-3x mb-3"></i>
                            <h5>Chọn ngày để xem lịch chiếu</h5>
                            <p>Vui lòng chọn một ngày ở trên để xem các suất chiếu có sẵn</p>
                        </div>
                    </div>
                </div>
            </c:if>

            <hr class="hr-movie">

            <!-- Trailer - ĐƯA XUỐNG DƯỚI CÙNG -->
            <div class="trailer-section mt-4">
                <h3 class="text-center mb-4">
                    <i class="fas fa-play-circle me-2"></i>TRAILER PHIM
                </h3>
                <div class="trailer_detail_movie">
                    <div class="ratio ratio-16x9">
                        <iframe src="${movie.trailer}" 
                                title="Trailer ${movie.name}" 
                                frameborder="0" 
                                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
                                allowfullscreen>
                        </iframe>
                    </div>
                </div>
            </div>
        </div>

        <!-- Footer -->
        <jsp:include page="/views/layout/Footer.jsp"/>

        <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.7.0/jquery.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            $(document).ready(function () {
                // Xử lý click chọn ngày
                $('.date-item').click(function () {
                    // Xóa active cũ
                    $('.date-item').removeClass('active');
                    // Thêm active mới
                    $(this).addClass('active');

                    // Lấy ngày được chọn
                    const selectedDate = $(this).data('date');
                    const movieId = '${movie.id}';

                    // Hiển thị loading`
                    $('#scheduleContent').html(`
                        <div class="text-center py-4">
                            <div class="spinner-border text-primary" role="status">
                                <span class="visually-hidden">Loading...</span>
                            </div>
                            <p class="mt-2">Đang tải lịch chiếu...</p>
                        </div>
                    `);

                    // Gọi AJAX để lấy lịch chiếu
                    loadSchedule(movieId, selectedDate);
                });

                // Tự động load lịch chiếu cho ngày đầu tiên
                const firstDate = $('.date-item.active').data('date');
                if (firstDate) {
                    loadSchedule('${movie.id}', firstDate);
                }

                // Smooth scroll khi click nút "Đặt vé ngay"
                $('a[href="#schedule-section"]').click(function (e) {
                    e.preventDefault();
                    $('html, body').animate({
                        scrollTop: $('#schedule-section').offset().top - 100
                    }, 800);
                });
            });

            function loadSchedule(movieId, selectedDate) {
                console.log("AJAX Request - Movie ID:", movieId, "Date:", selectedDate);

                $.ajax({
                    url: '${pageContext.request.contextPath}/schedule-ajax',
                    type: 'GET',
                    xhrFields: {
                        withCredentials: true  // QUAN TRỌNG: Gửi kèm session cookie
                    },
                    data: {
                        movieId: movieId,
                        date: selectedDate
                    },
                    success: function (response) {
                        console.log("AJAX Success - Response length:", response.length);
                        $('#scheduleContent').html(response);
                    },
                    error: function (xhr, status, error) {
                        console.log("AJAX Error:", error, "Status:", xhr.status);
                        // Nếu lỗi 401 hoặc redirect về login
                        if (xhr.status === 401 || xhr.responseURL && xhr.responseURL.includes('/login')) {
                            if (confirm('Phiên đăng nhập đã hết hạn. Bạn có muốn đăng nhập lại không?')) {
                                window.location.href = '${pageContext.request.contextPath}/login';
                            }
                            return;
                        }
                        $('#scheduleContent').html(`
                <div class="no-schedule">
                    <i class="fas fa-exclamation-triangle fa-2x mb-3 text-danger"></i>
                    <h5>Lỗi tải dữ liệu</h5>
                    <p class="text-muted">Đã có lỗi xảy ra khi tải lịch chiếu</p>
                </div>
            `);
                    }
                });
            }
            // FORCE OVERRIDE - Thêm vào CUỐI detail.jsp, SAU khi load seat-modal.js
document.addEventListener('DOMContentLoaded', function() {
    // Đợi 2 giây để modal được load xong
    setTimeout(() => {
        console.log('🔧 FORCING button override after modal load');
        
        // Tìm và clone button để xóa tất cả event listeners cũ
        const oldBtn = document.querySelector('#confirmBtn');
        if (oldBtn) {
            const newBtn = oldBtn.cloneNode(true);
            oldBtn.parentNode.replaceChild(newBtn, oldBtn);
            console.log('✅ Button replaced, old handlers removed');
        }
    }, 2000);
});

        </script>
    </body>
</html>
<script src="${pageContext.request.contextPath}/assets/user/js/seat-modal.js"></script>