// ========== VOUCHER SYSTEM (STANDALONE) ==========
console.log("🎫 VOUCHER SYSTEM loaded");

// Biến toàn cục
window.selectedVoucher = null;
window.appliedDiscount = 0;

// Hàm khởi tạo voucher system độc lập
window.initializeVoucherSystem = function() {
    console.log('🎬 [VOUCHER] Initializing standalone voucher system...');
    
    const modalEl = document.querySelector('.seat-modal-content');
    if (!modalEl) {
        console.log('❌ [VOUCHER] No modal found, retrying...');
        setTimeout(initializeVoucherSystem, 500);
        return;
    }
    
    console.log('✅ [VOUCHER] Modal found');
    
    // Load voucher lần đầu
    loadVouchers(0);
    
    // Lắng nghe sự kiện chọn ghế từ hệ thống cũ
    const originalRecalc = window.recalcAndRender;
    if (originalRecalc) {
        window.recalcAndRender = function(modalEl) {
            // Gọi hàm gốc
            originalRecalc(modalEl);
            
            // Cập nhật voucher sau khi tính toán xong
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
        };
    }
};

// Hàm tính tổng tiền gốc (tương thích với hệ thống cũ)


function calculateBaseTotalForVoucher() {
    let total = 0;
    document.querySelectorAll('.seat.selected').forEach(seat => {
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
        showVoucherToast(`Voucher ${voucher.code} yêu cầu đơn tối thiểu ${voucher.minOrder.toLocaleString()}₫`);
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

// Hàm hiển thị thông báo cho voucher
function showVoucherToast(msg) {
    // Sử dụng hệ thống toast có sẵn hoặc tạo mới
    if (typeof showToast === 'function') {
        showToast(msg);
    } else {
        // Fallback: tạo toast đơn giản
        const toast = document.createElement('div');
        toast.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            background: #ff4444;
            color: white;
            padding: 10px 15px;
            border-radius: 5px;
            z-index: 10000;
        `;
        toast.textContent = msg;
        document.body.appendChild(toast);
        setTimeout(() => toast.remove(), 3000);
    }
}

// Hàm debug
window.debugVoucher = function() {
    console.log('🔍 Voucher Debug:');
    console.log('Selected:', window.selectedVoucher);
    console.log('Discount:', window.appliedDiscount);
    console.log('Total:', calculateBaseTotal());
};

// Tự động khởi tạo khi DOM sẵn sàng
document.addEventListener('DOMContentLoaded', function() {
    console.log('🚀 Voucher system waiting for modal...');
    
    // Kiểm tra định kỳ cho đến khi modal xuất hiện
    const checkModal = setInterval(() => {
        const modalEl = document.querySelector('.seat-modal-content');
        if (modalEl) {
            clearInterval(checkModal);
            console.log('🎯 Modal found, initializing voucher system');
            setTimeout(initializeVoucherSystem, 1000);
        }
    }, 500);
});