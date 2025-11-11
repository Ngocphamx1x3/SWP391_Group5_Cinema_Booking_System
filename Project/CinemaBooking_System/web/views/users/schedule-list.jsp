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
                console.log('📌 Context path:', contextPath);
                
                // QUAN TRỌNG: Thêm credentials: 'include' để gửi kèm session cookie
                fetch(url, {
                    credentials: 'include',
                    method: 'GET',
                    headers: {
                        'X-Requested-With': 'XMLHttpRequest'
                    }
                })
                    .then(response => {
                        console.log('📨 Response status:', response.status, response.statusText);
                        // Nếu redirect về login (302 hoặc redirect), xử lý riêng
                        if (response.redirected && response.url.includes('/login')) {
                            if (confirm('Phiên đăng nhập đã hết hạn. Bạn có muốn đăng nhập lại không?')) {
                                window.location.href = contextPath + '/login';
                            }
                            return;
                        }
                        if (!response.ok) {
                            throw new Error('HTTP ' + response.status + ': ' + response.statusText);
                        }
                        return response.text();
                    })
                    .then(html => {
                        if (html) {
                            console.log('✅ HTML received, length:', html.length);
                            console.log('📄 First 200 chars:', html.substring(0, 200));
                            document.getElementById('seatModalBody').innerHTML = html;
                            
                            // Đợi một chút để DOM được render
                            setTimeout(function() {
                                const modalContent = document.querySelector('.seat-modal-content');
                                if (!modalContent) {
                                    console.warn('⚠️ Modal content element not found');
                                    return;
                                }
                                
                                // Khởi tạo lại seat-modal.js sau khi load modal content
                                if (typeof window.initSeatModalIfNeeded === 'function') {
                                    window.initSeatModalIfNeeded(modalContent);
                                    console.log('✅ Seat modal initialized');
                                } else {
                                    console.warn('⚠️ initSeatModalIfNeeded function not found');
                                }
                                
                                // QUAN TRỌNG: Attach event listener trực tiếp vào button để đảm bảo redirect tới FoodCombo
                                const confirmBtn = modalContent.querySelector('#confirmBtn');
                                if (confirmBtn) {
                                    console.log('✅ Confirm button found, attaching direct handler');
                                    
                                    // Đảm bảo button có type="button" để không submit form
                                    confirmBtn.type = 'button';
                                    
                                    // Xóa các event listener cũ bằng cách clone và replace
                                    const newBtn = confirmBtn.cloneNode(true);
                                    newBtn.type = 'button'; // Đảm bảo type="button"
                                    confirmBtn.parentNode.replaceChild(newBtn, confirmBtn);
                                    
                                    // Attach event listener mới với capture phase (ưu tiên cao nhất)
                                    // Sử dụng contextPath từ scope bên ngoài để đảm bảo có giá trị đúng
                                    newBtn.addEventListener('click', function handleConfirmClick(e) {
                                        console.log('🎯 Direct confirm button handler triggered');
                                        
                                        // Ngăn chặn mọi default behavior và propagation
                                        e.preventDefault();
                                        e.stopPropagation();
                                        e.stopImmediatePropagation();
                                        
                                        const modalEl = document.querySelector('.seat-modal-content');
                                        if (!modalEl) {
                                            console.error('❌ Cannot find .seat-modal-content');
                                            alert('Lỗi: Không tìm thấy thông tin modal!');
                                            return false;
                                        }
                                        
                                        const seatIds = modalEl.dataset.selectedSeatIds || '';
                                        const totalAmount = modalEl.dataset.totalAmount || '0';
                                        const scheduleId = modalEl.dataset.scheduleId;
                                        
                                        // Lấy contextPath: ưu tiên từ scope function, sau đó từ modal dataset
                                        // Nếu cả hai đều không có, tính từ window.location.pathname
                                        let finalContextPath = contextPath || modalEl.dataset.contextPath || '';
                                        
                                        // Nếu vẫn không có, tính từ URL hiện tại
                                        if (!finalContextPath || finalContextPath.trim() === '') {
                                            const currentPath = window.location.pathname;
                                            // Ví dụ: /CinemaBooking_System/detail -> /CinemaBooking_System
                                            const match = currentPath.match(/^\/([^\/]+)/);
                                            if (match && match[1]) {
                                                finalContextPath = '/' + match[1];
                                            }
                                        }
                                        
                                        // Đảm bảo finalContextPath có giá trị hợp lệ (bắt đầu bằng /)
                                        if (!finalContextPath || finalContextPath.trim() === '') {
                                            // Fallback: thử lấy từ window.location
                                            finalContextPath = window.location.pathname.split('/').filter(p => p)[0];
                                            if (finalContextPath) {
                                                finalContextPath = '/' + finalContextPath;
                                            } else {
                                                // Nếu vẫn không có, dùng giá trị mặc định
                                                finalContextPath = '/CinemaBooking_System';
                                            }
                                        }
                                        
                                        // Normalize: đảm bảo bắt đầu bằng / và không kết thúc bằng /
                                        finalContextPath = finalContextPath.trim();
                                        if (!finalContextPath.startsWith('/')) {
                                            finalContextPath = '/' + finalContextPath;
                                        }
                                        
                                        console.log('📊 Booking data:', { 
                                            scheduleId, 
                                            seatIds, 
                                            totalAmount, 
                                            contextPathFromScope: contextPath,
                                            contextPathFromModal: modalEl.dataset.contextPath,
                                            finalContextPath: finalContextPath,
                                            currentPath: window.location.pathname
                                        });
                                        
                                        if (!scheduleId) {
                                            alert('Lỗi: Không tìm thấy thông tin lịch chiếu!');
                                            return false;
                                        }
                                        if (!seatIds) {
                                            alert('Vui lòng chọn ít nhất một ghế!');
                                            return false;
                                        }
                                        
                                        // Disable button để tránh double click
                                        newBtn.disabled = true;
                                        newBtn.style.pointerEvents = 'none';
                                        newBtn.style.opacity = '0.6';
                                        
                                        // Tạo URL đầy đủ tới FoodCombo.jsp
                                        const params = new URLSearchParams({
                                            scheduleId: String(scheduleId),
                                            seatIds: seatIds,
                                            totalAmount: String(totalAmount)
                                        });
                                        
                                        // Tạo URL đầy đủ: http://host:port/contextPath/views/users/FoodCombo.jsp
                                        const baseUrl = window.location.origin;
                                        
                                        // Đảm bảo finalContextPath có giá trị hợp lệ
                                        let cleanContextPath = finalContextPath.trim();
                                        if (!cleanContextPath || cleanContextPath === '') {
                                            // Nếu vẫn rỗng, dùng giá trị mặc định từ context.xml
                                            cleanContextPath = '/CinemaBooking_System';
                                        }
                                        // Đảm bảo bắt đầu bằng / và không kết thúc bằng /
                                        if (!cleanContextPath.startsWith('/')) {
                                            cleanContextPath = '/' + cleanContextPath;
                                        }
                                        
                                        // Tạo đường dẫn đầy đủ
                                        const foodComboPath = cleanContextPath + '/views/users/FoodCombo.jsp';
                                        const redirectUrl = baseUrl + foodComboPath + '?' + params.toString();
                                        
                                        console.log('🚀 Redirecting to FoodCombo (full URL):', redirectUrl);
                                        console.log('📍 URL breakdown:', { 
                                            baseUrl: baseUrl, 
                                            contextPath: finalContextPath,
                                            fullPath: foodComboPath,
                                            params: params.toString(),
                                            finalUrl: redirectUrl
                                        });
                                        
                                        // Redirect tới FoodCombo.jsp với URL đầy đủ
                                        window.location.href = redirectUrl;
                                        
                                        return false;
                                    }, true); // Capture phase - chạy trước các listener khác
                                    
                                    console.log('✅ Direct handler attached to confirm button');
                                } else {
                                    console.warn('⚠️ Confirm button not found in modal content');
                                }
                            }, 200);
                        }
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