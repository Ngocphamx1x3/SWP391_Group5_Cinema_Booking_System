<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.FoodCombo, java.util.List"%>
<%@page import="dal.FoodComboDAO"%>
<%!
    private boolean isValidImageFile(String imageName) {
        if (imageName == null || imageName.trim().isEmpty()) return false;
        String lower = imageName.toLowerCase();
        return lower.endsWith(".jpg") || lower.endsWith(".jpeg") || 
               lower.endsWith(".png") || lower.endsWith(".gif") || 
               lower.endsWith(".webp") || lower.endsWith(".svg");
    }
%>
<%
    // Nhận thông tin vé từ URL params (từ seat-modal.js)
    String scheduleId = request.getParameter("scheduleId");
    String seatIds = request.getParameter("seatIds");
    String totalAmount = request.getParameter("totalAmount");
    
    // THÊM: Nhận thông tin voucher
    String voucherId = request.getParameter("voucherId");
    String voucherCode = request.getParameter("voucherCode");
    String discountAmount = request.getParameter("discountAmount");
    String originalAmount = request.getParameter("originalAmount");
    
    // Lưu vào request attribute để JavaScript có thể truy cập
    if (scheduleId != null) request.setAttribute("scheduleId", scheduleId);
    if (seatIds != null) request.setAttribute("seatIds", seatIds);
    if (totalAmount != null) request.setAttribute("totalAmount", totalAmount);
    if (voucherId != null) request.setAttribute("voucherId", voucherId);
    if (voucherCode != null) request.setAttribute("voucherCode", voucherCode);
    if (discountAmount != null) request.setAttribute("discountAmount", discountAmount);
    if (originalAmount != null) request.setAttribute("originalAmount", originalAmount);
    
    // DEBUG: In ra thông tin voucher
    System.out.println("[FOOD COMBO DEBUG] Voucher info:");
    System.out.println("  - voucherId: " + voucherId);
    System.out.println("  - voucherCode: " + voucherCode);
    System.out.println("  - discountAmount: " + discountAmount);
    System.out.println("  - originalAmount: " + originalAmount);
    System.out.println("  - totalAmount: " + totalAmount);
    
    List<FoodCombo> foodCombos = (List<FoodCombo>) request.getAttribute("foodCombos");
    if (foodCombos == null) {
        FoodComboDAO fcDao = new FoodComboDAO();
        foodCombos = fcDao.getActiveFoodCombos();
        request.setAttribute("foodCombos", foodCombos);
    }
    int pageSize = 9;
    int totalItems = (foodCombos != null) ? foodCombos.size() : 0;
    int totalPages = Math.max(1, (int) Math.ceil(totalItems / (double) pageSize));
    int currentPage = 1;
    try {
        String pageParam = request.getParameter("page");
        if (pageParam != null) currentPage = Integer.parseInt(pageParam);
    } catch (Exception ignore) {}
    currentPage = Math.max(1, Math.min(currentPage, totalPages));
    int startIndex = (currentPage - 1) * pageSize;
    int endIndex = Math.min(startIndex + pageSize, totalItems);
    request.setAttribute("pageTitle", "Chọn Combo");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chọn Combo | Cinema Booking</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/user/css/web.css">
    <link rel="icon" href="${pageContext.request.contextPath}/assets/user/img/logo.png" type="image/x-icon"/>
    <style>
        body {
            background: #f8fafc;
            font-family: 'Inter', sans-serif;
            color: #1e293b;
        }

        .container {
            max-width: 1180px;
            margin: 0 auto;
            padding: 32px 24px;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .toolbar {
            background: #fff;
            border-radius: 16px;
            padding: 16px 20px;
            display: flex;
            justify-content: space-between;
            flex-wrap: wrap;
            align-items: center;
            gap: 12px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.06);
            margin-bottom: 28px;
            width: 100%;
        }

        .search-box {
            display: flex;
            flex: 1;
            gap: 8px;
            min-width: 260px;
        }

        .search-box input {
            flex: 1;
            border: 1px solid #cbd5e1;
            border-radius: 10px;
            padding: 10px 14px;
            font-size: 14px;
            outline: none;
            transition: 0.2s;
        }

        .search-box input:focus {
            border-color: #3b82f6;
            box-shadow: 0 0 0 3px rgba(59,130,246,0.2);
        }

        .btn {
            background: linear-gradient(135deg, #3b82f6, #2563eb);
            color: white;
            border: none;
            border-radius: 10px;
            padding: 9px 16px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 14px rgba(37,99,235,0.25);
        }

        .btn-ghost {
            background: white;
            color: #2563eb;
            border: 2px solid #3b82f6;
            border-radius: 10px;
            padding: 9px 16px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
            text-decoration: none;
            display: inline-block;
        }

        .btn-ghost:hover {
            background: #eff6ff;
            border-color: #2563eb;
            color: #1e40af;
            transform: translateY(-1px);
            box-shadow: 0 4px 8px rgba(59, 130, 246, 0.15);
        }

        .btn-ghost:active {
            transform: translateY(0);
            box-shadow: 0 2px 4px rgba(59, 130, 246, 0.1);
        }

        .content-wrap {
            display: grid;
            grid-template-columns: 1.7fr 1fr;
            gap: 20px;
            width: 100%;
            max-width: 100%;
            align-items: start;
        }

        .card {
            background: #fff;
            border-radius: 16px;
            padding: 20px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.05);
            width: 100%;
        }

        .card:first-child {
            max-width: 100%;
            margin-right: 0;
            padding: 18px;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(235px, 1fr));
            gap: 16px;
            justify-items: center;
        }

        .combo-item {
            background: #f9fafb;
            border-radius: 16px;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            width: 100%;
            transition: 0.2s ease;
        }

        .combo-item:hover {
            transform: translateY(-3px);
            box-shadow: 0 6px 12px rgba(0,0,0,0.08);
        }

        .combo-thumb {
            width: 100%;
            height: 160px;
            object-fit: cover;
            background: #e2e8f0;
        }

        .combo-body {
            padding: 14px 16px;
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .combo-title {
            font-weight: 700;
            font-size: 15px;
            color: #0f172a;
        }

        .combo-desc {
            font-size: 13px;
            color: #64748b;
            line-height: 1.5;
            min-height: 36px;
        }

        .combo-actions {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 10px;
        }

        .combo-price {
            font-weight: 700;
            color: #16a34a;
            font-size: 15px;
        }

        .qty {
            display: inline-flex;
            align-items: center;
            border: 1px solid #e2e8f0;
            border-radius: 10px;
            overflow: hidden;
        }

        .qty button {
            background: #f1f5f9;
            border: none;
            padding: 6px 10px;
            font-weight: bold;
            cursor: pointer;
        }

        .qty input {
            width: 40px;
            border: none;
            text-align: center;
            padding: 6px 0;
            outline: none;
        }

        .cart {
            position: sticky;
            top: 24px;
            display: flex;
            flex-direction: column;
            gap: 12px;
            height: fit-content;
            max-width: 100%;
        }

        .cart-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .cart-list {
            display: flex;
            flex-direction: column;
            gap: 10px;
            max-height: 420px;
            overflow-y: auto;
        }

        .cart-item {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 10px;
            padding: 10px 12px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
        }
        
        .cart-item-info {
            flex: 1;
            min-width: 0;
        }

        .cart-item-title { 
            font-weight: 600; 
            font-size: 14px; 
            color: #0f172a;
            margin-bottom: 4px;
            word-wrap: break-word;
        }
        
        .cart-item-sub { 
            font-size: 12px; 
            color: #6b7280; 
        }
        
        .cart-item-actions {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .cart-item-price {
            font-weight: 600;
            color: #16a34a;
            font-size: 14px;
            white-space: nowrap;
        }
        
        .btn-remove {
            background: #ef4444;
            color: white;
            border: none;
            border-radius: 6px;
            padding: 4px 8px;
            font-size: 12px;
            cursor: pointer;
            transition: all 0.2s;
            white-space: nowrap;
        }
        
        .btn-remove:hover {
            background: #dc2626;
            transform: scale(1.05);
        }
        
        .btn-remove:active {
            transform: scale(0.95);
        }

        .cart-total {
            display: flex;
            justify-content: space-between;
            font-weight: 700;
            font-size: 15px;
            border-top: 1px solid #e2e8f0;
            padding-top: 10px;
        }

        .empty {
            text-align: center;
            color: #94a3b8;
            padding: 20px;
            border: 1px dashed #cbd5e1;
            border-radius: 12px;
        }

        @media (max-width: 1024px) {
            .content-wrap { 
                grid-template-columns: 1fr; 
                gap: 24px;
            }
            .cart { 
                position: static; 
                max-width: 100%;
            }
            .container {
                max-width: 100%;
                padding: 24px 16px;
            }
        }

        @media (min-width: 1025px) and (max-width: 1400px) {
            .container {
                max-width: 1120px;
            }
            .content-wrap {
                grid-template-columns: 1.65fr 1fr;
                gap: 18px;
            }
        }

        @media (min-width: 1401px) {
            .container {
                max-width: 1180px;
            }
        }

        .pagination {
            display: flex;
            gap: 8px;
            align-items: center;
            justify-content: center;
            margin-top: 16px;
            flex-wrap: wrap;
        }

        .page-link {
            padding: 8px 12px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            text-decoration: none;
            color: #334155;
            background: #fff;
        }

        .page-link.active {
            background: #2563eb;
            color: #fff;
            border-color: #2563eb;
        }

        .page-info {
            text-align: center;
            color: #64748b;
            margin-top: 8px;
        }
    </style>
</head>
<body>
<jsp:include page="/views/layout/Header.jsp"/>

<div class="container">
    <div class="toolbar">
        <div class="search-box">
            <input type="text" id="keyword" placeholder="Tìm kiếm combo popcorn, drink, snack...">
            <button id="btnSearch" class="btn">Tìm</button>
            <button id="btnReset" class="btn-ghost">Reset</button>
        </div>
        <a href="${pageContext.request.contextPath}/" class="btn-ghost">Trang chủ</a>
    </div>

    <div class="content-wrap">
        <div class="card">
            <h3 style="margin-bottom: 16px;">Danh sách Combo</h3>
            <div id="comboGrid" class="grid">
                <% if (foodCombos != null && !foodCombos.isEmpty()) { 
                    for (int i = startIndex; i < endIndex; i++) { 
                        FoodCombo c = foodCombos.get(i);
                        String comboName = c.getName() != null ? c.getName().replace("\"", "&quot;").replace("'", "&#39;") : "Combo";
                        double comboPrice = c.getPrice();
                        int comboId = c.getComboID();
                %>
                    <div class="combo-item" 
                         data-name="<%= comboName %>"
                         data-price="<%= String.format("%.0f", comboPrice) %>" 
                         data-id="<%= comboId %>">
                        <% if (isValidImageFile(c.getImage())) { %>
                            <img class="combo-thumb"
                                 src="${pageContext.request.contextPath}/assets/user/img/<%= c.getImage() %>"
                                 alt="<%= comboName %>"
                                 onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                            <div class="combo-thumb" style="display:none;align-items:center;justify-content:center;color:#64748b;">Không có ảnh</div>
                        <% } else { %>
                            <div class="combo-thumb" style="display:flex;align-items:center;justify-content:center;color:#64748b;">Không có ảnh</div>
                        <% } %>
                        <div class="combo-body">
                            <div class="combo-title"><%= comboName %></div>
                            <div class="combo-desc"><%= c.getDescription() != null ? c.getDescription() : "Combo đồ ăn/uống" %></div>
                            <div class="combo-actions">
                                <div class="combo-price"><%= c.getFormattedPrice() %></div>
                                <div style="display:flex;align-items:center;gap:8px;">
                                    <div class="qty">
                                        <button class="btnDec" type="button">-</button>
                                        <input type="number" class="qtyInput" value="1" min="1" inputmode="numeric">
                                        <button class="btnInc" type="button">+</button>
                                    </div>
                                    <button class="btn btnAdd" type="button">Thêm</button>
                                </div>
                            </div>
                        </div>
                    </div>
                <% } } else { %>
                    <div class="empty" style="grid-column:1/-1;">Chưa có combo nào để hiển thị</div>
                <% } %>
            </div>
            <% if (foodCombos != null && totalItems > 0) { %>
            <div class="pagination">
                <%
                    String baseUrl = request.getRequestURI();
                    int prev = (currentPage > 1) ? currentPage - 1 : 1;
                    int next = (currentPage < totalPages) ? currentPage + 1 : totalPages;
                %>
                <a class="page-link" href="<%= baseUrl %>?page=<%= prev %>">« Trước</a>
                <% for (int pIndex = 1; pIndex <= totalPages; pIndex++) { %>
                    <a class="page-link <%= (pIndex==currentPage?"active":"") %>" href="<%= baseUrl %>?page=<%= pIndex %>"><%= pIndex %></a>
                <% } %>
                <a class="page-link" href="<%= baseUrl %>?page=<%= next %>">Sau »</a>
            </div>
            <div class="page-info">Trang <%= currentPage %> / <%= totalPages %></div>
            <% } %>
        </div>

        <div class="cart card" id="cart">
            <div class="cart-header">
                <span style="font-weight:700;">Giỏ hàng</span>
                <button id="btnClear" class="btn-ghost" type="button">Xóa hết</button>
            </div>
            <div id="cartList" class="cart-list">
                <div class="empty">Chưa có sản phẩm nào</div>
            </div>
            <div class="cart-total">
                <span>Tổng</span>
                <span id="cartTotal">0 ₫</span>
            </div>
            <button id="btnCheckout" class="btn" style="margin-top:10px;">Thanh toán</button>
        </div>
    </div>
</div>

<jsp:include page="/views/layout/Footer.jsp"/>

<script>
// Lưu thông tin vé từ server-side vào JavaScript
const seatBookingData = {
    scheduleId: '<%= scheduleId != null ? scheduleId : "" %>',
    seatIds: '<%= seatIds != null ? seatIds : "" %>',
    totalAmount: '<%= totalAmount != null ? totalAmount : "0" %>',
    voucherId: '<%= voucherId != null ? voucherId : "" %>',
    voucherCode: '<%= voucherCode != null ? voucherCode : "" %>',
    discountAmount: '<%= discountAmount != null ? discountAmount : "0" %>',
    originalAmount: '<%= originalAmount != null ? originalAmount : totalAmount != null ? totalAmount : "0" %>'
};

// DEBUG: In ra tất cả thông tin nhận được
console.log("DEBUG seatBookingData:", seatBookingData);
console.log("Breakdown:");
console.log("  - scheduleId:", seatBookingData.scheduleId);
console.log("  - seatIds:", seatBookingData.seatIds);
console.log("  - totalAmount:", seatBookingData.totalAmount, "(Đây phải là giá ĐÃ GIẢM)");
console.log("  - voucherId:", seatBookingData.voucherId);
console.log("  - voucherCode:", seatBookingData.voucherCode);
console.log("  - discountAmount:", seatBookingData.discountAmount);
console.log("  - originalAmount:", seatBookingData.originalAmount);

// Tính toán để kiểm tra
const debugSeatTotal = parseInt(seatBookingData.totalAmount) || 0;
const debugDiscount = parseInt(seatBookingData.discountAmount) || 0;
const debugOriginalSeatAmount = parseInt(seatBookingData.originalAmount) || debugSeatTotal + debugDiscount;

console.log("🧮 Tính toán:");
console.log("  - seatTotal (đã giảm):", debugSeatTotal);
console.log("  - discount:", debugDiscount);
console.log("  - originalSeatAmount (từ URL):", debugOriginalSeatAmount);


// Giỏ hàng combo
let cart = [];

// Khởi tạo
document.addEventListener('DOMContentLoaded', function() {
    updateCartDisplay();
    
    // Xử lý tăng/giảm số lượng
    document.querySelectorAll('.btnInc').forEach(btn => {
        btn.addEventListener('click', function() {
            const input = this.parentElement.querySelector('.qtyInput');
            let val = parseInt(input.value) || 0;
            input.value = Math.max(1, val + 1);
        });
    });
    
    document.querySelectorAll('.btnDec').forEach(btn => {
        btn.addEventListener('click', function() {
            const input = this.parentElement.querySelector('.qtyInput');
            let val = parseInt(input.value) || 0;
            input.value = Math.max(1, val - 1);
        });
    });
    
    // Xử lý thêm vào giỏ
    document.querySelectorAll('.btnAdd').forEach(btn => {
        btn.addEventListener('click', function() {
            const item = this.closest('.combo-item');
            const comboId = parseInt(item.dataset.id);
            const name = item.dataset.name || 'Combo';
            const price = parseFloat(item.dataset.price) || 0;
            const qtyInput = item.querySelector('.qtyInput');
            const quantity = parseInt(qtyInput.value) || 1;
            
            // Validate dữ liệu
            if (!comboId || comboId <= 0) {
                alert('Lỗi: Không tìm thấy thông tin combo');
                return;
            }
            
            if (!name || name.trim() === '') {
                alert('Lỗi: Tên combo không hợp lệ');
                return;
            }
            
            if (price <= 0) {
                alert('Lỗi: Giá combo không hợp lệ');
                return;
            }
            
            if (quantity <= 0) {
                alert('Số lượng phải lớn hơn 0');
                return;
            }
            
            // Kiểm tra đã có trong giỏ chưa
            const existingIndex = cart.findIndex(c => c.comboId === comboId);
            if (existingIndex >= 0) {
                // Nếu đã có, cộng thêm số lượng
                cart[existingIndex].quantity += quantity;
            } else {
                // Nếu chưa có, thêm mới
                cart.push({ 
                    comboId: comboId, 
                    name: name.trim(), 
                    price: price, 
                    quantity: quantity 
                });
            }
            
            // Reset quantity về 1
            qtyInput.value = 1;
            
            // Cập nhật hiển thị
            updateCartDisplay();
            
            // Hiển thị thông báo
            console.log('Đã thêm vào giỏ:', name, 'x', quantity);
        });
    });
    
    // Xử lý xóa hết giỏ
    document.getElementById('btnClear')?.addEventListener('click', function() {
        cart = [];
        updateCartDisplay();
    });
    
    // Xử lý thanh toán
    document.getElementById('btnCheckout')?.addEventListener('click', function() {
        console.log("=== BẮT ĐẦU XỬ LÝ THANH TOÁN ===");
        
        if (!seatBookingData.scheduleId || !seatBookingData.seatIds) {
            console.error("Lỗi: Thiếu thông tin đặt vé");
            alert('Lỗi: Thiếu thông tin đặt vé. Vui lòng quay lại trang chọn ghế.');
            return;
        }
        
        // Disable button để tránh double submit
        this.disabled = true;
        console.log("Button disabled");
        
        // Tính tổng giá combo
        const comboTotal = cart.reduce((sum, item) => {
            const price = parseFloat(item.price) || 0;
            const quantity = parseInt(item.quantity) || 1;
            return sum + (price * quantity);
        }, 0);
        
        console.log("Thông tin giỏ hàng:");
        console.log("  - Số lượng combo:", cart.length);
        console.log("  - Tổng combo:", comboTotal);
        
        // Tính tổng giá vé - sử dụng giá đã giảm từ voucher
        const checkoutSeatTotal = parseInt(seatBookingData.totalAmount) || 0;
        const checkoutDiscountAmount = parseInt(seatBookingData.discountAmount) || 0;
        const checkoutOriginalSeatAmount = parseInt(seatBookingData.originalAmount) || (checkoutSeatTotal + checkoutDiscountAmount);
        
        console.log("Thông tin vé:");
        console.log("  - Vé gốc:", checkoutOriginalSeatAmount);
        console.log("  - Discount:", checkoutDiscountAmount);
        console.log("  - Vé sau discount:", checkoutSeatTotal);
        
        // Tổng cuối cùng (vé đã discount + combo)
        const finalTotal = checkoutSeatTotal + comboTotal;
        
        console.log("Tổng kết:");
        console.log("  - Vé (đã giảm):", checkoutSeatTotal);
        console.log("  - Combo:", comboTotal);
        console.log("  - Tổng thanh toán:", finalTotal);
        
        // Tạo form POST tới /checkout
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = '${pageContext.request.contextPath}/checkout';

        console.log("Tạo form với các field:");

        // Thông tin vé
        const f1 = document.createElement('input');
        f1.type = 'hidden';
        f1.name = 'scheduleId';
        f1.value = seatBookingData.scheduleId;
        form.appendChild(f1);
        console.log("  - scheduleId:", seatBookingData.scheduleId);

        const f2 = document.createElement('input');
        f2.type = 'hidden';
        f2.name = 'seatIds';
        f2.value = seatBookingData.seatIds;
        form.appendChild(f2);
        console.log("  - seatIds:", seatBookingData.seatIds);

        // Gửi totalAmount (tổng vé đã discount + combo)
        const f3 = document.createElement('input');
        f3.type = 'hidden';
        f3.name = 'totalAmount';
        f3.value = String(finalTotal);
        form.appendChild(f3);
        console.log("  - totalAmount (finalTotal):", finalTotal);

        // Gửi originalAmount (giá vé gốc CHƯA discount)
        const f3a = document.createElement('input');
        f3a.type = 'hidden';
        f3a.name = 'originalAmount';
        f3a.value = String(checkoutOriginalSeatAmount);
        form.appendChild(f3a);
        console.log("  - originalAmount:", checkoutOriginalSeatAmount);

        // QUAN TRỌNG: Thêm thông tin voucher vào form
        if (seatBookingData.voucherId && seatBookingData.voucherId !== '') {
    const fVoucherId = document.createElement('input');
    fVoucherId.type = 'hidden';
    fVoucherId.name = 'voucherId';
    fVoucherId.value = seatBookingData.voucherId;
    form.appendChild(fVoucherId);
    console.log("  - voucherId:", seatBookingData.voucherId);
    
    const fVoucherCode = document.createElement('input');
    fVoucherCode.type = 'hidden';
    fVoucherCode.name = 'voucherCode';
    fVoucherCode.value = seatBookingData.voucherCode;
    form.appendChild(fVoucherCode);
    console.log("  - voucherCode:", seatBookingData.voucherCode);
    
    const fDiscount = document.createElement('input');
    fDiscount.type = 'hidden';
    fDiscount.name = 'discountAmount';
    fDiscount.value = seatBookingData.discountAmount || '0';
    form.appendChild(fDiscount);
    console.log("  - discountAmount:", seatBookingData.discountAmount);
    
    console.log("[DEBUG] Voucher data being submitted:");
    console.log("  - voucherId:", seatBookingData.voucherId);
    console.log("  - voucherCode:", seatBookingData.voucherCode);
    console.log("  - discountAmount:", seatBookingData.discountAmount);
} else {
    console.log("  - Không có voucher");
    
    // THÊM: Gửi originalAmount ngay cả khi không có voucher
    const fOriginal = document.createElement('input');
    fOriginal.type = 'hidden';
    fOriginal.name = 'originalAmount';
    fOriginal.value = seatBookingData.originalAmount || seatBookingData.totalAmount;
    form.appendChild(fOriginal);
    console.log("  - originalAmount:", seatBookingData.originalAmount || seatBookingData.totalAmount);
}
        
        // Thông tin combo (nếu có)
        if (cart.length > 0) {
            const comboIds = cart.map(c => c.comboId).join(',');
            const comboQuantities = cart.map(c => c.quantity).join(',');
            
            const f4 = document.createElement('input');
            f4.type = 'hidden';
            f4.name = 'comboIds';
            f4.value = comboIds;
            form.appendChild(f4);
            console.log("  - comboIds:", comboIds);
            
            const f5 = document.createElement('input');
            f5.type = 'hidden';
            f5.name = 'comboQuantities';
            f5.value = comboQuantities;
            form.appendChild(f5);
            console.log("  - comboQuantities:", comboQuantities);
        } else {
            console.log("  - Không có combo");
        }
        
        console.log("Form đã tạo xong, chuẩn bị submit...");
        document.body.appendChild(form);
        form.submit();
        console.log("Form đã submit!");
    });
    
    // Xử lý tìm kiếm
    document.getElementById('btnSearch')?.addEventListener('click', function() {
        const keyword = document.getElementById('keyword').value.trim().toLowerCase();
        const items = document.querySelectorAll('.combo-item');
        
        items.forEach(item => {
            const name = item.dataset.name.toLowerCase();
            if (keyword === '' || name.includes(keyword)) {
                item.style.display = '';
            } else {
                item.style.display = 'none';
            }
        });
    });
    
    // Reset tìm kiếm
    document.getElementById('btnReset')?.addEventListener('click', function() {
        document.getElementById('keyword').value = '';
        document.querySelectorAll('.combo-item').forEach(item => {
            item.style.display = '';
        });
    });
});

function updateCartDisplay() {
    console.log("=== CẬP NHẬT HIỂN THỊ GIỎ HÀNG ===");
    
    const cartList = document.getElementById('cartList');
    const cartTotal = document.getElementById('cartTotal');
    const btnCheckout = document.getElementById('btnCheckout');
    
    const displaySeatTotal = parseInt(seatBookingData.totalAmount) || 0;
    const displayDiscountAmount = parseInt(seatBookingData.discountAmount) || 0;
    const displayOriginalSeatAmount = parseInt(seatBookingData.originalAmount) || (displaySeatTotal + displayDiscountAmount);
    
    console.log("Dữ liệu hiển thị:");
    console.log("  - seatTotal:", displaySeatTotal);
    console.log("  - discountAmount:", displayDiscountAmount);
    console.log("  - originalSeatAmount:", displayOriginalSeatAmount);
    console.log("  - Số lượng combo:", cart.length);
    
    if (cart.length === 0) {
        cartList.innerHTML = '<div class="empty">Chưa có sản phẩm nào</div>';
        
        if (displaySeatTotal > 0) {
            let totalHtml = '';
            
            if (displayDiscountAmount > 0) {
                totalHtml = '<div style="display:flex;flex-direction:column;gap:4px;align-items:flex-end;">' +
                    '<div style="font-size:12px;color:#64748b;text-decoration:line-through;">Vé gốc: ' + displayOriginalSeatAmount.toLocaleString('vi-VN') + ' &#x20AB;</div>' +
                    '<div style="font-size:12px;color:#ef4444;">Giảm: -' + displayDiscountAmount.toLocaleString('vi-VN') + ' &#x20AB;</div>' +
                    '<div style="font-size:12px;color:#64748b;">Vé: ' + displaySeatTotal.toLocaleString('vi-VN') + ' &#x20AB;</div>' +
                    '<div style="font-size:16px;color:#0f172a;font-weight:700;">Tổng: ' + displaySeatTotal.toLocaleString('vi-VN') + ' &#x20AB;</div>' +
                    '</div>';
            } else {
                totalHtml = '<div style="display:flex;flex-direction:column;gap:4px;align-items:flex-end;">' +
                    '<div style="font-size:12px;color:#64748b;">Vé: ' + displaySeatTotal.toLocaleString('vi-VN') + ' &#x20AB;</div>' +
                    '<div style="font-size:16px;color:#0f172a;font-weight:700;">Tổng: ' + displaySeatTotal.toLocaleString('vi-VN') + ' &#x20AB;</div>' +
                    '</div>';
            }
            
            cartTotal.innerHTML = totalHtml;
            if (btnCheckout) btnCheckout.disabled = false;
        } else {
            cartTotal.textContent = '0 ₫';
            if (btnCheckout) btnCheckout.disabled = true;
        }
        
        // DEBUG: Kiểm tra HTML cuối cùng
        setTimeout(() => {
            console.log("HTML cuối cùng của cartTotal:");
            console.log(cartTotal.innerHTML);
        }, 100);
        return;
    }
    
    // Hiển thị danh sách combo với nút xóa
    let html = '';
    cart.forEach((item, index) => {
        const itemName = item.name || 'Combo';
        const itemPrice = parseFloat(item.price) || 0;
        const itemQuantity = parseInt(item.quantity) || 1;
        const itemTotal = itemPrice * itemQuantity;
        
        const escapedName = escapeHtml(itemName);
        const formattedPrice = itemPrice.toLocaleString('vi-VN');
        const formattedTotal = itemTotal.toLocaleString('vi-VN');
        
        html += '<div class="cart-item" data-cart-index="' + index + '">';
        html += '<div class="cart-item-info">';
        html += '<div class="cart-item-title">' + escapedName + '</div>';
        html += '<div class="cart-item-sub">' + itemQuantity + ' x ' + formattedPrice + ' &#x20AB;</div>';
        html += '</div>';
        html += '<div class="cart-item-actions">';
        html += '<div class="cart-item-price">' + formattedTotal + ' &#x20AB;</div>';
        html += '<button class="btn-remove" data-cart-index="' + index + '" title="Xóa item này">Xóa</button>';
        html += '</div>';
        html += '</div>';
    });
    cartList.innerHTML = html;
    
    // Attach event listeners cho các nút xóa
    cartList.querySelectorAll('.btn-remove').forEach(btn => {
        btn.addEventListener('click', function() {
            const index = parseInt(this.getAttribute('data-cart-index'));
            removeFromCart(index);
        });
    });
    
    // Tính tổng và hiển thị với discount
    const comboTotal = cart.reduce((sum, item) => {
        const price = parseFloat(item.price) || 0;
        const quantity = parseInt(item.quantity) || 1;
        return sum + (price * quantity);
    }, 0);
    
    const finalTotal = displaySeatTotal + comboTotal;
    const originalTotal = displayOriginalSeatAmount + comboTotal;
    
    let totalHtml = '';
    
    if (displayDiscountAmount > 0) {
        totalHtml = '<div style="display:flex;flex-direction:column;gap:4px;align-items:flex-end;">' +
            '<div style="font-size:12px;color:#64748b;text-decoration:line-through;">Tổng gốc: ' + originalTotal.toLocaleString('vi-VN') + ' &#x20AB;</div>' +
            '<div style="font-size:12px;color:#ef4444;">Giảm: -' + displayDiscountAmount.toLocaleString('vi-VN') + ' &#x20AB;</div>' +
            '<div style="font-size:12px;color:#64748b;">Vé: ' + displaySeatTotal.toLocaleString('vi-VN') + ' &#x20AB;</div>' +
            '<div style="font-size:12px;color:#64748b;">Combo: ' + comboTotal.toLocaleString('vi-VN') + ' &#x20AB;</div>' +
            '<div style="font-size:16px;color:#0f172a;font-weight:700;">Tổng: ' + finalTotal.toLocaleString('vi-VN') + ' &#x20AB;</div>' +
            '</div>';
    } else {
        totalHtml = '<div style="display:flex;flex-direction:column;gap:4px;align-items:flex-end;">' +
            '<div style="font-size:12px;color:#64748b;">Vé: ' + displaySeatTotal.toLocaleString('vi-VN') + ' &#x20AB;</div>' +
            '<div style="font-size:12px;color:#64748b;">Combo: ' + comboTotal.toLocaleString('vi-VN') + ' &#x20AB;</div>' +
            '<div style="font-size:16px;color:#0f172a;font-weight:700;">Tổng: ' + finalTotal.toLocaleString('vi-VN') + ' &#x20AB;</div>' +
            '</div>';
    }
    
    cartTotal.innerHTML = totalHtml;
    if (btnCheckout) btnCheckout.disabled = false;
    
    // DEBUG: Kiểm tra HTML cuối cùng
    setTimeout(() => {
        console.log("HTML cuối cùng của cartTotal:");
        console.log(cartTotal.innerHTML);
    }, 100);
}

// Hàm xóa item khỏi giỏ hàng
function removeFromCart(index) {
    if (index >= 0 && index < cart.length) {
        const item = cart[index];
        const itemName = item.name || 'Combo';
        if (confirm('Bạn có chắc muốn xóa "' + itemName + '" khỏi giỏ hàng?')) {
            cart.splice(index, 1);
            updateCartDisplay();
        }
    }
}

// Hàm escape HTML để tránh XSS
function escapeHtml(text) {
    const map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };
    return text ? text.replace(/[&<>"']/g, m => map[m]) : '';
}
</script>
</body>
</html>