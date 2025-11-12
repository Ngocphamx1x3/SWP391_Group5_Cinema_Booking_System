(function () {
    console.log("🎬 seat-modal.js loaded - FIXED VERSION");
    const MAX_SELECTED = 8;
    
    // ========== GLOBAL VARIABLES ==========
    window.selectedVoucher = null;
    window.appliedDiscount = 0;
    
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
        if (existing) existing.remove();
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
    function buildRowState(modalEl, extraSelection) {
        const rows = new Map();
        modalEl.querySelectorAll('.seat').forEach(el => {
            const row = el.dataset.row;
            const col = parseInt(el.dataset.col || '0', 10);
            if (!row || !col) return;
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

    function violatesSingleGap(modalEl, extraSelection) {
        const rows = buildRowState(modalEl, extraSelection);
        for (const [, data] of rows.entries()) {
            const {present, occupied, selected, minCol, maxCol} = data;
            const isTaken = (c) => occupied.has(c) || selected.has(c);
            for (let c = minCol; c <= maxCol; c++) {
                if (!present.has(c)) continue;
                if (isTaken(c)) continue;
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
        if (!seat) return;

        const modalEl = seat.closest('.seat-modal-content');
        if (!modalEl) return;

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

        seat.classList.remove('selected');
        if (violatesSingleGap(modalEl, null)) {
            seat.classList.add('selected');
            showToast('⚠️ Bỏ ghế này sẽ tạo 1 ghế lẻ ở giữa. Vui lòng chọn ghế khác.');
            return;
        }
        recalcAndRender(modalEl);
    });

    // ========== XÁC NHẬN VÀ CHUYỂN SANG FOODCOMBO ==========
    // CRITICAL: Use capture phase and stop propagation to override all other handlers
    document.addEventListener('click', function (e) {
        const btn = e.target.closest('.confirm-btn#confirmBtn');
        if (!btn) return;
        
        // STOP ALL OTHER HANDLERS
        e.preventDefault();
        e.stopPropagation();
        e.stopImmediatePropagation();

        const modalEl = btn.closest('.seat-modal-content');
        if (!modalEl) return;

        if (violatesSingleGap(modalEl, null)) {
            showToast('⚠️ Không được để trống 1 ghế lẻ ở giữa trong hàng.');
            return;
        }

        const seatIds = modalEl.dataset.selectedSeatIds || '';
        const scheduleId = modalEl.dataset.scheduleId;
        const contextPath = modalEl.dataset.contextPath || '';

        console.log('🚀 ========== CONFIRM BUTTON CLICKED ==========');
        console.log('📋 Basic Info:');
        console.log('  - scheduleId:', scheduleId);
        console.log('  - seatIds:', seatIds);

        if (!scheduleId) {
            alert('Lỗi: Không tìm thấy thông tin lịch chiếu!');
            return;
        }
        if (!seatIds) {
            alert('Vui lòng chọn ít nhất một ghế!');
            return;
        }

        // ========== TÍNH GIÁ ==========
        const baseTotal = calculateBaseTotal();
        
        // Lấy finalTotal từ hiển thị (có thể đã có voucher)
        const displayTotalElement = document.getElementById('totalAmount');
        let finalTotal = baseTotal; // Mặc định = baseTotal
        
        if (displayTotalElement) {
            const displayText = displayTotalElement.textContent.replace(/[^\d]/g, '');
            const displayValue = parseInt(displayText) || 0;
            if (displayValue > 0) {
                finalTotal = displayValue;
            }
        }

        console.log('💰 Price Info:');
        console.log('  - baseTotal (original):', baseTotal);
        console.log('  - finalTotal (displayed):', finalTotal);

        // ========== KIỂM TRA VOUCHER ==========
        console.log('🎫 Voucher Check:');
        console.log('  - window.selectedVoucher:', window.selectedVoucher);
        console.log('  - window.appliedDiscount:', window.appliedDiscount);

        const hasVoucher = window.selectedVoucher && window.appliedDiscount > 0;
        
        if (hasVoucher) {
            console.log('✅ VOUCHER DETECTED!');
            console.log('  - Voucher ID:', window.selectedVoucher.id);
            console.log('  - Voucher Code:', window.selectedVoucher.code);
            console.log('  - Discount Amount:', window.appliedDiscount);
        } else {
            console.log('❌ NO VOUCHER FOUND');
            console.log('  - window.selectedVoucher is:', window.selectedVoucher);
            console.log('  - window.appliedDiscount is:', window.appliedDiscount);
        }

        // ========== TẠO URL ==========
        let comboUrl = contextPath + '/views/users/FoodCombo.jsp?' +
                       'scheduleId=' + scheduleId +
                       '&seatIds=' + encodeURIComponent(seatIds) +
                       '&totalAmount=' + finalTotal +
                       '&originalAmount=' + baseTotal;

        console.log('🔗 Base URL created:', comboUrl);

        // ========== THÊM VOUCHER VÀO URL ==========
        if (hasVoucher) {
            const voucherId = window.selectedVoucher.id;
            const voucherCode = window.selectedVoucher.code;
            const discountAmount = window.appliedDiscount;
            
            comboUrl += '&voucherId=' + voucherId +
                       '&voucherCode=' + encodeURIComponent(voucherCode) +
                       '&discountAmount=' + discountAmount;
            
            console.log('✅ VOUCHER ADDED TO URL:');
            console.log('  - voucherId:', voucherId);
            console.log('  - voucherCode:', voucherCode);
            console.log('  - discountAmount:', discountAmount);
        } else {
            console.log('ℹ️ No voucher to add to URL');
        }

        console.log('🔗 FINAL URL:', comboUrl);
        console.log('========== REDIRECTING ==========');
        
        // Chuyển hướng
        window.location.href = comboUrl;
        
        return false; // Prevent default
    }, true); // USE CAPTURE PHASE!

    window.initSeatModalIfNeeded = function (container) {
        const modalEl = (typeof container === 'string') ? document.querySelector(container) : container;
        if (modalEl && modalEl.classList.contains('seat-modal-content')) {
            recalcAndRender(modalEl);
        }
    };
})();

// ========== VOUCHER SYSTEM ==========
console.log("🎫 VOUCHER SYSTEM - Initializing");

function calculateBaseTotal() {
    const modalEl = document.querySelector('.seat-modal-content');
    if (!modalEl) return 0;
    
    let total = 0;
    modalEl.querySelectorAll('.seat.selected').forEach(seat => {
        total += parseFloat(seat.dataset.seatPrice) || 0;
    });
    return total;
}

function updateTotalDisplay(total) {
    const modalEl = document.querySelector('.seat-modal-content');
    if (!modalEl) return;
    
    const totalAmountElement = modalEl.querySelector('#totalAmount');
    if (totalAmountElement) {
        totalAmountElement.textContent = total.toLocaleString();
    }
    
    if (modalEl) {
        modalEl.dataset.totalAmount = String(total);
    }
}

function loadVouchers(totalAmount) {
    const modalEl = document.querySelector('.seat-modal-content');
    if (!modalEl) return;

    const voucherContainer = document.getElementById('voucherContainer');
    if (!voucherContainer) return;

    const urlParams = new URLSearchParams(window.location.search);
    const movieId = urlParams.get('id');
    
    if (!movieId) {
        voucherContainer.innerHTML = '<div class="no-vouchers">Không thể xác định phim</div>';
        return;
    }

    const contextPath = modalEl.dataset.contextPath || '';
    const url = contextPath + '/voucher-ajax?movieId=' + movieId + '&totalAmount=' + totalAmount;
    
    console.log('📡 [VOUCHER] Fetching vouchers for movieId:', movieId, 'total:', totalAmount);

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

function attachVoucherEvents() {
    console.log('🎯 Attaching voucher events...');
    
    document.querySelectorAll('.voucher-item').forEach(item => {
        item.addEventListener('click', function() {
            console.log('🎫 Voucher item clicked');
            
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
            
            console.log('💳 [VOUCHER] Selected voucher:', voucherData);
            
            // Áp dụng voucher
            updateTotalWithVoucher(voucherData);
        });
    });
}

function updateTotalWithVoucher(voucher) {
    console.log('💰 [VOUCHER] Applying voucher...');
    
    const baseTotal = calculateBaseTotal();
    
    console.log('  - Base total:', baseTotal);
    console.log('  - Min order:', voucher.minOrder);
    
    if (baseTotal < voucher.minOrder) {
        console.log('❌ Order total too low for voucher');
        alert(`Voucher ${voucher.code} yêu cầu đơn tối thiểu ${voucher.minOrder.toLocaleString()}₫`);
        document.querySelectorAll('.voucher-item').forEach(v => v.classList.remove('selected'));
        window.selectedVoucher = null;
        window.appliedDiscount = 0;
        updateTotalDisplay(baseTotal);
        return;
    }
    
    let discountAmount = 0;
    
    if (voucher.discountType === 1) {
        // Phần trăm
        discountAmount = baseTotal * (voucher.discountValue / 100);
        if (voucher.maxDiscount > 0 && discountAmount > voucher.maxDiscount) {
            discountAmount = voucher.maxDiscount;
        }
    } else {
        // Số tiền cố định
        discountAmount = voucher.discountValue;
    }
    
    const finalTotal = Math.max(0, baseTotal - discountAmount);
    
    console.log('✅ [VOUCHER] Discount calculated:');
    console.log('  - Discount amount:', discountAmount);
    console.log('  - Final total:', finalTotal);
    
    // Cập nhật hiển thị
    updateTotalDisplay(finalTotal);
    
    // ========== QUAN TRỌNG: LƯU VÀO BIẾN TOÀN CỤC ==========
    window.selectedVoucher = voucher;
    window.appliedDiscount = discountAmount;
    
    console.log('💾 [VOUCHER] SAVED TO GLOBAL:');
    console.log('  - window.selectedVoucher:', window.selectedVoucher);
    console.log('  - window.appliedDiscount:', window.appliedDiscount);
}

function initializeVoucherSystem() {
    console.log('🎬 [VOUCHER] Initializing voucher system...');
    
    const modalEl = document.querySelector('.seat-modal-content');
    if (!modalEl) {
        console.log('❌ [VOUCHER] No modal found');
        return;
    }
    
    console.log('✅ [VOUCHER] Modal found, scheduleId:', modalEl.dataset.scheduleId);
    
    // Load vouchers ban đầu
    loadVouchers(0);
    
    // Theo dõi sự thay đổi ghế
    modalEl.addEventListener('click', function(e) {
        if (e.target.closest('.seat')) {
            setTimeout(() => {
                const total = calculateBaseTotal();
                console.log('🔄 [VOUCHER] Seat change detected, new total:', total);
                loadVouchers(total);
                
                // Reset voucher khi ghế thay đổi
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
}

function initializeVoucherWhenReady() {
    console.log('🔍 Waiting for modal...');
    
    const checkModal = () => {
        const modalEl = document.querySelector('.seat-modal-content');
        if (modalEl) {
            console.log('✅ Modal found, initializing voucher system');
            setTimeout(initializeVoucherSystem, 500);
        } else {
            console.log('👀 No modal yet, observing...');
            const observer = new MutationObserver(function(mutations) {
                mutations.forEach(function(mutation) {
                    mutation.addedNodes.forEach(function(node) {
                        if (node.nodeType === 1) {
                            const modal = node.classList && node.classList.contains('seat-modal-content') 
                                ? node 
                                : node.querySelector && node.querySelector('.seat-modal-content');
                            
                            if (modal) {
                                console.log('🎯 Modal detected!');
                                setTimeout(initializeVoucherSystem, 500);
                                observer.disconnect();
                            }
                        }
                    });
                });
            });
            
            observer.observe(document.body, {
                childList: true,
                subtree: true
            });
        }
    };
    
    checkModal();
}

if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeVoucherWhenReady);
} else {
    initializeVoucherWhenReady();
}

// ========== DEBUG FUNCTIONS ==========
window.debugVoucher = function() {
    console.log('=== VOUCHER DEBUG ===');
    console.log('selectedVoucher:', window.selectedVoucher);
    console.log('appliedDiscount:', window.appliedDiscount);
    console.log('baseTotal:', calculateBaseTotal());
    
    const displayElement = document.getElementById('totalAmount');
    if (displayElement) {
        console.log('displayTotal:', displayElement.textContent);
    }
};

console.log('✅ Voucher system ready');