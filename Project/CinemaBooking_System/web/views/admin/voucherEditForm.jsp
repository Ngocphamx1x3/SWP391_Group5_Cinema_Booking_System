<%-- 
    Document   : voucherEditForm
    Created on : Oct 28, 2025, 11:03:49 AM
    Author     : admin
--%>

<%-- views/admin/voucherEditForm.jsp --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chỉnh sửa Voucher | Cinema Booking</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        /* Copy toàn bộ CSS từ voucherForm.jsp vào đây */
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

        .btn-info {
            background: #17a2b8;
            color: white;
        }

        .btn-info:hover {
            background: #138496;
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

        .checkbox-group {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .checkbox-group input[type="checkbox"] {
            width: auto;
        }
    </style>
</head>
<body>

    <div class="sidebar">
        <div class="sidebar-logo">
            <h2>🎬 CINEMA PRO</h2>
            <p>Admin Panel</p>
        </div>
        <nav>
            <a href="${pageContext.request.contextPath}/admindashboard">📊 Bảng điều khiển</a>
            <a href="${pageContext.request.contextPath}/views/admin/userManager.jsp">👥 Quản lý người dùng</a>
            <a href="${pageContext.request.contextPath}/admin/staff">🧑‍💼 Quản lý nhân viên</a>
            <a href="${pageContext.request.contextPath}/admin/cinemas">🏢 Quản lý rạp</a>
            <a href="${pageContext.request.contextPath}/admin/movies">🎞️ Quản lý phim</a>
            <a href="${pageContext.request.contextPath}/admin/seat-types">💺 Quản lý loại ghế</a>
            <a href="${pageContext.request.contextPath}/admin/vouchers" class="active">🎫 Quản lý Voucher</a>
            <a href="${pageContext.request.contextPath}/views/admin/paymentManager.jsp">💳 Quản lý thanh toán</a>
        </nav>
        <a href="${pageContext.request.contextPath}/logout" class="logout">🚪 Đăng xuất</a>
    </div>

    <header>
        <h1>Chỉnh sửa Voucher</h1>
        <div class="header-right">
            <span>👤 Admin: 
                <c:choose>
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
            <span>⏰ 
                <jsp:useBean id="now" class="java.util.Date" />
                <fmt:formatDate value="${now}" pattern="dd/MM/yyyy HH:mm" />
            </span>
        </div>
    </header>

    <div class="content">
        <div class="form-container">
            <h2 class="form-title">✏️ Chỉnh sửa Voucher: ${voucher.code}</h2>

            <c:if test="${not empty error}">
                <div class="alert alert-error">${error}</div>
            </c:if>

            <form action="${pageContext.request.contextPath}/admin/vouchers/update" method="POST">
                <input type="hidden" name="id" value="${voucher.id}">
                
                <div class="form-group">
                    <label for="code" class="required">Mã Voucher</label>
                    <input type="text" id="code" name="code" required 
                           value="${voucher.code}" 
                           placeholder="VD: SUMMER2024, MOVIE50K" 
                           maxlength="50">
                </div>

                <div class="form-group">
                    <label for="name" class="required">Tên Voucher</label>
                    <input type="text" id="name" name="name" required 
                           value="${voucher.name}"
                           placeholder="VD: Giảm 50K mùa hè, Khuyến mãi 20%">
                </div>

                <div class="form-group">
                    <label for="description">Mô tả</label>
                    <textarea id="description" name="description" 
                              placeholder="Mô tả chi tiết về voucher...">${voucher.description}</textarea>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="discountType" class="required">Loại giảm giá</label>
                        <select id="discountType" name="discountType" required onchange="toggleDiscountFields()">
                            <option value="1" ${voucher.discountType == 1 ? 'selected' : ''}>Phần trăm (%)</option>
                            <option value="2" ${voucher.discountType == 2 ? 'selected' : ''}>Số tiền cố định (VND)</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="discountValue" class="required">Giá trị giảm giá</label>
                        <input type="number" id="discountValue" name="discountValue" 
                               step="0.01" min="0.01" required 
                               value="${voucher.discountValue}"
                               placeholder="VD: 10 hoặc 50000">
                        <div class="discount-type-info" id="discountInfo">
                            ${voucher.discountType == 1 ? 'Nhập phần trăm giảm giá (VD: 10 cho 10%)' : 'Nhập số tiền giảm giá (VD: 50000 cho 50,000 VND)'}
                        </div>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="minOrderAmount" class="required">Đơn hàng tối thiểu (VND)</label>
                        <input type="number" id="minOrderAmount" name="minOrderAmount" 
                               step="1000" min="0" value="${voucher.minOrderAmount}" required>
                    </div>

                    <div class="form-group">
                        <label for="maxDiscountAmount">Giảm tối đa (VND)</label>
                        <input type="number" id="maxDiscountAmount" name="maxDiscountAmount" 
                               step="1000" min="0" 
                               value="${voucher.maxDiscountAmount > 0 ? voucher.maxDiscountAmount : ''}"
                               placeholder="Chỉ áp dụng cho giảm %">
                        <div class="discount-type-info">
                            Chỉ cần thiết cho giảm giá phần trăm
                        </div>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="quantity" class="required">Số lượng</label>
                        <input type="number" id="quantity" name="quantity" 
                               min="1" required value="${voucher.quantity}">
                        <div class="discount-type-info">
                            Đã sử dụng: ${voucher.usedQuantity}
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="startDate" class="required">Ngày bắt đầu</label>
                        <input type="datetime-local" id="startDate" name="startDate" 
                               value="<fmt:formatDate value="${voucher.startDate}" pattern="yyyy-MM-dd'T'HH:mm" />" required>
                    </div>

                    <div class="form-group">
                        <label for="endDate" class="required">Ngày kết thúc</label>
                        <input type="datetime-local" id="endDate" name="endDate" 
                               value="<fmt:formatDate value="${voucher.endDate}" pattern="yyyy-MM-dd'T'HH:mm" />" required>
                    </div>
                </div>

                <div class="form-group">
                    <div class="checkbox-group">
                        <input type="checkbox" id="isActive" name="isActive" ${voucher.isActive ? 'checked' : ''}>
                        <label for="isActive">Kích hoạt voucher</label>
                    </div>
                </div>

                <div class="form-actions">
                    <a href="${pageContext.request.contextPath}/admin/vouchers/detail/${voucher.id}" class="btn btn-info">👁️ Xem chi tiết</a>
                    <a href="${pageContext.request.contextPath}/admin/vouchers" class="btn btn-secondary">← Quay lại</a>
                    <button type="submit" class="btn btn-primary">💾 Cập nhật Voucher</button>
                </div>
            </form>
        </div>
    </div>

    <script>
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
                if (maxDiscountField.value > 0) {
                    maxDiscountField.value = '';
                }
            }
        }

        // Validate form
        document.querySelector('form').addEventListener('submit', function(e) {
            const startDate = new Date(document.getElementById('startDate').value);
            const endDate = new Date(document.getElementById('endDate').value);
            
            if (endDate <= startDate) {
                e.preventDefault();
                alert('Ngày kết thúc phải sau ngày bắt đầu!');
                return false;
            }
        });
    </script>

</body>
</html>
