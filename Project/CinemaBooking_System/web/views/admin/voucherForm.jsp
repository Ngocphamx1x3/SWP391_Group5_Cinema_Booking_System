
<%-- views/admin/voucherForm.jsp --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Tạo Voucher Mới | Cinema Booking</title>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }

            body {
                font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
                background: #f4f7fa;
                color: #2d3748;
                min-height: 100vh;
            }

            /* Sidebar và Header giữ nguyên từ dashboard */
            .sidebar {
                position: fixed;
                top: 0;
                left: 0;
                width: 280px;
                height: 100vh;
                background: #ffffff;
                border-right: 1px solid #e2e8f0;
                display: flex;
                flex-direction: column;
                padding: 30px 0;
                box-shadow: 2px 0 15px rgba(0, 0, 0, 0.05);
                z-index: 1000;
            }

            .sidebar-logo {
                text-align: center;
                margin-bottom: 50px;
                padding: 0 25px;
            }

            .sidebar-logo h2 {
                font-size: 26px;
                font-weight: 700;
                color: #1a202c;
                letter-spacing: 1px;
            }

            .sidebar nav {
                flex: 1;
                overflow-y: auto;
            }

            .sidebar a {
                color: #4a5568;
                text-decoration: none;
                padding: 16px 30px;
                display: flex;
                align-items: center;
                gap: 15px;
                font-size: 15px;
                font-weight: 500;
                transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
                position: relative;
            }

            .sidebar a:hover {
                background: #e6f7ff;
                color: #007bff;
                padding-left: 35px;
            }

            .sidebar a.active {
                background: #e6f7ff;
                color: #007bff;
                padding-left: 35px;
            }

            .sidebar a.logout {
                margin-top: auto;
                background: rgba(239, 68, 68, 0.1);
                color: #ef4444;
                margin: 20px 20px 0;
                border-radius: 12px;
                justify-content: center;
            }

            header {
                margin-left: 280px;
                background: rgba(255, 255, 255, 0.8);
                backdrop-filter: blur(20px);
                border-bottom: 1px solid #e2e8f0;
                padding: 20px 40px;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }

            header h1 {
                font-size: 28px;
                font-weight: 700;
                color: #1a202c;
            }

            .header-right {
                display: flex;
                align-items: center;
                gap: 20px;
            }

            .header-right span {
                font-weight: 500;
                color: #4a5568;
                font-size: 14px;
                display: flex;
                align-items: center;
                gap: 8px;
            }

            .content {
                margin-left: 280px;
                padding: 40px;
            }

            /* Form styles */
            .form-container {
                background: #ffffff;
                border: 1px solid #e2e8f0;
                border-radius: 20px;
                padding: 40px;
                max-width: 800px;
                margin: 0 auto;
            }

            .form-title {
                font-size: 24px;
                font-weight: 700;
                margin-bottom: 30px;
                color: #1a202c;
                text-align: center;
            }

            .form-group {
                margin-bottom: 25px;
            }

            .form-row {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 20px;
            }

            label {
                display: block;
                margin-bottom: 8px;
                font-weight: 500;
                color: #374151;
            }

            .required::after {
                content: " *";
                color: #ef4444;
            }

            input, select, textarea {
                width: 100%;
                padding: 12px 16px;
                border: 1px solid #d1d5db;
                border-radius: 8px;
                font-size: 14px;
                transition: all 0.3s;
            }

            input:focus, select:focus, textarea:focus {
                outline: none;
                border-color: #007bff;
                box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.1);
            }

            textarea {
                resize: vertical;
                min-height: 80px;
            }

            .form-actions {
                display: flex;
                gap: 15px;
                justify-content: flex-end;
                margin-top: 30px;
            }

            .btn {
                padding: 12px 30px;
                border: none;
                border-radius: 8px;
                font-weight: 500;
                cursor: pointer;
                transition: all 0.3s;
                text-decoration: none;
                display: inline-block;
                text-align: center;
            }

            .btn-primary {
                background: #007bff;
                color: white;
            }

            .btn-primary:hover {
                background: #0056b3;
            }

            .btn-secondary {
                background: #6b7280;
                color: white;
            }

            .btn-secondary:hover {
                background: #4b5563;
            }

            .alert {
                padding: 12px 16px;
                border-radius: 8px;
                margin-bottom: 20px;
            }

            .alert-success {
                background: #d1fae5;
                color: #065f46;
                border: 1px solid #a7f3d0;
            }

            .alert-error {
                background: #fee2e2;
                color: #991b1b;
                border: 1px solid #fecaca;
            }

            .discount-type-info {
                font-size: 12px;
                color: #6b7280;
                margin-top: 5px;
            }

            /* Thêm vào phần CSS */
            .form-check {
                display: flex;
                align-items: center;
                margin-bottom: 8px;
            }

            .form-check-input {
                width: auto !important;
                margin-right: 10px;
                margin-top: 0;
            }

            .form-check-label {
                cursor: pointer;
                user-select: none;
            }

            /* Style cho checkbox container */
            .movies-container {
                border: 1px solid #d1d5db;
                border-radius: 8px;
                padding: 15px;
                max-height: 200px;
                overflow-y: auto;
                background: #f9fafb;
            }

            .movie-item {
                display: flex;
                align-items: center;
                padding: 8px 12px;
                border: 1px solid #e5e7eb;
                border-radius: 6px;
                background: white;
                margin-bottom: 8px;
                transition: all 0.2s;
            }

            .movie-item:hover {
                background: #f3f4f6;
                border-color: #d1d5db;
            }

            .movie-item:last-child {
                margin-bottom: 0;
            }
        </style>
    </head>
    <body>

        <div class="sidebar">
            <div class="sidebar-logo">
                <h2>CINEMA PRO</h2>
                <p>Admin Panel</p>
            </div>
            <nav>
                <a href="${pageContext.request.contextPath}/admindashboard">Bảng điều khiển</a>
                <a href="${pageContext.request.contextPath}/views/admin/userManager.jsp">Quản lý người dùng</a>
                <a href="${pageContext.request.contextPath}/admin/staff">Quản lý nhân viên</a>
                <a href="${pageContext.request.contextPath}/admin/cinemas">Quản lý rạp</a>
                <a href="${pageContext.request.contextPath}/admin/movies">Quản lý phim</a>
                <a href="${pageContext.request.contextPath}/admin/seat-types">Quản lý loại ghế</a>
                <a href="${pageContext.request.contextPath}/admin/vouchers" class="active">Quản lý Voucher</a>
                <a href="${pageContext.request.contextPath}/views/admin/paymentManager.jsp">Quản lý thanh toán</a>
            </nav>
            <a href="${pageContext.request.contextPath}/logout" class="logout">Đăng xuất</a>
        </div>

        <header>
            <h1>Tạo Voucher Mới</h1>
            <div class="header-right">
                <span>Admin: 
                    <c:choose>
                        <%-- Ưu tiên username, nếu không có thì dùng email --%>
                        <c:when test="${not empty sessionScope.account.username}">
                            ${sessionScope.account.username}
                        </c:when>
                        <c:when test="${not empty sessionScope.account.email}">
                            ${sessionScope.account.email}
                        </c:when>
                        <c:otherwise>
                            Admin User
                        </c:otherwise>
                    </c:choose>
                </span>
                <span> 
                    <jsp:useBean id="now" class="java.util.Date" />
                    <fmt:formatDate value="${now}" pattern="dd/MM/yyyy HH:mm" />
                </span>
            </div>
        </header>

        <div class="content">
            <div class="form-container">
                <h2 class="form-title"> Tạo Voucher Khuyến Mãi</h2>

                <c:if test="${not empty error}">
                    <div class="alert alert-error">${error}</div>
                </c:if>

                <form action="${pageContext.request.contextPath}/admin/vouchers/create" method="POST">
                    <div class="form-group">
                        <label for="code" class="required">Mã Voucher</label>
                        <input type="text" id="code" name="code" required 
                               placeholder="VD: SUMMER2024, MOVIE50K" 
                               maxlength="50">
                    </div>

                    <div class="form-group">
                        <label for="name" class="required">Tên Voucher</label>
                        <input type="text" id="name" name="name" required 
                               placeholder="VD: Giảm 50K mùa hè, Khuyến mãi 20%">
                    </div>

                    <div class="form-group">
                        <label for="description">Mô tả</label>
                        <textarea id="description" name="description" 
                                  placeholder="Mô tả chi tiết về voucher..."></textarea>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="discountType" class="required">Loại giảm giá</label>
                            <select id="discountType" name="discountType" required onchange="toggleDiscountFields()">
                                <option value="1">Phần trăm (%)</option>
                                <option value="2">Số tiền cố định (VND)</option>
                            </select>
                        </div>

                       <div class="form-group">
    <label for="discountValue" class="required">Giá trị giảm giá</label>
    <input type="number" id="discountValue" name="discountValue" 
           step="0.01" min="0.01" required 
           placeholder="VD: 10 hoặc 50000"
           oninput="formatDiscountValue(this)">
    <div class="discount-type-info" id="discountInfo">
        Nhập phần trăm giảm giá (VD: 10 cho 10%)
    </div>
    <div id="discountValueError" class="error-message" style="display: none;"></div>
</div>
                    </div>

                    <div class="form-row">
    <div class="form-group">
    <label for="minOrderAmount" class="required">Đơn hàng tối thiểu (VND)</label>
    <input type="number" id="minOrderAmount" name="minOrderAmount" 
           step="1000" min="1000" max="1000000" value="1000" required
           placeholder="VD: 50000 cho 50,000 VND">
    <div class="discount-type-info">
        Đơn hàng tối thiểu từ 1,000 đến 1,000,000 VND
    </div>
    <div id="minOrderAmountError" class="error-message" style="display: none;"></div>
</div>

    <div class="form-group">
        <label for="maxDiscountAmount">Giảm tối đa (VND)</label>
        <input type="number" id="maxDiscountAmount" name="maxDiscountAmount" 
               step="1000" min="1000" max="1000000" 
               placeholder="Chỉ áp dụng cho giảm %"
               disabled>
        <div class="discount-type-info" id="maxDiscountInfo">
            Chỉ áp dụng cho giảm giá phần trăm (1,000 - 1,000,000 VND)
        </div>
        <div id="maxDiscountAmountError" class="error-message" style="display: none;"></div>
    </div>
</div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="quantity" class="required">Số lượng</label>
                            <input type="number" id="quantity" name="quantity" 
                                   min="1" required value="100">
                        </div>

                        <div class="form-group">
                            <label for="startDate" class="required">Ngày bắt đầu</label>
                            <input type="datetime-local" id="startDate" name="startDate" required>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="endDate" class="required">Ngày kết thúc</label>
                            <input type="datetime-local" id="endDate" name="endDate" required>
                        </div>
                    </div>

                    <!-- Phần áp dụng cho phim để riêng -->
                    <div class="form-group">
                        <label for="movies">Áp dụng cho phim</label>
                        <div class="movies-container">
                            <div class="form-check" style="margin-bottom: 15px; padding: 8px; background: #f3f4f6; border-radius: 6px;">
                                <input class="form-check-input" type="checkbox" id="selectAllMovies" onchange="toggleAllMovies()" style="width: auto; margin-right: 10px;">
                                <label class="form-check-label" for="selectAllMovies" style="font-weight: 600; color: #374151;">
                                    Chọn tất cả phim
                                </label>
                            </div>
                            <div class="movies-list">
                                <c:choose>
                                    <c:when test="${not empty movies}">
                                        <c:forEach var="movie" items="${movies}">
                                            <div class="movie-item">
                                                <input class="form-check-input movie-checkbox" type="checkbox" 
                                                       name="selectedMovies" value="${movie.id}" id="movie_${movie.id}">
                                                <label class="form-check-label" for="movie_${movie.id}">
                                                    <strong>${movie.name}</strong> 
                                                    <c:if test="${not empty movie.code}">
                                                        <span style="color: #6b7280; font-size: 12px;">(${movie.code})</span>
                                                    </c:if>
                                                </label>
                                            </div>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <div style="text-align: center; padding: 20px; color: #6b7280;">
                                            <p>Không có phim nào khả dụng</p>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        <div class="discount-type-info">
                            Để trống nếu áp dụng cho tất cả phim
                        </div>
                    </div>

                    <div class="form-actions">
                        <a href="${pageContext.request.contextPath}/admin/vouchers" class="btn btn-secondary">← Quay lại</a>
                        <button type="submit" class="btn btn-primary">Tạo Voucher</button>
                    </div>
                </form>
            </div>
        </div>

        <script>
            // Đặt ngày mặc định
            const now = new Date();
            const startDate = new Date(now.getTime() + 60 * 60 * 1000); // 1 giờ sau
            const endDate = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000); // 30 ngày sau

            document.getElementById('startDate').value = formatDateTime(startDate);
            document.getElementById('endDate').value = formatDateTime(endDate);

            function toggleAllMovies() {
                const selectAll = document.getElementById('selectAllMovies');
                const movieCheckboxes = document.querySelectorAll('.movie-checkbox');

                movieCheckboxes.forEach(checkbox => {
                    checkbox.checked = selectAll.checked;
                });
            }

// Tự động check/uncheck "Chọn tất cả" khi thay đổi các checkbox con
            document.addEventListener('DOMContentLoaded', function () {
                const movieCheckboxes = document.querySelectorAll('.movie-checkbox');
                const selectAllCheckbox = document.getElementById('selectAllMovies');

                movieCheckboxes.forEach(checkbox => {
                    checkbox.addEventListener('change', function () {
                        const allChecked = Array.from(movieCheckboxes).every(cb => cb.checked);
                        const someChecked = Array.from(movieCheckboxes).some(cb => cb.checked);

                        selectAllCheckbox.checked = allChecked;
                        selectAllCheckbox.indeterminate = someChecked && !allChecked;
                    });
                });
            });

            function formatDateTime(date) {
                const year = date.getFullYear();
                const month = String(date.getMonth() + 1).padStart(2, '0');
                const day = String(date.getDate()).padStart(2, '0');
                const hours = String(date.getHours()).padStart(2, '0');
                const minutes = String(date.getMinutes()).padStart(2, '0');

                return `${year}-${month}-${day}T${hours}:${minutes}`;
                    }

                    function toggleDiscountFields() {
                        const discountType = document.getElementById('discountType').value;
                        const discountInfo = document.getElementById('discountInfo');
                        const maxDiscountField = document.getElementById('maxDiscountAmount');

                        if (discountType === '1') {
                            discountInfo.textContent = 'Nhập phần trăm giảm giá (VD: 10 cho 10%)';
                            maxDiscountField.required = false;
                        } else {
                            discountInfo.textContent = 'Nhập số tiền giảm giá (VD: 50000 cho 50,000 VND)';
                            maxDiscountField.required = false;
                            maxDiscountField.value = '';
                        }
                    }

                    // Validate form
                    document.querySelector('form').addEventListener('submit', function (e) {
                        const startDate = new Date(document.getElementById('startDate').value);
                        const endDate = new Date(document.getElementById('endDate').value);

                        if (endDate <= startDate) {
                            e.preventDefault();
                            alert('Ngày kết thúc phải sau ngày bắt đầu!');
                            return false;
                        }
                    });

                    function validateDates() {
                        const startDate = new Date(document.getElementById('startDate').value);
                        const endDate = new Date(document.getElementById('endDate').value);
                        const now = new Date();

                        // Reset thời gian để so sánh chỉ ngày
                        now.setHours(0, 0, 0, 0);
                        startDate.setHours(0, 0, 0, 0);

                        let errors = [];

                        // Kiểm tra ngày bắt đầu không được trước ngày hiện tại
                        if (startDate < now) {
                            errors.push('Ngày bắt đầu không được trong quá khứ');
                        }

                        // Kiểm tra ngày kết thúc phải sau ngày bắt đầu
                        if (endDate <= startDate) {
                            errors.push('Ngày kết thúc phải sau ngày bắt đầu');
                        }

                        // Kiểm tra ngày kết thúc không được trong quá khứ
                        if (endDate < now) {
                            errors.push('Ngày kết thúc không được trong quá khứ');
                        }

                        return errors;
                    }

// Thêm sự kiện validate khi form submit
                    document.querySelector('form').addEventListener('submit', function (e) {
                        const errors = validateDates();

                        if (errors.length > 0) {
                            e.preventDefault();
                            alert('Lỗi validation:\n' + errors.join('\n'));
                            return false;
                        }
                    });

// Thêm real-time validation khi người dùng thay đổi ngày
                    document.getElementById('startDate').addEventListener('change', function () {
                        highlightDateErrors();
                    });

                    document.getElementById('endDate').addEventListener('change', function () {
                        highlightDateErrors();
                    });

                    function highlightDateErrors() {
                        const startDateInput = document.getElementById('startDate');
                        const endDateInput = document.getElementById('endDate');
                        const now = new Date();

                        // Reset styles
                        startDateInput.style.borderColor = '#d1d5db';
                        endDateInput.style.borderColor = '#d1d5db';

                        if (startDateInput.value) {
                            const startDate = new Date(startDateInput.value);
                            startDate.setHours(0, 0, 0, 0);
                            now.setHours(0, 0, 0, 0);

                            if (startDate < now) {
                                startDateInput.style.borderColor = '#ef4444';
                            }
                        }

                        if (endDateInput.value && startDateInput.value) {
                            const startDate = new Date(startDateInput.value);
                            const endDate = new Date(endDateInput.value);

                            if (endDate <= startDate) {
                                endDateInput.style.borderColor = '#ef4444';
                            }

                            now.setHours(0, 0, 0, 0);
                            endDate.setHours(0, 0, 0, 0);

                            if (endDate < now) {
                                endDateInput.style.borderColor = '#ef4444';
                            }
                        }
                    }

                    function validateQuantity() {
                        const quantityInput = document.getElementById('quantity');
                        const quantity = parseInt(quantityInput.value);

                        if (quantity < 1) {
                            return ['Số lượng phải lớn hơn hoặc bằng 1'];
                        }

                        if (quantity > 10000) {
                            return ['Số lượng voucher không được vượt quá 10,000'];
                        }

                        return [];
                    }

// Cập nhật hàm validate form
                    document.querySelector('form').addEventListener('submit', function(e) {
    const dateErrors = validateDates();
    const quantityErrors = validateQuantity();
    const discountValueErrors = validateDiscountValue();
    const maxDiscountAmountErrors = validateMaxDiscountAmount();
    const allErrors = [...dateErrors, ...quantityErrors, ...discountValueErrors, ...maxDiscountAmountErrors];
    
    if (allErrors.length > 0) {
        e.preventDefault();
        alert('Lỗi validation:\n' + allErrors.join('\n'));
        return false;
    }
});

// Thêm real-time validation cho số lượng
                    document.getElementById('quantity').addEventListener('input', function () {
                        highlightQuantityErrors();
                    });

                    function highlightQuantityErrors() {
                        const quantityInput = document.getElementById('quantity');
                        const quantity = parseInt(quantityInput.value) || 0;

                        // Reset style
                        quantityInput.style.borderColor = '#d1d5db';

                        if (quantity < 1 || quantity > 10000) {
                            quantityInput.style.borderColor = '#ef4444';
                        }
                    }

// Thêm vào phần script hiện tại

// Validation khi submit form cho discount value
function validateDiscountValue() {
    const discountValueInput = document.getElementById('discountValue');
    const value = parseFloat(discountValueInput.value) || 0;
    const discountType = document.getElementById('discountType').value;
    
    let errors = [];
    
    if (discountType === '1') {
        // Phần trăm
        if (value < 0.01) {
            errors.push('Giá trị giảm giá phần trăm phải lớn hơn 0');
        } else if (value > 100) {
            errors.push('Giá trị giảm giá phần trăm không được vượt quá 100%');
        }
    } else {
        // Số tiền cố định
        if (value < 1000) {
            errors.push('Giá trị giảm giá tiền mặt tối thiểu là 1,000 VND');
        } else if (value % 1000 !== 0) {
            errors.push('Giá trị giảm giá tiền mặt phải là bội số của 1,000 VND');
        }
    }
    
    return errors;
}

// Real-time validation cho discount value (cập nhật)
function validateDiscountValueRealTime(input) {
    const value = parseFloat(input.value) || 0;
    const discountType = document.getElementById('discountType').value;
    const errorElement = document.getElementById('discountValueError');
    
    let errors = [];
    
    if (discountType === '1') {
        // Phần trăm
        if (value < 0.01) {
            errors.push('Giá trị giảm giá phần trăm phải lớn hơn 0');
        } else if (value > 100) {
            errors.push('Giá trị giảm giá phần trăm không được vượt quá 100%');
        }
    } else {
        // Số tiền cố định
        if (value < 1000) {
            errors.push('Giá trị giảm giá tiền mặt tối thiểu là 1,000 VND');
        } else if (value % 1000 !== 0) {
            errors.push('Giá trị giảm giá tiền mặt phải là bội số của 1,000 VND');
        }
    }
    
    if (errors.length > 0) {
        showDiscountValueError(errors.join(', '));
        input.style.borderColor = '#ef4444';
        input.setCustomValidity(errors[0]);
    } else {
        hideDiscountValueError();
        input.style.borderColor = '#10b981';
        input.setCustomValidity('');
        setTimeout(() => {
            input.style.borderColor = '#d1d5db';
        }, 2000);
    }
}

function highlightDiscountErrors() {
    const discountValueInput = document.getElementById('discountValue');
    const discountType = document.getElementById('discountType').value;
    const discountValue = parseFloat(discountValueInput.value) || 0;
    
    // Reset style
    discountValueInput.style.borderColor = '#d1d5db';
    
    let hasError = false;
    
    if (discountType === '1') { // Phần trăm
        if (discountValue < 1 || discountValue > 100) {
            hasError = true;
        }
    } else { // Số tiền cố định
        if (discountValue < 1000 || discountValue > 1000000) {
            hasError = true;
        }
    }
    
    if (hasError) {
        discountValueInput.style.borderColor = '#ef4444';
    }
}

// Cập nhật hàm validate form tổng thể
// Cập nhật hàm validate chính
document.querySelector('form').addEventListener('submit', function(e) {
    const dateErrors = validateDates();
    const quantityErrors = validateQuantity();
    const discountValueErrors = validateDiscountValue();
    const maxDiscountAmountErrors = validateMaxDiscountAmount();
    const minOrderAmountErrors = validateMinOrderAmount();
    
    const allErrors = [
        ...dateErrors, 
        ...quantityErrors, 
        ...discountValueErrors, 
        ...maxDiscountAmountErrors,
        ...minOrderAmountErrors
    ];
    
    if (allErrors.length > 0) {
        e.preventDefault();
        alert('Lỗi validation:\n' + allErrors.join('\n'));
        return false;
    }
});

// Thêm event listener cho min order amount
document.getElementById('minOrderAmount').addEventListener('input', function() {
    validateMinOrderAmountRealTime(this);
});

// Thêm event listener cho blur (tự động làm tròn)
document.getElementById('minOrderAmount').addEventListener('blur', function() {
    const value = parseInt(this.value) || 0;
    if (value >= 1000) {
        // Làm tròn xuống bội số của 1000 gần nhất
        const roundedValue = Math.floor(value / 1000) * 1000;
        this.value = roundedValue.toString();
        validateMinOrderAmountRealTime(this);
    }
});

// Khởi tạo validation khi trang load
document.addEventListener('DOMContentLoaded', function() {
    // Đảm bảo các field được set đúng attributes ban đầu
    toggleDiscountFields();
    
    // Validate các field ban đầu
    const discountValueInput = document.getElementById('discountValue');
    const maxDiscountInput = document.getElementById('maxDiscountAmount');
    const minOrderAmountInput = document.getElementById('minOrderAmount');
    
    validateDiscountValueRealTime(discountValueInput);
    validateMaxDiscountAmountRealTime(maxDiscountInput);
    validateMinOrderAmountRealTime(minOrderAmountInput);
});

// Thêm real-time validation cho giá trị giảm giá
document.getElementById('discountValue').addEventListener('input', function () {
    highlightDiscountErrors();
});

document.getElementById('discountType').addEventListener('change', function () {
    // Cập nhật thông tin hiển thị
    toggleDiscountFields();
    // Validate lại giá trị hiện tại
    highlightDiscountErrors();
    // Reset giá trị nếu cần
    const discountValueInput = document.getElementById('discountValue');
    const currentValue = parseFloat(discountValueInput.value) || 0;
    
    if (this.value === '1') { // Chuyển sang phần trăm
        if (currentValue > 100) {
            discountValueInput.value = 100;
        }
    } else { // Chuyển sang tiền mặt
        if (currentValue < 1000) {
            discountValueInput.value = 1000;
        } else if (currentValue > 1000000) {
            discountValueInput.value = 1000000;
        }
    }
});

// Cập nhật hàm toggleDiscountFields để hiển thị placeholder phù hợp
// Hàm toggleDiscountFields cập nhật
function toggleDiscountFields() {
    const discountType = document.getElementById('discountType').value;
    const discountInfo = document.getElementById('discountInfo');
    const discountValueInput = document.getElementById('discountValue');
    const maxDiscountField = document.getElementById('maxDiscountAmount');
    const maxDiscountInfo = document.getElementById('maxDiscountInfo');

    if (discountType === '1') {
        // Phần trăm
        discountInfo.textContent = 'Nhập phần trăm giảm giá (VD: 10 cho 10%) - Tối đa 100%';
        discountValueInput.step = '0.01';
        discountValueInput.min = '0.01';
        discountValueInput.max = '100';
        discountValueInput.placeholder = 'VD: 10 cho 10%';
        
        // Kích hoạt và yêu cầu nhập max discount amount
        maxDiscountField.disabled = false;
        maxDiscountField.required = true;
        maxDiscountInfo.textContent = 'Bắt buộc cho giảm giá phần trăm (1,000 - 1,000,000 VND)';
        maxDiscountInfo.style.color = '#374151';
        
        // Reset giá trị nếu vượt quá 100
        if (parseFloat(discountValueInput.value) > 100) {
            discountValueInput.value = '100';
        }
        
        // Set giá trị mặc định cho max discount nếu chưa có
        if (!maxDiscountField.value) {
            maxDiscountField.value = '50000';
        }
    } else {
        // Số tiền cố định
        discountInfo.textContent = 'Nhập số tiền giảm giá (VD: 50000 cho 50,000 VND)';
        discountValueInput.step = '1000';
        discountValueInput.min = '1000'; // Tối thiểu 1,000 VND
        discountValueInput.max = ''; // Bỏ giới hạn max
        discountValueInput.placeholder = 'VD: 50000 cho 50,000 VND';
        
        // Vô hiệu hóa và không yêu cầu max discount amount
        maxDiscountField.disabled = true;
        maxDiscountField.required = false;
        maxDiscountField.value = '';
        maxDiscountInfo.textContent = 'Chỉ áp dụng cho giảm giá phần trăm';
        maxDiscountInfo.style.color = '#6b7280';
        
        // Đảm bảo giá trị hiện tại hợp lệ (là bội số của 1000)
        const currentValue = parseInt(discountValueInput.value) || 0;
        if (currentValue > 0 && currentValue < 1000) {
            discountValueInput.value = '1000';
        } else if (currentValue > 0) {
            // Làm tròn xuống bội số của 1000 gần nhất
            const roundedValue = Math.floor(currentValue / 1000) * 1000;
            discountValueInput.value = roundedValue.toString();
        }
    }
    
    // Validate lại giá trị hiện tại
    validateDiscountValueRealTime(discountValueInput);
    validateMaxDiscountAmountRealTime(maxDiscountField);
    
    // Reset validation state của input
    discountValueInput.setCustomValidity('');
}

function validateMaxDiscountAmountRealTime(input) {
    // Chỉ validate nếu field không bị disabled
    if (input.disabled) {
        hideMaxDiscountAmountError();
        input.style.borderColor = '#d1d5db';
        return;
    }
    
    const value = parseInt(input.value) || 0;
    const errorElement = document.getElementById('maxDiscountAmountError');
    
    let errors = [];
    
    if (value < 1000) {
        errors.push('Giảm tối đa tối thiểu là 1,000 VND');
    }
    
    if (value > 1000000) {
        errors.push('Giảm tối đa không được vượt quá 1,000,000 VND');
    }
    
    if (value === 0) {
        errors.push('Vui lòng nhập giảm tối đa');
    }
    
    if (errors.length > 0) {
        showMaxDiscountAmountError(errors.join(', '));
        input.style.borderColor = '#ef4444';
    } else {
        hideMaxDiscountAmountError();
        input.style.borderColor = '#10b981';
        setTimeout(() => {
            input.style.borderColor = '#d1d5db';
        }, 2000);
    }
}

function showMaxDiscountAmountError(message) {
    const errorElement = document.getElementById('maxDiscountAmountError');
    errorElement.textContent = message;
    errorElement.style.display = 'block';
}

function hideMaxDiscountAmountError() {
    const errorElement = document.getElementById('maxDiscountAmountError');
    if (errorElement) {
        errorElement.style.display = 'none';
    }
}

// Validation khi submit form cho max discount amount
function validateMaxDiscountAmount() {
    const maxDiscountField = document.getElementById('maxDiscountAmount');
    const discountType = document.getElementById('discountType').value;
    
    // Nếu là giảm giá phần trăm thì validate max discount amount
    if (discountType === '1') {
        const value = parseInt(maxDiscountField.value) || 0;
        let errors = [];
        
        if (value < 1000) {
            errors.push('Giảm tối đa tối thiểu là 1,000 VND');
        }
        
        if (value > 1000000) {
            errors.push('Giảm tối đa không được vượt quá 1,000,000 VND');
        }
        
        if (value === 0) {
            errors.push('Vui lòng nhập giảm tối đa cho giảm giá phần trăm');
        }
        
        return errors;
    }
    
    return [];
}

// Hàm tự động format giá trị khi nhập
function formatDiscountValue(input) {
    const discountType = document.getElementById('discountType').value;
    
    if (discountType === '2') { // Số tiền cố định
        // Xóa các ký tự không phải số
        let value = input.value.replace(/[^\d]/g, '');
        
        // Giới hạn độ dài
        if (value.length > 9) {
            value = value.substring(0, 9);
        }
        
        // Cập nhật giá trị
        input.value = value;
    }
    
    validateDiscountValueRealTime(input);
}

// Real-time validation cho min order amount
function validateMinOrderAmountRealTime(input) {
    const value = parseInt(input.value) || 0;
    const errorElement = document.getElementById('minOrderAmountError');
    
    let errors = [];
    
    if (value < 1000) {
        errors.push('Đơn hàng tối thiểu phải từ 1,000 VND');
    }
    
    if (value > 1000000) {
        errors.push('Đơn hàng tối thiểu không được vượt quá 1,000,000 VND');
    }
    
    if (value % 1000 !== 0) {
        errors.push('Đơn hàng tối thiểu phải là bội số của 1,000 VND');
    }
    
    if (errors.length > 0) {
        showMinOrderAmountError(errors.join(', '));
        input.style.borderColor = '#ef4444';
        input.setCustomValidity(errors[0]);
    } else {
        hideMinOrderAmountError();
        input.style.borderColor = '#10b981';
        input.setCustomValidity('');
        setTimeout(() => {
            input.style.borderColor = '#d1d5db';
        }, 2000);
    }
}

function showMinOrderAmountError(message) {
    const errorElement = document.getElementById('minOrderAmountError');
    errorElement.textContent = message;
    errorElement.style.display = 'block';
}

function hideMinOrderAmountError() {
    const errorElement = document.getElementById('minOrderAmountError');
    if (errorElement) {
        errorElement.style.display = 'none';
    }
}

// Validation khi submit form cho min order amount
function validateMinOrderAmount() {
    const minOrderAmountInput = document.getElementById('minOrderAmount');
    const value = parseInt(minOrderAmountInput.value) || 0;
    
    let errors = [];
    
    if (value < 1000) {
        errors.push('Đơn hàng tối thiểu phải từ 1,000 VND');
    }
    
    if (value > 1000000) {
        errors.push('Đơn hàng tối thiểu không được vượt quá 1,000,000 VND');
    }
    
    if (value % 1000 !== 0) {
        errors.push('Đơn hàng tối thiểu phải là bội số của 1,000 VND');
    }
    
    return errors;
}

// Thêm hàm format số tiền để hiển thị đẹp hơn
document.getElementById('discountValue').addEventListener('blur', function () {
    const discountType = document.getElementById('discountType').value;
    const value = parseFloat(this.value);
    
    if (!isNaN(value)) {
        if (discountType === '2') { // Tiền mặt
            // Làm tròn đến hàng nghìn
            this.value = Math.round(value / 1000) * 1000;
        } else { // Phần trăm
            // Làm tròn đến số nguyên
            this.value = Math.round(value);
        }
    }
});

document.getElementById('maxDiscountAmount').addEventListener('input', function() {
    validateMaxDiscountAmountRealTime(this);
});

// Thêm event listener cho discount type
document.getElementById('discountType').addEventListener('change', function() {
    const discountValueInput = document.getElementById('discountValue');
    const maxDiscountInput = document.getElementById('maxDiscountAmount');
    
    validateDiscountValueRealTime(discountValueInput);
    validateMaxDiscountAmountRealTime(maxDiscountInput);
});

// Khởi tạo validation khi trang load
document.addEventListener('DOMContentLoaded', function () {
    toggleDiscountFields();
    highlightDiscountErrors();
});

// Hàm tự động làm tròn giá trị tiền khi rời khỏi input
document.getElementById('discountValue').addEventListener('blur', function() {
    const discountType = document.getElementById('discountType').value;
    
    if (discountType === '2') { // Số tiền cố định
        const value = parseInt(this.value) || 0;
        if (value >= 1000) {
            // Làm tròn xuống bội số của 1000 gần nhất
            const roundedValue = Math.floor(value / 1000) * 1000;
            this.value = roundedValue.toString();
            validateDiscountValueRealTime(this);
        }
    }
});

// Hàm validate khi người dùng nhập
document.getElementById('discountValue').addEventListener('input', function() {
    const discountType = document.getElementById('discountType').value;
    
    if (discountType === '2') { // Số tiền cố định
        // Cho phép người dùng nhập tự do, chỉ validate real-time
        validateDiscountValueRealTime(this);
    } else {
        validateDiscountValueRealTime(this);
    }
});
        </script>

    </body>
</html>
