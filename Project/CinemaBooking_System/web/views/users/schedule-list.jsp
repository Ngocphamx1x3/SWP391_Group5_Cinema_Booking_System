<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<c:choose>
    <c:when test="${empty schedules}">
        <div class="no-schedule text-center py-5">
            <i class="fas fa-film fa-4x mb-4 text-muted"></i>
            <h4 class="text-muted">Không có suất chiếu nào</h4>
            <p class="text-muted">Không có suất chiếu nào cho ngày ${selectedDate}</p>
        </div>
    </c:when>
    <c:otherwise>
        <div class="schedule-results">
            <c:forEach var="schedule" items="${schedules}">
                <div class="schedule-item mb-3 p-3 border rounded">
                    <div class="schedule-info">
                        <h5 class="cinema-name">${schedule.cinemaName}</h5>
                        <p class="cinema-address text-muted mb-1">
                            <i class="fas fa-map-marker-alt"></i> ${schedule.cinemaAddress}
                        </p>
                        <p class="room-name mb-1">
                            <i class="fas fa-door-open"></i> ${schedule.roomName}
                        </p>
                        <c:if test="${not empty schedule.roomDescription}">
                            <p class="room-description text-muted small mb-2">
                                ${schedule.roomDescription}
                            </p>
                        </c:if>
                        
                        <div class="showtime-list mt-2">
                            <a href="javascript:void(0)" 
                               class="showtime-item btn btn-outline-primary btn-sm me-2 mb-2"
                               onclick="handleScheduleClick(${schedule.id}, ${not empty sessionScope.account})"
                               data-schedule-id="${schedule.id}">
                                <fmt:formatDate value="${schedule.startAt}" pattern="HH:mm"/> - 
                                <fmt:formatDate value="${schedule.finishAt}" pattern="HH:mm"/>
                            </a>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>

        <!-- MODAL CHỌN GHẾ -->
        <div id="seatModal" class="modal-overlay" style="display: none;">
            <div class="modal-container">
                <div class="modal-header">
                    <h3>Chọn Ghế</h3>
                    <button class="close-btn" onclick="closeSeatModal()">&times;</button>
                </div>
                <div class="modal-body" id="seatModalBody">
                    <div class="loading-spinner">
                        <i class="fas fa-spinner fa-spin"></i> Đang tải...
                    </div>
                </div>
            </div>
        </div>

        <script>
            function handleScheduleClick(scheduleId, isLoggedIn) {
                console.log('Schedule clicked:', scheduleId, 'Logged in:', isLoggedIn);
                
                if (!isLoggedIn) {
                    if (confirm('Bạn cần đăng nhập để đặt vé. Đến trang đăng nhập ngay?')) {
                        sessionStorage.setItem('redirectScheduleId', scheduleId);
                        sessionStorage.setItem('redirectUrl', window.location.href);
                        window.location.href = '${pageContext.request.contextPath}/login';
                    }
                } else {
                    openSeatModal(scheduleId);
                }
            }

            function openSeatModal(scheduleId) {
                console.log('Opening seat modal for schedule:', scheduleId);
                
                const modal = document.getElementById('seatModal');
                modal.style.display = 'flex';
                
                loadSeatData(scheduleId);
            }

            function closeSeatModal() {
                const modal = document.getElementById('seatModal');
                modal.style.display = 'none';
                document.getElementById('seatModalBody').innerHTML = 
                    '<div class="loading-spinner"><i class="fas fa-spinner fa-spin"></i> Đang tải...</div>';
            }

            function loadSeatData(scheduleId) {
                // SỬA QUAN TRỌNG: Dùng context path
                const contextPath = '${pageContext.request.contextPath}';
                const url = contextPath + '/user-seat-modal?scheduleId=' + scheduleId;
                
                console.log('🌐 Fetching from URL:', url);
                
                fetch(url)
                    .then(response => {
                        console.log('📨 Response status:', response.status, response.statusText);
                        if (!response.ok) {
                            throw new Error('HTTP ' + response.status + ': ' + response.statusText);
                        }
                        return response.text();
                    })
                    .then(html => {
                        console.log('✅ HTML received, length:', html.length);
                        console.log('📄 First 200 chars:', html.substring(0, 200));
                        document.getElementById('seatModalBody').innerHTML = html;
                    })
                    .catch(error => {
                        console.error('❌ Error loading seat data:', error);
                        document.getElementById('seatModalBody').innerHTML = 
                            '<div class="error-message">Lỗi tải dữ liệu ghế: ' + error.message + '</div>';
                    });
            }

            document.getElementById('seatModal').addEventListener('click', function(e) {
                if (e.target === this) {
                    closeSeatModal();
                }
            });

            document.addEventListener('DOMContentLoaded', function() {
                const redirectScheduleId = sessionStorage.getItem('redirectScheduleId');
                const isLoggedIn = ${not empty sessionScope.account};
                
                if (redirectScheduleId && isLoggedIn) {
                    sessionStorage.removeItem('redirectScheduleId');
                    sessionStorage.removeItem('redirectUrl');
                    openSeatModal(redirectScheduleId);
                }
            });
        </script>

        <style>
            .modal-overlay {
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(0, 0, 0, 0.8);
                display: flex;
                justify-content: center;
                align-items: center;
                z-index: 10000;
            }

            .modal-container {
                background: white;
                border-radius: 15px;
                width: 95%;
                max-width: 900px;
                max-height: 90vh;
                overflow: hidden;
            }

            .modal-header {
                background: #D0010B;
                color: white;
                padding: 20px;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }

            .close-btn {
                background: none;
                border: none;
                color: white;
                font-size: 2rem;
                cursor: pointer;
            }

            .modal-body {
                padding: 0;
                max-height: calc(90vh - 80px);
                overflow-y: auto;
            }

            .loading-spinner, .error-message {
                text-align: center;
                padding: 50px;
            }
        </style>
    </c:otherwise>
</c:choose>