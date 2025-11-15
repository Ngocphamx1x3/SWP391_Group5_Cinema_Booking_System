<%-- 
    Document   : bookingDetails
    Created on : Nov 6, 2025, 7:15:59 PM
    Author     : admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chi tiết Đặt Vé | Cinema Booking</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: #f4f7fa;
            color: #2d3748;
            padding: 20px;
        }

        .container {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            overflow: hidden;
        }

        .header {
            background: linear-gradient(135deg, #00d4ff 0%, #0099ff 100%);
            color: white;
            padding: 25px;
            text-align: center;
        }

        .header h1 {
            font-size: 24px;
            margin-bottom: 5px;
        }

        .ticket-code {
            font-size: 18px;
            font-weight: 600;
            background: rgba(255,255,255,0.2);
            padding: 8px 16px;
            border-radius: 20px;
            display: inline-block;
            margin-top: 10px;
        }

        .content {
            padding: 30px;
        }

        .section {
            margin-bottom: 25px;
            padding-bottom: 25px;
            border-bottom: 1px solid #e2e8f0;
        }

        .section:last-child {
            border-bottom: none;
            margin-bottom: 0;
        }

        .section-title {
            font-size: 16px;
            font-weight: 600;
            color: #4a5568;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
        }

        .info-item {
            display: flex;
            flex-direction: column;
            gap: 5px;
        }

        .info-label {
            font-size: 13px;
            color: #6b7280;
            font-weight: 500;
        }

        .info-value {
            font-size: 15px;
            color: #2d3748;
            font-weight: 600;
        }

        .seats-container {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-top: 10px;
        }

        .seat-badge {
            background: #e6f7ff;
            color: #007bff;
            padding: 6px 12px;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 600;
            border: 1px solid #b3e0ff;
        }

        .status-badge {
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
            display: inline-block;
        }

        .status-pending {
            background: rgba(255, 193, 7, 0.2);
            color: #ffc107;
            border: 1px solid rgba(255, 193, 7, 0.3);
        }

        .status-confirmed {
            background: rgba(16, 185, 129, 0.2);
            color: #10b981;
            border: 1px solid rgba(16, 185, 129, 0.3);
        }

        .status-cancelled {
            background: rgba(239, 68, 68, 0.2);
            color: #ef4444;
            border: 1px solid rgba(239, 68, 68, 0.3);
        }

        .status-completed {
            background: rgba(59, 130, 246, 0.2);
            color: #3b82f6;
            border: 1px solid rgba(59, 130, 246, 0.3);
        }

        .actions {
            text-align: center;
            padding: 20px;
            background: #f8f9fa;
            border-top: 1px solid #e2e8f0;
        }

        .btn {
            background: #6c757d;
            color: white;
            border: none;
            border-radius: 8px;
            padding: 10px 20px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
        }

        .btn-close {
            background: #007bff;
        }

        .btn-close:hover {
            background: #0056b3;
        }
        
        .status-pending {
    background: rgba(255, 193, 7, 0.2);
    color: #ffc107;
    border: 1px solid rgba(255, 193, 7, 0.3);
}

.status-active {
    background: rgba(16, 185, 129, 0.2);
    color: #10b981;
    border: 1px solid rgba(16, 185, 129, 0.3);
}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Chi tiết Đặt Vé</h1>
            <div class="ticket-code">${booking.ticketCode}</div>
        </div>

        <div class="content">
            <!-- Thông tin khách hàng -->
            <div class="section">
                <div class="section-title">Thông tin khách hàng</div>
                <div class="info-grid">
                    <div class="info-item">
                        <div class="info-label">Họ tên</div>
                        <div class="info-value">${booking.customerName}</div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Email</div>
                        <div class="info-value">${booking.customerEmail}</div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Số điện thoại</div>
                        <div class="info-value">${booking.customerPhone}</div>
                    </div>
                </div>
            </div>

            <!-- Thông tin phim -->
            <div class="section">
                <div class="section-title">Thông tin phim</div>
                <div class="info-grid">
                    <div class="info-item">
                        <div class="info-label">Tên phim</div>
                        <div class="info-value">${booking.movieName}</div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Rạp chiếu</div>
                        <div class="info-value">${booking.cinemaName}</div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Phòng chiếu</div>
                        <div class="info-value">${booking.roomName}</div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Suất chiếu</div>
                        <div class="info-value">
                            <c:if test="${not empty booking.showtime}">
                                <fmt:formatDate value="${booking.showtime}" pattern="HH:mm dd/MM/yyyy" />
                            </c:if>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Thông tin ghế -->
            <div class="section">
                <div class="section-title">Thông tin ghế</div>
                <div class="seats-container">
                    <c:forEach var="seat" items="${booking.seats}">
                        <div class="seat-badge">${seat}</div>
                    </c:forEach>
                </div>
            </div>

            <!-- Thông tin thanh toán -->
            <div class="section">
                <div class="section-title">Thông tin thanh toán</div>
                <div class="info-grid">
                    <div class="info-item">
                        <div class="info-label">Thành tiền</div>
                        <div class="info-value">${booking.totalAmountFormatted}</div>
                    </div>
                    <div class="info-item">
    <div class="info-label">Trạng thái</div>
    <div class="info-value">
        <span class="status-badge ${booking.statusBadgeClass}">
            ${booking.statusFormatted}
        </span>
    </div>
</div>
                    <div class="info-item">
                        <div class="info-label">Ngày đặt</div>
                        <div class="info-value">
                            <c:if test="${not empty booking.orderDate}">
                                <fmt:formatDate value="${booking.orderDate}" pattern="HH:mm dd/MM/yyyy" />
                            </c:if>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="actions">
            <button class="btn btn-close" onclick="window.close()">Đóng</button>
        </div>
    </div>

    <script>
        // Tự động đóng cửa sổ sau 30 giây nếu không tương tác
        setTimeout(() => {
            if (confirm('Cửa sổ sẽ đóng sau 10 giây nữa. Bạn có muốn giữ cửa sổ mở không?')) {
                // Reset timer nếu người dùng chọn giữ cửa sổ mở
                setTimeout(() => {
                    if (confirm('Cửa sổ sẽ đóng sau 5 giây nữa...')) {
                        // Tiếp tục giữ mở
                    } else {
                        window.close();
                    }
                }, 5000);
            } else {
                window.close();
            }
        }, 30000);
    </script>
</body>
</html>
