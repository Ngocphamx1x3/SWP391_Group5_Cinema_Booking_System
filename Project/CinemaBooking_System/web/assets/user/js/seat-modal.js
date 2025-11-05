(function () {
    console.log("🎬 seat-modal.js loaded");
    const MAX_SELECTED = 8;
    
    window.calculateBaseTotal = function() {
        const modalEl = document.querySelector('.seat-modal-content');
        if (!modalEl) return 0;
        
        let total = 0;
        modalEl.querySelectorAll('.seat.selected').forEach(seat => {
            total += parseFloat(seat.dataset.seatPrice) || 0;
        });
        console.log('💰 [GLOBAL BASE TOTAL] Calculated:', total);
        return total;
    };
    
    function showToast(msg) {
        const existing = document.querySelector('.occupied-alert');
        if (existing)
            existing.remove();
        const el = document.createElement('div');
        el.className = 'occupied-alert';
        el.innerHTML = `<strong>${msg}</strong>`;
        document.body.appendChild(el);
        setTimeout(() => el.remove(), 2500);
    }

    function showOccupiedSeatMessage(seatCode) {
        showToast(`⚠️ Ghế ${seatCode} đã được đặt. Vui lòng chọn ghế khác.`);
    }

    // ---- Single-gap helpers ----
    function buildRowState(modalEl, extraSelection /* {row, col} | null */) {
        const rows = new Map();
        modalEl.querySelectorAll('.seat').forEach(el => {
            const row = el.dataset.row;
            const col = parseInt(el.dataset.col || '0', 10);
            if (!row || !col)
                return;
            if (!rows.has(row))
                rows.set(row, {present: new Set(), occupied: new Set(), selected: new Set(), minCol: col, maxCol: col});
            const r = rows.get(row);
            r.present.add(col);
            r.minCol = Math.min(r.minCol, col);
            r.maxCol = Math.max(r.maxCol, col);
            if (el.classList.contains('occupied') || el.dataset.seatOccupied === 'true')
                r.occupied.add(col);
            if (el.classList.contains('selected'))
                r.selected.add(col);
        });
        if (extraSelection && rows.has(extraSelection.row)) {
            rows.get(extraSelection.row).selected.add(extraSelection.col);
        }
        return rows;
    }

    function violatesSingleGap(modalEl, extraSelection /* {row, col} | null */) {
        const rows = buildRowState(modalEl, extraSelection);
        for (const [, data] of rows.entries()) {
            const {present, occupied, selected, minCol, maxCol} = data;
            const isTaken = (c) => occupied.has(c) || selected.has(c);
            for (let c = minCol; c <= maxCol; c++) {
                if (!present.has(c))
                    continue;
                if (isTaken(c))
                    continue;
                const hasLeft = present.has(c - 1);
                const hasRight = present.has(c + 1);
                if (hasLeft && hasRight) {
                    if (isTaken(c - 1) && isTaken(c + 1))
                        return true;
                }
            }
        }
        return false;
    }
    // ---- /Single-gap helpers ----

    function recalcAndRender(modalEl) {
        const selectedEls = [...modalEl.querySelectorAll('.seat.selected')];
        const selectedSeatsContainer = modalEl.querySelector('#selectedSeats');
        const totalAmountElement = modalEl.querySelector('#totalAmount');
        const confirmBtn = modalEl.querySelector('#confirmBtn');

        const seatData = selectedEls.map(el => ({
                id: el.dataset.seatId,
                code: el.dataset.seatCode,
                price: parseInt(el.dataset.seatPrice || '0', 10) || 0
            }));
        const total = seatData.reduce((s, x) => s + x.price, 0);

        selectedSeatsContainer.innerHTML = seatData.length === 0
                ? '<div class="no-selection">Chưa chọn ghế</div>'
                : seatData.map(s => `<div class="selected-seat-badge">${s.code} - ${s.price.toLocaleString()}₫</div>`).join('');

        totalAmountElement.textContent = total.toLocaleString();
        confirmBtn.disabled = seatData.length === 0;

        modalEl.dataset.selectedSeatIds = seatData.map(s => s.id).join(',');
        modalEl.dataset.totalAmount = String(total);
    }

    // Chọn / bỏ chọn ghế
    document.addEventListener('click', function (e) {
        const seat = e.target.closest('.seat');
        if (!seat)
            return;

        const modalEl = seat.closest('.seat-modal-content');
        if (!modalEl)
            return;

        // 🔒 CHẶN GHẾ BẬN (từ server)
        if (seat.classList.contains('occupied') || seat.dataset.seatOccupied === 'true') {
            showOccupiedSeatMessage(seat.dataset.seatCode);
            return;
        }

        const currentlySelected = seat.classList.contains('selected');

        if (!currentlySelected) {
            const selectedCount = modalEl.querySelectorAll('.seat.selected').length;
            if (selectedCount >= MAX_SELECTED) {
                showToast('⚠️ Một người chỉ được đặt tối đa 8 ghế.');
                return;
            }
            const row = seat.dataset.row;
            const col = parseInt(seat.dataset.col || '0', 10);
            if (row && col && violatesSingleGap(modalEl, {row, col})) {
                showToast('⚠️ Không được để trống 1 ghế lẻ ở giữa trong hàng.');
                return;
            }
            seat.classList.add('selected');
            recalcAndRender(modalEl);
            return;
        }

        // Bỏ chọn: không để tạo ghế lẻ
        seat.classList.remove('selected');
        if (violatesSingleGap(modalEl, null)) {
            seat.classList.add('selected');
            showToast('⚠️ Bỏ ghế này sẽ tạo 1 ghế lẻ ở giữa. Vui lòng chọn ghế khác.');
            return;
        }
        recalcAndRender(modalEl);
    });

   // Xác nhận: POST tới /checkout
document.addEventListener('click', function (e) {
    const btn = e.target.closest('.confirm-btn#confirmBtn');
    if (!btn) return;

    const modalEl = btn.closest('.seat-modal-content');
    if (!modalEl) return;

    // Kiểm tra ghế lẻ
    if (violatesSingleGap(modalEl, null)) {
        showToast('⚠️ Không được để trống 1 ghế lẻ ở giữa trong hàng.');
        return;
    }

    const seatIds = modalEl.dataset.selectedSeatIds || '';
    let totalAmount = modalEl.dataset.totalAmount || '0';
    const scheduleId = modalEl.dataset.scheduleId;
    const contextPath = modalEl.dataset.contextPath || '';

    console.log('🔍 [CHECKOUT] Starting checkout process:');
    console.log(' - Schedule ID:', scheduleId);
    console.log(' - Seat IDs:', seatIds);
    console.log(' - Total Amount from dataset:', totalAmount);

    // DEBUG: Kiểm tra giá trị hiển thị trên giao diện
    const displayTotalElement = document.getElementById('totalAmount');
    if (displayTotalElement) {
        const displayTotal = displayTotalElement.textContent.replace(/[^\d]/g, '');
        console.log(' - Total Amount from display:', displayTotal);
        
        // Ưu tiên sử dụng giá trị từ hiển thị nếu khác với dataset
        if (displayTotal !== totalAmount.replace(/[^\d]/g, '')) {
            console.log('⚠️ [CHECKOUT] Dataset and display mismatch, using display value');
            totalAmount = displayTotal;
        }
    }

    if (!scheduleId) {
        alert('Lỗi: Không tìm thấy thông tin lịch chiếu!');
        return;
    }
    if (!seatIds) {
        alert('Vui lòng chọn ít nhất một ghế!');
        return;
    }

    // Disable để tránh double submit
    btn.disabled = true;
    btn.textContent = 'Đang xử lý...';

    // Tính tổng gốc từ các ghế được chọn
    function calculateBaseTotal() {
        let total = 0;
        modalEl.querySelectorAll('.seat.selected').forEach(seat => {
            total += parseFloat(seat.dataset.seatPrice) || 0;
        });
        console.log('💰 [BASE TOTAL] Calculated:', total);
        return total;
    }

    const baseTotal = calculateBaseTotal();
    const finalTotal = parseInt(totalAmount.replace(/[^\d]/g, '')) || 0;
    const discountAmount = baseTotal - finalTotal;

    console.log('💰 [PRICE BREAKDOWN] Base:', baseTotal, 'Final:', finalTotal, 'Discount:', discountAmount);

    // Tạo form POST tới /checkout
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = contextPath + '/checkout';

    // Các trường bắt buộc
    const fields = [
        { name: 'scheduleId', value: scheduleId },
        { name: 'seatIds', value: seatIds },
        { name: 'totalAmount', value: String(finalTotal) },
        { name: 'originalAmount', value: String(baseTotal) }
    ];

    // Thêm thông tin voucher nếu có
    if (window.selectedVoucher && window.appliedDiscount > 0) {
        fields.push(
            { name: 'voucherId', value: String(window.selectedVoucher.id) },
            { name: 'voucherCode', value: String(window.selectedVoucher.code) },
            { name: 'discountAmount', value: String(discountAmount) }
        );
        console.log('💳 [VOUCHER] Adding voucher to form:', window.selectedVoucher);
    }

    console.log('📤 [FORM DATA] Fields to submit:', fields);

    // Thêm tất cả các trường vào form
    fields.forEach(field => {
        const input = document.createElement('input');
        input.type = 'hidden';
        input.name = field.name;
        input.value = field.value;
        form.appendChild(input);
    });

    // Thêm form vào DOM và submit
    document.body.appendChild(form);
    
    console.log('🚀 [SUBMIT] Submitting form to:', form.action);
    form.submit();
});

    // Gọi sau khi load fragment để sync tổng tiền
    window.initSeatModalIfNeeded = function (container) {
        const modalEl = (typeof container === 'string') ? document.querySelector(container) : container;
        if (modalEl && modalEl.classList.contains('seat-modal-content')) {
            recalcAndRender(modalEl);
        }
    };
})();

// ========== VOUCHER SYSTEM (GLOBAL SCOPE) ==========
console.log("🎫 VOUCHER SYSTEM - Global scope loaded");

// Biến toàn cục
window.selectedVoucher = null;
window.appliedDiscount = 0;

// Hàm chính để khởi tạo voucher system
window.initializeVoucherSystem = function() {
    console.log('🎬 [VOUCHER] Initializing voucher system...');
    
    const modalEl = document.querySelector('.seat-modal-content');
    if (!modalEl) {
        console.log('❌ [VOUCHER] No modal found');
        return;
    }
    
    console.log('✅ [VOUCHER] Modal found, scheduleId:', modalEl.dataset.scheduleId);
    
    // Load voucher lần đầu
    loadVouchers(0);
    
    // Theo dõi sự thay đổi ghế được chọn
    modalEl.addEventListener('click', function(e) {
        if (e.target.closest('.seat')) {
            setTimeout(() => {
                const total = calculateBaseTotal();
                console.log('🔄 [VOUCHER] Seat change detected, new total:', total);
                loadVouchers(total);
                
                // Reset voucher nếu tổng tiền thay đổi
                if (window.selectedVoucher) {
                    console.log('🔄 [VOUCHER] Resetting voucher due to seat change');
                    document.querySelectorAll('.voucher-item').forEach(v => v.classList.remove('selected'));
                    window.selectedVoucher = null;
                    window.appliedDiscount = 0;
                    updateTotalDisplay(total);
                }
            }, 100);
        }
    });
};

// Hàm tính tổng tiền gốc
function calculateBaseTotal() {
    const modalEl = document.querySelector('.seat-modal-content');
    if (!modalEl) return 0;
    
    let total = 0;
    modalEl.querySelectorAll('.seat.selected').forEach(seat => {
        total += parseFloat(seat.dataset.seatPrice) || 0;
    });
    return total;
}

// Hàm cập nhật hiển thị tổng tiền
function updateTotalDisplay(total) {
    const modalEl = document.querySelector('.seat-modal-content');
    if (!modalEl) return;
    
    const totalAmountElement = modalEl.querySelector('#totalAmount');
    if (totalAmountElement) {
        totalAmountElement.textContent = total.toLocaleString();
    }
}

// Hàm tải voucher
function loadVouchers(totalAmount) {
    const modalEl = document.querySelector('.seat-modal-content');
    if (!modalEl) return;

    const voucherContainer = document.getElementById('voucherContainer');
    if (!voucherContainer) return;

    // Lấy movieId từ URL
    const urlParams = new URLSearchParams(window.location.search);
    const movieId = urlParams.get('id');
    
    if (!movieId) {
        voucherContainer.innerHTML = '<div class="no-vouchers">Không thể xác định phim</div>';
        return;
    }

    const contextPath = modalEl.dataset.contextPath || '';
    const url = contextPath + '/voucher-ajax?movieId=' + movieId + '&totalAmount=' + totalAmount;
    
    console.log('📡 [VOUCHER] Fetching vouchers for movieId:', movieId, 'total:', totalAmount);

    // Hiển thị loading
    voucherContainer.innerHTML = '<div class="voucher-loading"><i class="fas fa-spinner fa-spin"></i> Đang tải khuyến mãi...</div>';

    fetch(url)
        .then(response => {
            if (!response.ok) throw new Error('Network error');
            return response.text();
        })
        .then(html => {
            voucherContainer.innerHTML = html;
            attachVoucherEvents();
        })
        .catch(error => {
            console.error('❌ [VOUCHER] Error:', error);
            voucherContainer.innerHTML = '<div class="no-vouchers">Lỗi tải khuyến mãi</div>';
        });
}

// Gắn sự kiện cho voucher items
function attachVoucherEvents() {
    document.querySelectorAll('.voucher-item').forEach(item => {
        item.addEventListener('click', function() {
            // Bỏ chọn tất cả
            document.querySelectorAll('.voucher-item').forEach(v => v.classList.remove('selected'));
            
            // Chọn voucher này
            this.classList.add('selected');
            
            // Lấy thông tin voucher
            const voucherData = {
                id: this.dataset.voucherId,
                code: this.dataset.voucherCode,
                discountType: parseInt(this.dataset.discountType),
                discountValue: parseFloat(this.dataset.discountValue),
                maxDiscount: parseFloat(this.dataset.maxDiscount) || 0,
                minOrder: parseFloat(this.dataset.minOrder) || 0
            };
            
            console.log('💳 [VOUCHER] Selected:', voucherData.code);
            
            // Cập nhật tổng tiền
            updateTotalWithVoucher(voucherData);
        });
    });
}

// Cập nhật tổng tiền với voucher
function updateTotalWithVoucher(voucher) {
    const baseTotal = calculateBaseTotal();
    
    if (baseTotal < voucher.minOrder) {
        showToast(`Voucher ${voucher.code} yêu cầu đơn tối thiểu ${voucher.minOrder.toLocaleString()}₫`);
        document.querySelectorAll('.voucher-item').forEach(v => v.classList.remove('selected'));
        window.selectedVoucher = null;
        window.appliedDiscount = 0;
        updateTotalDisplay(baseTotal);
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
    
    updateTotalDisplay(finalTotal);
    window.selectedVoucher = voucher;
    window.appliedDiscount = discountAmount;
    
    console.log('💰 [VOUCHER] Applied discount:', discountAmount, 'Final total:', finalTotal);
}

// Hàm debug
window.debugVoucher = function() {
    console.log('🔍 Voucher Debug:');
    console.log('Selected:', window.selectedVoucher);
    console.log('Discount:', window.appliedDiscount);
    console.log('Total:', calculateBaseTotal());
};

// Hàm load voucher trực tiếp (fallback)
window.loadVouchersDirectlyUltimate = function(totalAmount = 0) {
    console.log('📥 [DIRECT] Loading vouchers directly...');
    
    const modalEl = document.querySelector('.seat-modal-content');
    if (!modalEl) {
        console.log('❌ [DIRECT] No modal found');
        return;
    }

    const voucherContainer = document.getElementById('voucherContainer');
    if (!voucherContainer) {
        console.log('❌ [DIRECT] No voucher container found');
        return;
    }

    // Lấy movieId từ URL
    const urlParams = new URLSearchParams(window.location.search);
    const movieId = urlParams.get('id');
    
    if (!movieId) {
        console.log('❌ [DIRECT] No movieId found');
        voucherContainer.innerHTML = '<div class="no-vouchers">Không thể xác định phim</div>';
        return;
    }

    const contextPath = modalEl.dataset.contextPath || '';
    const url = contextPath + '/voucher-ajax?movieId=' + movieId + '&totalAmount=' + totalAmount;
    
    console.log('📡 [DIRECT] Fetching vouchers from:', url);

    // Hiển thị loading
    voucherContainer.innerHTML = '<div class="voucher-loading"><i class="fas fa-spinner fa-spin"></i> Đang tải khuyến mãi...</div>';

    fetch(url)
        .then(response => {
            if (!response.ok) throw new Error('Network error: ' + response.status);
            return response.text();
        })
        .then(html => {
            console.log('✅ [DIRECT] Vouchers loaded successfully, length:', html.length);
            voucherContainer.innerHTML = html;
            attachVoucherEvents();
        })
        .catch(error => {
            console.error('❌ [DIRECT] Error loading vouchers:', error);
            voucherContainer.innerHTML = '<div class="no-vouchers">Lỗi tải khuyến mãi: ' + error.message + '</div>';
        });
};

// ========== AUTO-INITIALIZATION ==========
console.log("🚀 Voucher auto-initialization started");

// Khởi tạo tự động khi modal được load
function initializeVoucherWhenReady() {
    console.log('🔍 Checking for modal...');
    
    const modalEl = document.querySelector('.seat-modal-content');
    if (modalEl) {
        console.log('✅ Modal found, initializing voucher system');
        
        // Sử dụng hàm nào có sẵn
        if (typeof initializeVoucherSystem === 'function') {
            setTimeout(initializeVoucherSystem, 300);
        } else if (typeof loadVouchersDirectlyUltimate === 'function') {
            setTimeout(() => loadVouchersDirectlyUltimate(0), 300);
        } else {
            console.log('❌ No voucher functions available');
        }
    } else {
        console.log('👀 No modal yet, waiting...');
        // Theo dõi sự xuất hiện của modal
        const modalObserver = new MutationObserver(function(mutations) {
            mutations.forEach(function(mutation) {
                mutation.addedNodes.forEach(function(node) {
                    if (node.nodeType === 1) {
                        const modal = node.classList && node.classList.contains('seat-modal-content') 
                            ? node 
                            : node.querySelector && node.querySelector('.seat-modal-content');
                        
                        if (modal) {
                            console.log('🎯 Modal detected via MutationObserver');
                            setTimeout(() => {
                                if (typeof initializeVoucherSystem === 'function') {
                                    initializeVoucherSystem();
                                } else if (typeof loadVouchersDirectlyUltimate === 'function') {
                                    loadVouchersDirectlyUltimate(0);
                                }
                            }, 300);
                            modalObserver.disconnect();
                        }
                    }
                });
            });
        });
        
        modalObserver.observe(document.body, {
            childList: true,
            subtree: true
        });
    }
}

// Bắt đầu khởi tạo
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeVoucherWhenReady);
} else {
    initializeVoucherWhenReady();
}

console.log('✅ Voucher system ready for initialization');
