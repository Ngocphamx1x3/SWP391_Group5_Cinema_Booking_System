// /assets/user/js/seat-modal.js
(function () {
    console.log("🎬 seat-modal.js loaded");
    const MAX_SELECTED = 8;

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
        if (!btn)
            return;

        const modalEl = btn.closest('.seat-modal-content');
        if (!modalEl)
            return;

        if (violatesSingleGap(modalEl, null)) {
            showToast('⚠️ Không được để trống 1 ghế lẻ ở giữa trong hàng.');
            return;
        }

        const seatIds = modalEl.dataset.selectedSeatIds || '';
        const totalAmount = modalEl.dataset.totalAmount || '0';
        const scheduleId = modalEl.dataset.scheduleId;
        const contextPath = modalEl.dataset.contextPath || '';

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

        // Tạo form POST tới /checkout (đúng với CheckoutController.doPost)
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = `${contextPath}/checkout`;

        const f1 = document.createElement('input');
        f1.type = 'hidden';
        f1.name = 'scheduleId';
        f1.value = String(scheduleId);
        form.appendChild(f1);

        const f2 = document.createElement('input');
        f2.type = 'hidden';
        f2.name = 'seatIds';
        f2.value = seatIds;
        form.appendChild(f2);

        const f3 = document.createElement('input');
        f3.type = 'hidden';
        f3.name = 'totalAmount';
        f3.value = String(totalAmount);
        form.appendChild(f3);

        document.body.appendChild(form);
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
