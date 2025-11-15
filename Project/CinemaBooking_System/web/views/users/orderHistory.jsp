<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Lịch sử đơn hàng</title>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }

            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: #f5f5f5;
                min-height: 100vh;
            }

            .order-history-container {
                max-width: 1000px;
                margin: 80px auto 30px;
                padding: 0 15px;
            }

            .page-header {
                background: white;
                padding: 20px;
                border-radius: 8px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.1);
                margin-bottom: 20px;
            }

            .page-header h1 {
                color: #333;
                font-size: 24px;
                margin-bottom: 5px;
            }

            .order-count {
                color: #666;
                font-size: 14px;
            }

            .alert-danger {
                background: #fee;
                color: #c33;
                padding: 12px 15px;
                border-radius: 6px;
                margin-bottom: 15px;
                border-left: 3px solid #c33;
            }

            .order-card {
                background: white;
                border-radius: 8px;
                margin-bottom: 15px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.08);
                overflow: hidden;
            }

            .order-header {
                background: #667eea;
                padding: 12px 15px;
                color: white;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }

            .order-info {
                font-size: 14px;
            }

            .order-info strong {
                font-size: 15px;
                margin-bottom: 3px;
                display: block;
            }

            .order-status {
                padding: 5px 15px;
                border-radius: 15px;
                font-weight: 600;
                font-size: 12px;
            }

            .status-success {
                background: #51cf66;
                color: white;
            }
            .status-warning {
                background: #ffd43b;
                color: #333;
            }
            .status-danger {
                background: #ff6b6b;
                color: white;
            }
            .status-secondary {
                background: #868e96;
                color: white;
            }

            .order-items {
                padding: 15px;
            }

            .section-title {
                font-weight: 600;
                font-size: 14px;
                margin: 12px 0 8px;
                color: #667eea;
                padding-left: 8px;
                border-left: 3px solid #667eea;
            }

            .section-title:first-child {
                margin-top: 0;
            }

            .ticket-item, .combo-item {
                display: flex;
                align-items: center;
                padding: 10px;
                margin-bottom: 8px;
                background: #f8f9fa;
                border-radius: 6px;
                gap: 10px;
            }

            .ticket-icon {
                width: 35px;
                height: 35px;
                background: #667eea;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 18px;
                flex-shrink: 0;
                color: white;
            }

            .ticket-details {
                flex: 1;
                min-width: 0;
            }

            .ticket-movie-name {
                font-weight: 600;
                margin-bottom: 4px;
                color: #333;
                font-size: 14px;
            }

            .ticket-info {
                color: #666;
                font-size: 12px;
                line-height: 1.5;
            }

            .ticket-price {
                font-weight: 700;
                color: #51cf66;
                font-size: 15px;
                white-space: nowrap;
            }

            .combo-image {
                width: 50px;
                height: 50px;
                border-radius: 6px;
                object-fit: cover;
                border: 2px solid #e9ecef;
                flex-shrink: 0;
            }

            .combo-details {
                flex: 1;
                min-width: 0;
            }

            .combo-name {
                font-weight: 600;
                margin-bottom: 3px;
                color: #333;
                font-size: 14px;
            }

            .combo-price {
                color: #666;
                font-size: 12px;
            }

            .order-total {
                text-align: right;
                padding: 12px 15px;
                background: #f8f9fa;
                border-top: 1px solid #dee2e6;
                font-weight: 700;
                font-size: 16px;
                color: #667eea;
            }

            .empty-state {
                background: white;
                text-align: center;
                padding: 40px 30px;
                border-radius: 8px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            }

            .empty-state-icon {
                font-size: 50px;
                margin-bottom: 15px;
                opacity: 0.5;
            }

            .empty-state h3 {
                color: #333;
                margin-bottom: 8px;
                font-size: 20px;
            }

            .empty-state p {
                color: #666;
                font-size: 14px;
            }

            .no-items-msg {
                padding: 20px;
                text-align: center;
                color: #999;
                font-style: italic;
                background: #f8f9fa;
                border-radius: 6px;
                margin: 8px 0;
                font-size: 13px;
            }

            .filter-container {
                background: white;
                padding: 15px;
                border-radius: 8px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.08);
                margin-bottom: 20px;
            }

            .search-box {
                display: flex;
                gap: 10px;
                margin-bottom: 15px;
            }

            .search-input {
                flex: 1;
                padding: 10px 15px;
                border: 1px solid #ddd;
                border-radius: 6px;
                font-size: 14px;
                transition: border-color 0.3s;
            }

            .search-input:focus {
                outline: none;
                border-color: #667eea;
            }

            .search-btn {
                padding: 10px 20px;
                background: #667eea;
                color: white;
                border: none;
                border-radius: 6px;
                font-size: 14px;
                font-weight: 600;
                cursor: pointer;
                transition: background 0.3s;
            }

            .search-btn:hover {
                background: #5568d3;
            }

            .filter-tabs {
                display: flex;
                gap: 8px;
                flex-wrap: wrap;
            }

            .filter-tab {
                padding: 8px 16px;
                background: #f8f9fa;
                border: 1px solid #dee2e6;
                border-radius: 20px;
                font-size: 13px;
                font-weight: 500;
                cursor: pointer;
                transition: all 0.3s;
                color: #666;
            }

            .filter-tab:hover {
                background: #e9ecef;
            }

            .filter-tab.active {
                background: #667eea;
                color: white;
                border-color: #667eea;
            }

            .filter-tab .count {
                display: inline-block;
                background: rgba(0,0,0,0.1);
                padding: 2px 6px;
                border-radius: 10px;
                font-size: 11px;
                margin-left: 5px;
            }

            .filter-tab.active .count {
                background: rgba(255,255,255,0.3);
            }

            .no-results {
                background: white;
                text-align: center;
                padding: 40px 30px;
                border-radius: 8px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            }

            .no-results-icon {
                font-size: 50px;
                margin-bottom: 15px;
                opacity: 0.5;
            }

            .no-results h3 {
                color: #333;
                margin-bottom: 8px;
                font-size: 18px;
            }

            .no-results p {
                color: #666;
                font-size: 14px;
            }
        </style>
    </head>
    <body>

        <div class="order-history-container">
            <div class="page-header">
                <h1>Lịch sử đơn hàng</h1>
                
            </div>

            <c:if test="${not empty error}">
                <div class="alert-danger">
                    ${error}
                </div>
            </c:if>

            <!-- Filter and Search Section -->
            <c:if test="${not empty orders}">
                <div class="filter-container">
                    <div class="search-box">
                        <input type="text" 
                               id="searchInput" 
                               class="search-input" 
                               placeholder="Tìm kiếm theo mã đơn, tên phim, rạp...">
                        <button class="search-btn" onclick="filterOrders()">Tìm kiếm</button>
                    </div>

                    <div class="filter-tabs">
                        <div class="filter-tab active" data-status="all" onclick="filterByStatus('all')">
                            Tất cả <span class="count" id="count-all">0</span>
                        </div>
                        <div class="filter-tab" data-status="PENDING" onclick="filterByStatus('PENDING')">
                            Chờ thanh toán <span class="count" id="count-pending">0</span>
                        </div>
                        <div class="filter-tab" data-status="PAID" onclick="filterByStatus('PAID')">
                            Đã thanh toán <span class="count" id="count-paid">0</span>
                        </div>
                    </div>
                </div>
            </c:if>

            <c:choose>
                <c:when test="${not empty orders}">
                    <div id="ordersContainer">
                        <c:forEach var="order" items="${orders}">
                            <c:if test="${order.status == 'PAID' or order.status == 'PENDING'}">
                                <div class="order-card" 
                                     data-order-status="${order.status}"
                                     data-order-code="${order.orderCode}"
                                     data-order-date="${order.formattedOrderDate}">
                                    <div class="order-header">
                                        <div class="order-info">
                                            <strong>${order.orderCode}</strong>
                                            <div>${order.formattedOrderDate}</div>
                                        </div>
                                        <div class="order-status status-${order.statusColor}">
                                            ${order.statusText}
                                        </div>
                                    </div>

                                    <div class="order-items">
                                        <c:if test="${not empty order.tickets}">
                                            <div class="section-title">Vé xem phim</div>
                                            <c:forEach var="ticket" items="${order.tickets}">
                                                <div class="ticket-item" 
                                                     data-movie-name="${ticket.movieName}" 
                                                     data-cinema-name="${ticket.cinemaName}">
                                                    <div class="ticket-icon">
                                                        <c:choose>
                                                            <c:when test="${ticket.ticketStatus == 'CONFIRMED'}">V</c:when>
                                                            <c:when test="${ticket.ticketStatus == 'CANCELLED'}">X</c:when>
                                                            <c:otherwise>...</c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                    <div class="ticket-details">
                                                        <div class="ticket-movie-name">${ticket.movieName}</div>
                                                        <div class="ticket-info">
                                                            ${ticket.cinemaName} - ${ticket.roomName}<br>
                                                            ${ticket.formattedStartAt} | Ghế: <strong>${ticket.seatCode}</strong>
                                                            <c:if test="${ticket.ticketStatus != 'CONFIRMED'}">
                                                                <br><span style="color: #ff6b6b; font-size: 11px;">
                                                                    (Trạng thái: 
                                                                    <c:choose>
                                                                        <c:when test="${ticket.ticketStatus == 'CANCELLED'}">Đã hủy</c:when>
                                                                        <c:when test="${ticket.ticketStatus == 'PENDING'}">Chờ xác nhận</c:when>
                                                                        <c:otherwise>${ticket.ticketStatus}</c:otherwise>
                                                                    </c:choose>)
                                                                </span>
                                                            </c:if>
                                                        </div>
                                                    </div>
                                                    <div class="ticket-price">
                                                        ${ticket.formattedTicketPrice}
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </c:if>

                                        <c:if test="${not empty order.orderCombos}">
                                            <div class="section-title">Đồ ăn & Nước uống</div>
                                            <c:forEach var="combo" items="${order.orderCombos}">
                                                <div class="combo-item">
                                                    <c:set var="imagePath" value="${pageContext.request.contextPath}/assets/user/img/${empty combo.comboImage ? 'default-combo.png' : combo.comboImage}" />
                                                    <img src="${imagePath}" 
                                                         alt="${combo.comboName}" 
                                                         class="combo-image"
                                                         onerror="this.src='${pageContext.request.contextPath}/assets/user/img/default-combo.png'">
                                                    <div class="combo-details">
                                                        <div class="combo-name">${combo.comboName}</div>
                                                        <div class="combo-price">
                                                            ${combo.formattedPrice} × ${combo.quantity} = <strong>${combo.formattedSubTotal}</strong>
                                                        </div>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </c:if>

                                        <c:if test="${empty order.tickets and empty order.orderCombos}">
                                            <div class="no-items-msg">
                                                Đơn hàng không có sản phẩm
                                            </div>
                                        </c:if>
                                    </div>

                                    <div class="order-total">
                                        Tổng tiền: ${order.formattedTotalMoney}
                                    </div>
                                </div>
                            </c:if>
                        </c:forEach>
                    </div>

                    <div id="noResults" class="no-results" style="display: none;">
                        <div class="no-results-icon">!</div>
                        <h3>Không tìm thấy đơn hàng</h3>
                        <p>Không có đơn hàng nào phù hợp với tìm kiếm của bạn.</p>
                    </div>
                </c:when>

                <c:otherwise>
                    <div class="empty-state">
                        <div class="empty-state-icon">!</div>
                        <h3>Chưa có đơn hàng nào</h3>
                        <p>Bạn chưa có đơn hàng nào trong lịch sử.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <script>
            let currentStatus = 'all';

            document.addEventListener('DOMContentLoaded', function () {
                updateOrderCounts();

                const searchInput = document.getElementById('searchInput');
                if (searchInput) {
                    searchInput.addEventListener('keypress', function (e) {
                        if (e.key === 'Enter') {
                            filterOrders();
                        }
                    });

                    searchInput.addEventListener('input', function () {
                        filterOrders();
                    });
                }
            });

            function updateOrderCounts() {
                const orders = document.querySelectorAll('.order-card');
                const counts = {
                    all: orders.length,
                    pending: 0,
                    paid: 0
                };

                orders.forEach(order => {
                    const status = order.getAttribute('data-order-status');
                    if (status === 'PENDING') {
                        counts.pending++;
                    } else if (status === 'PAID') {
                        counts.paid++;
                    }
                });

                document.getElementById('count-all').textContent = counts.all;
                document.getElementById('count-pending').textContent = counts.pending;
                document.getElementById('count-paid').textContent = counts.paid;
            }

            function filterByStatus(status) {
                currentStatus = status;

                document.querySelectorAll('.filter-tab').forEach(tab => {
                    tab.classList.remove('active');
                });
                event.target.closest('.filter-tab').classList.add('active');

                filterOrders();
            }

            function filterOrders() {
                const searchInput = document.getElementById('searchInput');
                const searchTerm = searchInput ? searchInput.value.toLowerCase().trim() : '';

                const orders = document.querySelectorAll('.order-card');
                let visibleCount = 0;

                orders.forEach(order => {
                    const orderStatus = order.getAttribute('data-order-status');
                    const orderCode = order.getAttribute('data-order-code').toLowerCase();
                    const orderDate = order.getAttribute('data-order-date').toLowerCase();

                    let movieNames = '';
                    let cinemaNames = '';
                    order.querySelectorAll('.ticket-item').forEach(ticket => {
                        const movie = ticket.getAttribute('data-movie-name');
                        const cinema = ticket.getAttribute('data-cinema-name');
                        if (movie)
                            movieNames += movie.toLowerCase() + ' ';
                        if (cinema)
                            cinemaNames += cinema.toLowerCase() + ' ';
                    });

                    const fullSearchText = orderCode + ' ' + orderDate + ' ' + movieNames + ' ' + cinemaNames;

                    let statusMatch = false;
                    if (currentStatus === 'all') {
                        statusMatch = true;
                    } else if (currentStatus === orderStatus) {
                        statusMatch = true;
                    }

                    const searchMatch = searchTerm === '' || fullSearchText.includes(searchTerm);

                    if (statusMatch && searchMatch) {
                        order.style.display = 'block';
                        visibleCount++;
                    } else {
                        order.style.display = 'none';
                    }
                });

                const noResults = document.getElementById('noResults');
                const ordersContainer = document.getElementById('ordersContainer');
                if (visibleCount === 0) {
                    if (noResults)
                        noResults.style.display = 'block';
                    if (ordersContainer)
                        ordersContainer.style.display = 'none';
                } else {
                    if (noResults)
                        noResults.style.display = 'none';
                    if (ordersContainer)
                        ordersContainer.style.display = 'block';
                }
            }
        </script>
    </body>
</html>