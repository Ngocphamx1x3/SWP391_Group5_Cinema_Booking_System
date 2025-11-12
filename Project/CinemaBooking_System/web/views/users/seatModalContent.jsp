<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    model.Schedule schedule = (model.Schedule) request.getAttribute("schedule");
    java.util.List<model.Seat> seats = (java.util.List<model.Seat>) request.getAttribute("seats");
    java.util.Map<String, Object> roomLayout = (java.util.Map<String, Object>) request.getAttribute("roomLayout");
    Double basePrice = (Double) request.getAttribute("basePrice");

    Integer roomRows = (Integer) request.getAttribute("roomRows");
    Integer roomColumns = (Integer) request.getAttribute("roomColumns");
    String movieImage = (String) request.getAttribute("movieImage");
    Integer movieDuration = (Integer) request.getAttribute("movieDuration");

    java.util.Set<Integer> occupiedSeatIds = (java.util.Set<Integer>) request.getAttribute("occupiedSeatIds");
    if (occupiedSeatIds == null) occupiedSeatIds = new java.util.HashSet<>();

    if (roomRows == null) roomRows = 9;
    if (roomColumns == null) roomColumns = 18;
    if (movieImage == null) movieImage = "default.jpg";
    if (movieDuration == null) movieDuration = 120;

    java.util.Map<String, model.Seat> seatPositionMap = new java.util.HashMap<>();
    java.util.Map<String, Integer> seatWidthMap = new java.util.HashMap<>();
    if (seats != null) {
        for (model.Seat seat : seats) {
            String key = seat.getPositionY() + "," + seat.getPositionX();
            seatPositionMap.put(key, seat);
            seatWidthMap.put(key, seat.getWidthUnits());
        }
    }
    String[] rowNames = {"A","B","C","D","E","F","G","H","I","J","K","L","M"};
%>

<!-- Quan trọng: nhúng scheduleId & contextPath để JS dùng -->
<div class="seat-modal-content"
     data-schedule-id="<%= schedule != null ? schedule.getId() : "" %>"
     data-context-path="${pageContext.request.contextPath}">

    <!-- Movie Info -->
    <div class="movie-info-header">
        <div class="movie-poster-small">
            <img src="${pageContext.request.contextPath}/assets/admin/img/img/<%= movieImage %>"
                 alt="<%= schedule != null ? schedule.getMovieName() : "Movie" %>"
                 onerror="this.style.display='none'; this.parentNode.querySelector('.poster-placeholder').style.display='flex';">
            <div class="poster-placeholder" style="display:none;"><i class="fas fa-film"></i></div>
        </div>
        <div class="movie-details">
            <h3><%= schedule != null ? schedule.getMovieName() : "Đang tải..." %></h3>
            <div class="schedule-details">
                <div class="detail-item">
                    <i class="fas fa-clock"></i>
                    <span>
                        <% if (schedule != null && schedule.getStartAt() != null) { %>
                        <%= new java.text.SimpleDateFormat("HH:mm").format(schedule.getStartAt()) %> -
                        <%= new java.text.SimpleDateFormat("HH:mm").format(schedule.getFinishAt()) %>
                        <% } else { %>Đang tải...<% } %>
                    </span>
                </div>
                <div class="detail-item">
                    <i class="fas fa-calendar"></i>
                    <span>
                        <% if (schedule != null && schedule.getStartAt() != null) { %>
                        <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(schedule.getStartAt()) %>
                        <% } else { %>Đang tải...<% } %>
                    </span>
                </div>
                <div class="detail-item">
                    <i class="fas fa-film"></i>
                    <span><%= schedule != null ? schedule.getRoomName() : "Đang tải..." %></span>
                </div>
            </div>
        </div>
    </div>

    <div class="cinema-screen">🎬 MÀN HÌNH CHÍNH 🎬</div>

    <!-- Seat Grid -->
    <div class="seat-grid-container">
        <div class="seat-grid">
            <%
              if (seats == null || seats.isEmpty()) {
            %>
            <div class="no-seats-message">
                <i class="fas fa-chair fa-3x"></i>
                <h4>Chưa có sơ đồ ghế</h4>
                <p>Phòng chiếu này chưa được thiết lập sơ đồ ghế</p>
            </div>
            <%
              } else {
                java.util.Map<String, Boolean> displayed = new java.util.HashMap<>();
                for (int y = 0; y < roomRows; y++) {
                  if (y >= rowNames.length) break;
            %>
            <div class="seat-row">
                <div class="row-label"><%= rowNames[y] %></div>
                <%
                  for (int x = 0; x < roomColumns; x++) {
                    String key = y + "," + x;
                    if (displayed.containsKey(key)) continue;

                    model.Seat seat = seatPositionMap.get(key);
                    if (seat != null) {
                      String seatClass = "seat-standard";
                      String typeName  = seat.getTypeName();
                      String seatColor = seat.getCustomColor();
                      int seatWidth    = seatWidthMap.get(key);
                      boolean isOccupied = occupiedSeatIds.contains(seat.getId());

                      if (typeName != null) {
                        switch (typeName.toLowerCase()) {
                          case "vip":     seatClass = "seat-vip";   break;
                          case "vip 2":   seatClass = "seat-vip2";  break;
                          case "couple":  seatClass = "seat-couple";break;
                          case "disabled":seatClass = "seat-disabled"; break;
                        }
                      }

                      // ------ NULL-SAFE GIÁ GHẾ ------
                      Double typeSurcharge = seat.getTypeSurcharge();
                      double seatPrice = (basePrice != null ? basePrice : 0d)
                                       + ((typeSurcharge != null && typeSurcharge > 0) ? typeSurcharge : 0d);

                      // ------ Fallback cho row/col để JS dùng ổn định ------
                      String rowAttr = (seat.getRowCode() != null && !seat.getRowCode().isEmpty())
                                       ? seat.getRowCode()
                                       : (seat.getLine() != null ? seat.getLine() : "");
                      int colAttr = (seat.getColumnNumber() != 0 ? seat.getColumnNumber() : seat.getNumber());

                      // Đánh dấu các ô bị chiếm bởi ghế đôi
                      for (int i = 0; i < seatWidth; i++) {
                        int cx = x + i;
                        if (cx < roomColumns) displayed.put(y + "," + cx, true);
                      }
                %>
                <div class="seat <%= seatClass %> <%= isOccupied ? "occupied" : "" %> <%= seatWidth > 1 ? "double-seat" : "" %>"
                     data-seat-id="<%= seat.getId() %>"
                     data-seat-code="<%= seat.getCode() %>"
                     data-seat-price="<%= (long) seatPrice %>"
                     data-seat-width="<%= seatWidth %>"
                     data-seat-occupied="<%= isOccupied %>"
                     data-row="<%= rowAttr %>"
                     data-col="<%= colAttr %>"
                     style="<%= seatColor != null ? ("background-color:" + seatColor + "; border-color:" + seatColor + ";") : "" %><%= seatWidth > 1 ? (" width:" + (seatWidth * 30 + (seatWidth - 1) * 4) + "px;") : "" %>">
                    <%= seat.getCode() %>
                    <% if (isOccupied) { %><div class="occupied-icon">✗</div><% } %>
                </div>
                <%
                    } else {
                %>
                <div class="empty-cell"></div>
                <%
                    }
                  } // end for x
                %>
            </div>
            <%
                } // end for y
              } // end else seats not empty
            %>
        </div>
    </div>

    <!-- Legend -->
    <div class="seat-legend">
        <div class="legend-item"><div class="legend-color standard"></div><span>Thường</span></div>
        <div class="legend-item"><div class="legend-color vip"></div><span>VIP 1</span></div>
        <div class="legend-item"><div class="legend-color vip2"></div><span>VIP 2</span></div>
        <div class="legend-item"><div class="legend-color couple"></div><span>Đôi</span></div>
        <div class="legend-item"><div class="legend-color occupied"></div><span>Đã đặt</span></div>
        <div class="legend-item"><div class="legend-color selected"></div><span>Bạn chọn</span></div>
    </div>

    <!-- Thêm phần Voucher vào modal ghế -->
<div class="voucher-container" id="voucherContainer">
    <div class="voucher-loading">
        <i class="fas fa-spinner fa-spin"></i> Đang tải khuyến mãi...
    </div>
</div>


    <!-- Selection Summary -->
    <div class="selection-summary">
        <h4>Ghế đã chọn:</h4>
        <div class="selected-seats" id="selectedSeats">
            <div class="no-selection">Chưa chọn ghế</div>
        </div>
        <div class="total-price">Tổng: <span id="totalAmount">0</span> VND</div>
        
        
        <button class="confirm-btn" id="confirmBtn" disabled>Xác Nhận</button>
    </div>
    
<!-- Thêm đoạn script này vào cuối file seat-modal.jsp, trước thẻ đóng </div> -->
<script>
// ========== VOUCHER SIMPLE SYSTEM ==========
console.log("🎫 VOUCHER SIMPLE SYSTEM - Initializing");

// Định nghĩa các hàm debug TRƯỚC KHI sử dụng
window.reloadVouchers = function() {
    console.log('🔄 Manual voucher reload triggered');
    initializeVoucherSimple();
};

window.debugVoucherSystem = function() {
    const modalEl = document.querySelector('.seat-modal-content');
    const voucherContainer = document.getElementById('voucherContainer');
    
    console.log('=== VOUCHER DEBUG INFO ===');
    console.log('Modal element:', modalEl ? 'Found' : 'Not found');
    console.log('Voucher container:', voucherContainer ? 'Found' : 'Not found');
    
    if (modalEl) {
        console.log('Schedule ID:', modalEl.dataset.scheduleId);
        console.log('Context path:', modalEl.dataset.contextPath);
    }
    
    const urlParams = new URLSearchParams(window.location.search);
    console.log('Movie ID from URL:', urlParams.get('id'));
    
    // Test AJAX call
    if (modalEl && urlParams.get('id')) {
        const testUrl = modalEl.dataset.contextPath + '/voucher-ajax?movieId=' + urlParams.get('id') + '&totalAmount=0';
        console.log('Test URL:', testUrl);
        
        fetch(testUrl)
            .then(r => {
                console.log('Test fetch status:', r.status);
                return r.text();
            })
            .then(html => {
                console.log('Test fetch response length:', html.length);
                console.log('Test fetch first 100 chars:', html.substring(0, 100));
            })
            .catch(e => console.log('Test fetch error:', e));
    }
};

// Khởi tạo voucher system đơn giản và hiệu quả
function initializeVoucherSimple() {
    console.log('🎫 [SIMPLE] Starting voucher initialization...');
    
    const voucherContainer = document.getElementById('voucherContainer');
    if (!voucherContainer) {
        console.log('❌ [SIMPLE] Voucher container not found');
        return;
    }
    
    const modalEl = document.querySelector('.seat-modal-content');
    if (!modalEl) {
        console.log('❌ [SIMPLE] Modal not found');
        return;
    }
    
    const scheduleId = modalEl.dataset.scheduleId;
    const contextPath = modalEl.dataset.contextPath || '';
    
    console.log('✅ [SIMPLE] Modal found, scheduleId:', scheduleId);
    
    // Lấy movieId từ URL
    const urlParams = new URLSearchParams(window.location.search);
    const movieId = urlParams.get('id');
    
    if (!movieId) {
        console.log('❌ [SIMPLE] No movieId found');
        voucherContainer.innerHTML = '<div class="no-vouchers">Không thể xác định phim</div>';
        return;
    }
    
    console.log('✅ [SIMPLE] Movie ID:', movieId);
    
    // Load vouchers trực tiếp
    loadVouchersDirect(movieId, 0, contextPath, voucherContainer);
}

// Hàm load voucher trực tiếp
function loadVouchersDirect(movieId, totalAmount, contextPath, container) {
    const url = contextPath + '/voucher-ajax?movieId=' + movieId + '&totalAmount=' + totalAmount;
    
    console.log('📡 [SIMPLE] Fetching from:', url);
    
    container.innerHTML = '<div class="voucher-loading"><i class="fas fa-spinner fa-spin"></i> Đang tải khuyến mãi...</div>';
    
    fetch(url)
        .then(response => {
            console.log('📨 [SIMPLE] Response status:', response.status);
            if (!response.ok) throw new Error('HTTP ' + response.status);
            return response.text();
        })
        .then(html => {
            console.log('✅ [SIMPLE] Vouchers loaded, length:', html.length);
            console.log('📄 [SIMPLE] First 200 chars:', html.substring(0, 200));
            container.innerHTML = html;
            attachVoucherEventsSimple();
        })
        .catch(error => {
            console.error('❌ [SIMPLE] Error:', error);
            container.innerHTML = '<div class="no-vouchers">Lỗi tải khuyến mãi: ' + error.message + '</div>';
        });
}

// Gắn sự kiện đơn giản
// Gắn sự kiện cho voucher items (hệ thống cũ)
function attachVoucherEventsSimple() {
    const items = document.querySelectorAll('.voucher-item');
    console.log('🎯 [SIMPLE] Found', items.length, 'voucher items');
    
    items.forEach(item => {
        item.addEventListener('click', function() {
            const isCurrentlySelected = this.classList.contains('selected');
            
            // Nếu đang được chọn thì không làm gì (vì đã có nút bỏ chọn)
            if (isCurrentlySelected) {
                return;
            }
            
            // Bỏ chọn tất cả
            document.querySelectorAll('.voucher-item').forEach(v => {
                v.classList.remove('selected');
                // Ẩn nút bỏ chọn của tất cả voucher
                const deselectBtn = v.querySelector('.voucher-deselect-btn');
                if (deselectBtn) deselectBtn.style.display = 'none';
            });
            
            // Chọn voucher này
            this.classList.add('selected');
            
            // Hiển thị nút bỏ chọn
            const deselectBtn = this.querySelector('.voucher-deselect-btn');
            if (deselectBtn) deselectBtn.style.display = 'block';
            
            const voucherData = {
                id: this.dataset.voucherId,
                code: this.dataset.voucherCode,
                discountType: parseInt(this.dataset.discountType),
                discountValue: parseFloat(this.dataset.discountValue),
                maxDiscount: parseFloat(this.dataset.maxDiscount) || 0,
                minOrder: parseFloat(this.dataset.minOrder) || 0
            };
            
            console.log('💳 [SIMPLE] Voucher selected:', voucherData);
            applyVoucherDiscount(voucherData);
        });
    });
    
    // Gắn sự kiện cho các nút bỏ chọn (nếu có)
    document.querySelectorAll('.btn-deselect-voucher').forEach(btn => {
        btn.addEventListener('click', function(e) {
            e.stopPropagation(); // Ngăn sự kiện click lan ra voucher item
            deselectVoucher(this);
        });
    });
}

// Hàm bỏ chọn voucher
function deselectVoucher(button) {
    const voucherItem = button.closest('.voucher-item');
    voucherItem.classList.remove('selected');
    
    // Ẩn nút bỏ chọn
    const deselectBtn = voucherItem.querySelector('.voucher-deselect-btn');
    if (deselectBtn) deselectBtn.style.display = 'none';
    
    console.log('❌ [SIMPLE] Voucher deselected via button');
    resetVoucherDiscount();
}

// Hàm reset voucher
function resetVoucherDiscount() {
    const baseTotal = calculateBaseTotalSimple();
    console.log('🔄 [SIMPLE] Resetting voucher, returning to base total:', baseTotal);
    
    updateTotalDisplaySimple(baseTotal);
    
    // Cập nhật dataset.totalAmount
    const modalEl = document.querySelector('.seat-modal-content');
    if (modalEl) {
        modalEl.dataset.totalAmount = String(baseTotal);
        console.log('💾 [SIMPLE] Reset modal dataset.totalAmount:', modalEl.dataset.totalAmount);
    }
    
    // Reset biến toàn cục
    window.selectedVoucher = null;
    window.appliedDiscount = 0;
    
    console.log('✅ [SIMPLE] Voucher reset completed');
}

// Hàm reset cho hệ thống cũ
function resetVoucherDiscountOld() {
    const baseTotal = calculateBaseTotal();
    console.log('🔄 [VOUCHER] Resetting voucher, returning to base total:', baseTotal);
    
    updateTotalDisplay(baseTotal);
    
    // Reset biến toàn cục
    window.selectedVoucher = null;
    window.appliedDiscount = 0;
}

// Hàm reset voucher
function resetVoucherDiscount() {
    const baseTotal = calculateBaseTotalSimple();
    console.log('🔄 [SIMPLE] Resetting voucher, returning to base total:', baseTotal);
    
    updateTotalDisplaySimple(baseTotal);
    
    // Cập nhật dataset.totalAmount
    const modalEl = document.querySelector('.seat-modal-content');
    if (modalEl) {
        modalEl.dataset.totalAmount = String(baseTotal);
        console.log('💾 [SIMPLE] Reset modal dataset.totalAmount:', modalEl.dataset.totalAmount);
    }
    
    // Reset biến toàn cục
    window.selectedVoucher = null;
    window.appliedDiscount = 0;
    
    console.log('✅ [SIMPLE] Voucher reset completed');
}
// Áp dụng discount
// Cập nhật tổng tiền với voucher
function applyVoucherDiscount(voucher) {
    const baseTotal = calculateBaseTotalSimple();
    console.log('💰 [SIMPLE] Base total:', baseTotal);
    
    if (baseTotal < voucher.minOrder) {
        const message = `Voucher ${voucher.code} yêu cầu đơn tối thiểu ${voucher.minOrder.toLocaleString()}₫`;
        console.log('❌ [SIMPLE]', message);
        alert(message);
        document.querySelectorAll('.voucher-item').forEach(v => v.classList.remove('selected'));
        updateTotalDisplaySimple(baseTotal);
        
        // Reset biến toàn cục
        window.selectedVoucher = null;
        window.appliedDiscount = 0;
        return;
    }
    
    let discountAmount = 0;
    
    if (voucher.discountType === 1) {
        discountAmount = baseTotal * (voucher.discountValue / 100);
        if (voucher.maxDiscount > 0 && discountAmount > voucher.maxDiscount) {
            discountAmount = voucher.maxDiscount;
        }
    } else {
        discountAmount = voucher.discountValue;
    }
    
    const finalTotal = Math.max(0, baseTotal - discountAmount);
    console.log('💰 [SIMPLE] Discount:', discountAmount, 'Final total:', finalTotal);
    
    updateTotalDisplaySimple(finalTotal);
    
    // QUAN TRỌNG: Cập nhật dataset.totalAmount để checkout sử dụng
   const modalEl = document.querySelector('.seat-modal-content');
    if (modalEl) {
        modalEl.dataset.totalAmount = String(finalTotal);
        console.log('💾 [SIMPLE] Updated modal dataset.totalAmount:', modalEl.dataset.totalAmount);
    }
    
    // Lưu vào biến toàn cục để checkout sử dụng
    window.selectedVoucher = voucher;
    window.appliedDiscount = discountAmount;
    
    console.log('💾 [SIMPLE] Global vars updated:', {
        selectedVoucher: window.selectedVoucher,
        appliedDiscount: window.appliedDiscount
    });
}

// Tính tổng tiền đơn giản
function calculateBaseTotalSimple() {
    // Cách 1: Tính từ các ghế được chọn (chính xác nhất)
    let total = 0;
    document.querySelectorAll('.seat.selected').forEach(seat => {
        total += parseFloat(seat.dataset.seatPrice) || 0;
    });
    
    console.log('💰 [SIMPLE] Calculated base total from seats:', total);
    return total;
}

// Cập nhật hiển thị tổng tiền
function updateTotalDisplaySimple(total) {
    const totalElement = document.getElementById('totalAmount');
    const modalEl = document.querySelector('.seat-modal-content');
    
    if (totalElement) {
        totalElement.textContent = total.toLocaleString();
        console.log('💰 [SIMPLE] Updated total display:', total.toLocaleString());
    }
    
    // QUAN TRỌNG: Đồng bộ với dataset
    if (modalEl) {
        modalEl.dataset.totalAmount = String(total);
        console.log('💾 [SIMPLE] Updated modal dataset.totalAmount:', modalEl.dataset.totalAmount);
    }
}

// Trong file seat selection (seat-modal.js hoặc tương tự)
function proceedToCombo() {
    const selectedVoucher = document.querySelector('.voucher-item.selected');
    let voucherParams = '';
    
    if (selectedVoucher) {
        const voucherId = selectedVoucher.dataset.voucherId;
        const voucherCode = selectedVoucher.dataset.voucherCode;
        const discountAmount = calculateDiscount(selectedVoucher, totalAmount);
        
        voucherParams = `&voucherId=${voucherId}&voucherCode=${voucherCode}&discountAmount=${discountAmount}`;
    }
    
    // Chuyển đến trang combo với thông tin voucher
   window.location.href = `${contextPath}/views/users/FoodCombo.jsp?scheduleId=${scheduleId}&seatIds=${selectedSeatIds}&totalAmount=${modalEl.dataset.totalAmount || totalAmount}`;
}

// Khởi tạo tự động
function autoInitializeVoucher() {
    console.log('🚀 [SIMPLE] Auto-initializing voucher system...');
    
    // Đợi một chút để đảm bảo DOM đã sẵn sàng
    setTimeout(() => {
        const modalEl = document.querySelector('.seat-modal-content');
        if (modalEl) {
            console.log('🎯 [SIMPLE] Modal found, initializing...');
            initializeVoucherSimple();
        } else {
            console.log('👀 [SIMPLE] Modal not found yet, waiting...');
            // Thử lại sau 1 giây
            setTimeout(initializeVoucherSimple, 1000);
        }
    }, 500);
}

// Bắt đầu khởi tạo
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', autoInitializeVoucher);
} else {
    autoInitializeVoucher();
}

// Cũng khởi tạo khi có sự kiện modal mở (nếu có)
if (typeof window.openSeatModal === 'function') {
    const originalOpenSeatModal = window.openSeatModal;
    window.openSeatModal = function(...args) {
        console.log('🎬 [SIMPLE] Seat modal opened, initializing voucher...');
        const result = originalOpenSeatModal(...args);
        setTimeout(initializeVoucherSimple, 1000);
        return result;
    };
}

console.log('✅ VOUCHER SIMPLE SYSTEM - Ready');
</script>
</div>

<style>
    /* --- Giữ nguyên style của bạn, rút gọn phần không đổi --- */
    .seat-modal-content{
        padding:20px;
        background:#fff;
        border-radius:15px;
        max-width:900px;
        margin:0 auto;
    }
    .movie-info-header{
        display:flex;
        gap:15px;
        align-items:center;
        margin-bottom:20px;
        padding:15px;
        background:#f8f9fa;
        border-radius:10px;
        border:1px solid #e0e0e0;
    }
    .movie-poster-small{
        width:60px;
        height:80px;
        border-radius:8px;
        overflow:hidden;
        background:#e0e0e0;
        flex-shrink:0;
        position:relative;
    }
    .movie-poster-small img{
        width:100%;
        height:100%;
        object-fit:cover;
    }
    .poster-placeholder{
        width:100%;
        height:100%;
        background:#f8f9fa;
        display:flex;
        align-items:center;
        justify-content:center;
        color:#ccc;
        border-radius:8px;
    }
    .cinema-screen{
        background:linear-gradient(135deg,#4a5568 0%,#2d3748 100%);
        color:#fff;
        text-align:center;
        padding:15px;
        margin:20px 0;
        border-radius:8px;
        font-weight:bold;
        box-shadow:0 4px 8px rgba(0,0,0,.1);
    }
    .seat-grid-container{
        background:#f8f9fa;
        padding:20px;
        border-radius:10px;
        margin:20px 0;
        overflow-x:auto;
        border:2px solid #e0e0e0;
    }
    .seat-grid{
        display:flex;
        flex-direction:column;
        gap:8px;
        align-items:center;
        min-width:max-content;
    }
    .seat-row{
        display:flex;
        gap:4px;
        align-items:center;
        height:34px;
        min-height:34px;
    }
    .row-label{
        width:25px;
        text-align:center;
        font-weight:bold;
        color:#666;
        font-size:14px;
        flex-shrink:0;
    }
    .seat{
        width:30px;
        height:30px;
        border-radius:6px;
        display:flex;
        align-items:center;
        justify-content:center;
        font-size:10px;
        font-weight:bold;
        cursor:pointer;
        transition:all .2s;
        border:2px solid;
        color:#fff;
        position:relative;
        box-sizing:border-box;
        flex-shrink:0;
        user-select:none;
    }
    .seat.double-seat{
        width:64px!important;
        font-size:9px!important;
        z-index:2;
        position:relative;
    }
    .seat:hover{
        transform:scale(1.1);
        z-index:3;
    }
    .seat.selected{
        background:#28a745!important;
        border-color:#218838!important;
        box-shadow:0 0 10px rgba(40,167,69,.5);
        z-index:3;
    }
    .seat.occupied{
        background: #ccc !important;
        border-color: #999 !important;
        color: #666 !important;
        cursor: not-allowed;
        opacity: .7;
        pointer-events: none;      /* <- khóa mọi click/hover */
        box-shadow: none;
    }

    .seat.occupied:hover{
        transform: none;           /* không phóng to khi hover */
    }
    .occupied-icon{
        position:absolute;
        top:50%;
        left:50%;
        transform:translate(-50%,-50%);
        font-size:14px;
        color:#ff4444;
        font-weight:bold;
    }
    .seat-standard{
        background:#1e90ff;
        border-color:#1e90ff;
    }
    .seat-vip{
        background:#ffd700;
        border-color:#ffd700;
        color:#333!important;
    }
    .seat-couple{
        background:#ff69b4;
        border-color:#ff69b4;
    }
    .seat-disabled{
        background:#32CD32;
        border-color:#32CD32;
    }
    .seat-vip2{
        background:#a11212;
        border-color:#a11212;
        color:#333!important;
    }
    .empty-cell{
        width:30px;
        height:30px;
        visibility:hidden;
        pointer-events:none;
        flex-shrink:0;
    }
    .no-seats-message{
        text-align:center;
        padding:40px;
        color:#666;
        background:#fff;
        border-radius:10px;
        margin:20px 0;
    }
    .seat-legend{
        display:flex;
        justify-content:center;
        gap:20px;
        margin:20px 0;
        flex-wrap:wrap;
        padding:15px;
        background:#f8f9fa;
        border-radius:10px;
        border:1px solid #e0e0e0;
    }
    .legend-item{
        display:flex;
        align-items:center;
        gap:8px;
        font-size:14px;
    }
    .legend-color{
        width:20px;
        height:20px;
        border-radius:4px;
        border:2px solid;
        flex-shrink:0;
    }
    .legend-color.standard{
        background:#1e90ff;
        border-color:#1e90ff;
    }
    .legend-color.vip{
        background:#ffd700;
        border-color:#ffd700;
    }
    .legend-color.couple{
        background:#ff69b4;
        border-color:#ff69b4;
    }
    .legend-color.occupied{
        background:#ccc;
        border-color:#999;
    }
    .legend-color.vip2{
        background:#ff4444;
        border-color:#ff4444;
    }
    .legend-color.selected{
        background:#28a745;
        border-color:#218838;
    }
    .selection-summary{
        background:#fff;
        border:2px solid #e0e0e0;
        border-radius:10px;
        padding:20px;
        margin-top:20px;
    }
    .selected-seats{
        display:flex;
        flex-wrap:wrap;
        gap:8px;
        margin:10px 0;
        min-height:40px;
        align-items:center;
    }
    .no-selection{
        color:#999;
        font-style:italic;
        font-size:14px;
    }
    .selected-seat-badge{
        background:#D0010B;
        color:#fff;
        padding:5px 10px;
        border-radius:15px;
        font-size:14px;
        font-weight:bold;
        display:inline-block;
    }
    .total-price{
        font-size:18px;
        font-weight:bold;
        margin:15px 0;
        color:#D0010B;
        text-align:center;
    }
    .confirm-btn{
        background:#D0010B;
        color:#fff;
        border:none;
        padding:12px 30px;
        border-radius:25px;
        font-size:16px;
        font-weight:bold;
        cursor:pointer;
        width:100%;
        transition:all .3s;
    }
    .confirm-btn:disabled{
        background:#ccc;
        cursor:not-allowed;
    }
    .occupied-alert{
        position:fixed;
        top:20px;
        right:20px;
        background:#ff4444;
        color:#fff;
        padding:15px;
        border-radius:8px;
        z-index:10000;
        box-shadow:0 4px 12px rgba(0,0,0,.3);
    }
    
    /* Voucher Section Styles */
.voucher-container {
    margin: 20px 0;
    padding: 15px;
    background: #f8f9fa;
    border-radius: 10px;
    border: 1px solid #e9ecef;
}

.voucher-loading {
    text-align: center;
    padding: 20px;
    color: #6c757d;
}

.no-vouchers {
    text-align: center;
    padding: 20px;
    color: #6c757d;
    font-style: italic;
}

.voucher-section {
    margin: 0;
}/* Voucher Container Styles */
.voucher-container {
    margin: 15px 0;
    padding: 15px;
    background: #f8f9fa;
    border-radius: 8px;
    border: 1px solid #e9ecef;
}

.voucher-loading {
    text-align: center;
    padding: 20px;
    color: #6c757d;
}

.voucher-list {
    display: flex;
    flex-direction: column;
    gap: 10px;
}

.voucher-item {
    padding: 12px 15px;
    background: white;
    border: 2px solid #e9ecef;
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.3s ease;
}

.voucher-item:hover {
    border-color: #007bff;
    transform: translateY(-2px);
}

.voucher-item.selected {
    border-color: #28a745;
    background: #f8fff9;
}

.voucher-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 5px;
}

.voucher-code {
    font-weight: bold;
    color: #dc3545;
}

.voucher-discount {
    background: #dc3545;
    color: white;
    padding: 2px 8px;
    border-radius: 4px;
    font-size: 12px;
}

.voucher-description {
    font-size: 14px;
    color: #6c757d;
    margin-bottom: 5px;
}

.voucher-conditions {
    font-size: 12px;
    color: #868e96;
}

.no-vouchers {
    text-align: center;
    padding: 20px;
    color: #6c757d;
    font-style: italic;
}
</style>
