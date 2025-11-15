<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.Seat, model.SeatType, java.util.List, java.util.ArrayList, java.util.Map, java.util.HashMap"%>
<%
    List<Seat> seats = (List<Seat>) request.getAttribute("seats");
    Map<String, List<Seat>> seatMap = (Map<String, List<Seat>>) request.getAttribute("seatMap");
    int roomId = (Integer) request.getAttribute("roomId");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Sơ đồ ghế | Cinema Booking</title>
    <style>
        .seat-map-container {
            background: #f8f9fa;
            padding: 30px;
            border-radius: 15px;
            max-width: 1200px;
            margin: 0 auto;
        }
        
        .screen {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            text-align: center;
            padding: 20px;
            margin: 0 50px 40px 50px;
            border-radius: 10px;
            font-weight: bold;
            font-size: 18px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }
        
        .seats-grid {
            display: flex;
            flex-direction: column;
            gap: 15px;
            align-items: center;
        }
        
        .seat-row {
            display: flex;
            gap: 8px;
            align-items: center;
        }
        
        .row-label {
            font-weight: bold;
            color: #333;
            min-width: 30px;
            text-align: center;
        }
        
        .seat {
            width: 35px;
            height: 35px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 10px;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s ease;
            border: 2px solid transparent;
        }
        
        .seat:hover {
            transform: scale(1.1);
        }
        
        /* Seat Types */
        .seat-standard {
            background: #1e90ff;
            color: white;
        }
        
        .seat-vip {
            background: #ffd700;
            color: #333;
        }
        
        .seat-couple {
            background: #ff69b4;
            color: white;
        }
        
        .seat-disabled {
            background: #32CD32;
            color: white;
        }
        
        .seat-occupied {
            background: #ccc;
            color: #666;
            cursor: not-allowed;
        }
        
        .seat-selected {
            border: 3px solid #ff4757;
            transform: scale(1.1);
        }
        
        /* Legend */
        .seat-legend {
            display: flex;
            justify-content: center;
            gap: 20px;
            margin-top: 30px;
            flex-wrap: wrap;
        }
        
        .legend-item {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
        }
        
        .legend-color {
            width: 20px;
            height: 20px;
            border-radius: 4px;
        }
        
        /* Selection Info */
        .selection-info {
            background: white;
            padding: 20px;
            border-radius: 10px;
            margin-top: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .selected-seats {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            margin: 10px 0;
        }
        
        .selected-seat-badge {
            background: #ff4757;
            color: white;
            padding: 5px 10px;
            border-radius: 15px;
            font-size: 12px;
        }
    </style>
</head>
<body>
    <div class="seat-map-container">
        <div class="screen">
            MÀN HÌNH
        </div>
        
        <div class="seats-grid" id="seatsGrid">
            <% 
            // Group seats by row
            Map<String, List<Seat>> rowMap = new HashMap<>();
            if (seats != null) {
                for (Seat seat : seats) {
                    rowMap.computeIfAbsent(seat.getRowCode(), k -> new ArrayList<>()).add(seat);
                }
            }
            
            // Display seats
            List<String> rows = new ArrayList<>(rowMap.keySet());
            Collections.sort(rows);
            
            for (String row : rows) {
            %>
            <div class="seat-row">
                <div class="row-label"><%= row %></div>
                <% 
                List<Seat> rowSeats = rowMap.get(row);
                rowSeats.sort((s1, s2) -> Integer.compare(s1.getColumnNumber(), s2.getColumnNumber()));
                
                for (Seat seat : rowSeats) { 
                %>
                <div class="seat <%= seat.getCssClass() %>" 
                     data-seat-id="<%= seat.getId() %>"
                     data-seat-position="<%= seat.getPosition() %>"
                     data-seat-price="<%= seat.getPrice() %>"
                     onclick="selectSeat(this)">
                    <%= seat.getColumnNumber() %>
                </div>
                <% } %>
            </div>
            <% } %>
        </div>
        
        <!-- Legend -->
        <div class="seat-legend">
            <div class="legend-item">
                <div class="legend-color" style="background: #1e90ff;"></div>
                <span>Ghế Thường</span>
            </div>
            <div class="legend-item">
                <div class="legend-color" style="background: #ffd700;"></div>
                <span>Ghế VIP</span>
            </div>
            <div class="legend-item">
                <div class="legend-color" style="background: #ff69b4;"></div>
                <span>Ghế Đôi</span>
            </div>
            <div class="legend-item">
                <div class="legend-color" style="background: #32CD32;"></div>
                <span>Ghế Khuyết tật</span>
            </div>
            <div class="legend-item">
                <div class="legend-color" style="background: #ccc;"></div>
                <span>Đã đặt</span>
            </div>
        </div>
        
        <!-- Selection Information -->
        <div class="selection-info">
            <h3>Ghế đã chọn:</h3>
            <div class="selected-seats" id="selectedSeats">
                <!-- Selected seats will appear here -->
            </div>
            <div>
                <strong>Tổng cộng: </strong>
                <span id="totalPrice">0</span> VND
            </div>
            <button onclick="proceedToBooking()" style="
                background: linear-gradient(135deg, #00d4ff 0%, #0099ff 100%);
                color: white;
                border: none;
                padding: 12px 30px;
                border-radius: 8px;
                cursor: pointer;
                margin-top: 15px;
                font-weight: bold;
            ">Tiếp tục đặt vé</button>
        </div>
    </div>

    <script>
        let selectedSeats = [];
        let totalPrice = 0;
        
        function selectSeat(seatElement) {
            const seatId = seatElement.getAttribute('data-seat-id');
            const seatPosition = seatElement.getAttribute('data-seat-position');
            const seatPrice = parseFloat(seatElement.getAttribute('data-seat-price'));
            
            // Check if seat is available
            if (seatElement.classList.contains('seat-occupied')) {
                alert('Ghế này đã được đặt!');
                return;
            }
            
            // Toggle selection
            if (seatElement.classList.contains('seat-selected')) {
                // Deselect
                seatElement.classList.remove('seat-selected');
                selectedSeats = selectedSeats.filter(seat => seat.id !== seatId);
                totalPrice -= seatPrice;
            } else {
                // Select
                seatElement.classList.add('seat-selected');
                selectedSeats.push({
                    id: seatId,
                    position: seatPosition,
                    price: seatPrice
                });
                totalPrice += seatPrice;
            }
            
            updateSelectionDisplay();
        }
        
        function updateSelectionDisplay() {
            const selectedSeatsContainer = document.getElementById('selectedSeats');
            const totalPriceElement = document.getElementById('totalPrice');
            
            selectedSeatsContainer.innerHTML = '';
            selectedSeats.forEach(seat => {
                const badge = document.createElement('div');
                badge.className = 'selected-seat-badge';
                badge.textContent = `${seat.position} - ${seat.price.toLocaleString()} VND`;
                selectedSeatsContainer.appendChild(badge);
            });
            
            totalPriceElement.textContent = totalPrice.toLocaleString();
        }
        
        function proceedToBooking() {
            if (selectedSeats.length === 0) {
                alert('Vui lòng chọn ít nhất một ghế!');
                return;
            }
            
            // Chuyển đến trang booking với danh sách ghế đã chọn
            const seatIds = selectedSeats.map(seat => seat.id).join(',');
            window.location.href = '${pageContext.request.contextPath}/booking?seatIds=' + seatIds + '&roomId=<%= roomId %>';
        }
    </script>
</body>
</html>