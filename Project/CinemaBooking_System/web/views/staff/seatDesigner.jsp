<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.Seat, model.SeatType, java.util.List, java.util.Map"%>
<%
    int roomId = (int) request.getAttribute("roomId");
    Map<String, Object> roomLayout = (Map<String, Object>) request.getAttribute("roomLayout");
    List<Seat> seats = (List<Seat>) request.getAttribute("seats");
    List<SeatType> seatTypes = (List<SeatType>) request.getAttribute("seatTypes");
    String error = (String) request.getAttribute("error");
    String success = request.getParameter("success");
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Thiết kế Ghế - <%= roomLayout.get("name") %> | Cinema Booking</title>
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

            /* ===== Sidebar ===== */
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

            .sidebar-logo p {
                font-size: 11px;
                color: #6b7280;
                margin-top: 5px;
                text-transform: uppercase;
                letter-spacing: 2px;
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

            .sidebar a::before {
                content: '';
                position: absolute;
                left: 0;
                top: 0;
                height: 100%;
                width: 4px;
                background: linear-gradient(180deg, #00d4ff 0%, #0099ff 100%);
                transform: scaleY(0);
                transition: transform 0.3s ease;
            }

            .sidebar a:hover {
                background: #e6f7ff;
                color: #007bff;
                padding-left: 35px;
            }

            .sidebar a:hover::before {
                transform: scaleY(1);
            }

            .sidebar a.active {
                background: #e6f7ff;
                color: #007bff;
                padding-left: 35px;
            }

            .sidebar a.active::before {
                transform: scaleY(1);
            }

            .sidebar a.logout {
                margin-top: auto;
                background: rgba(239, 68, 68, 0.1);
                color: #ef4444;
                margin: 20px 20px 0;
                border-radius: 12px;
                justify-content: center;
            }

            .sidebar a.logout:hover {
                background: rgba(239, 68, 68, 0.2);
                padding-left: 30px;
            }

            /* ===== Header ===== */
            header {
                margin-left: 280px;
                background: rgba(255, 255, 255, 0.8);
                backdrop-filter: blur(20px);
                border-bottom: 1px solid #e2e8f0;
                padding: 20px 40px;
                display: flex;
                justify-content: space-between;
                align-items: center;
                position: sticky;
                top: 0;
                z-index: 100;
            }

            header h1 {
                font-size: 28px;
                font-weight: 700;
                color: #1a202c;
            }

            .header-right {
                display: flex;
                align-items: center;
                gap: 35px;
            }

            .header-right span {
                font-weight: 500;
                color: #4a5568;
                font-size: 14px;
                display: flex;
                align-items: center;
                gap: 8px;
            }

            /* ===== Content ===== */
            .content {
                margin-left: 280px;
                padding: 40px;
            }

            /* ===== Designer Container ===== */
            .designer-container {
                display: flex;
                gap: 30px;
                background: #ffffff;
                border: 1px solid #e2e8f0;
                border-radius: 20px;
                padding: 30px;
                box-shadow: 0 10px 20px rgba(0, 0, 0, 0.05);
            }

            /* ===== Tool Panel ===== */
            .tool-panel {
                width: 300px;
                background: #f8f9fa;
                border: 1px solid #e2e8f0;
                border-radius: 16px;
                padding: 25px;
                display: flex;
                flex-direction: column;
                gap: 25px;
            }

            .panel-section {
                background: #ffffff;
                border: 1px solid #e2e8f0;
                border-radius: 12px;
                padding: 20px;
            }

            .panel-section h3 {
                font-size: 16px;
                font-weight: 600;
                color: #1a202c;
                margin-bottom: 15px;
                display: flex;
                align-items: center;
                gap: 8px;
            }

            .seat-type-list {
                display: flex;
                flex-direction: column;
                gap: 12px;
            }

            .seat-type-item {
                display: flex;
                align-items: center;
                gap: 12px;
                padding: 12px;
                border: 2px solid transparent;
                border-radius: 8px;
                cursor: pointer;
                transition: all 0.3s ease;
                background: #ffffff;
            }

            .seat-type-item:hover {
                border-color: #007bff;
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(0, 123, 255, 0.15);
            }

            .seat-type-item.active {
                border-color: #007bff;
                background: #e6f7ff;
            }

            .seat-preview {
                width: 24px;
                height: 24px;
                border-radius: 4px;
                border: 2px solid currentColor;
                background: currentColor;
                opacity: 0.8;
            }

            .seat-type-item.active .seat-preview {
                transform: scale(1.1);
                box-shadow: 0 0 0 2px #007bff;
            }

            .seat-type-info {
                flex: 1;
            }

            .seat-type-name {
                font-weight: 600;
                font-size: 14px;
                color: #1a202c;
            }

            .seat-type-price {
                font-size: 12px;
                color: #6b7280;
            }

            .tool-actions {
                display: flex;
                flex-direction: column;
                gap: 12px;
            }

            .btn {
                padding: 12px 20px;
                border: none;
                border-radius: 12px;
                font-size: 14px;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.3s ease;
                text-decoration: none;
                text-align: center;
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 8px;
            }

            .btn-primary {
                background: linear-gradient(135deg, #00d4ff 0%, #0099ff 100%);
                color: white;
            }

            .btn-primary:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 25px rgba(0, 123, 255, 0.3);
            }

            .btn-secondary {
                background: #6c757d;
                color: #ffffff;
                border: 1px solid #6c757d;
            }

            .btn-secondary:hover {
                background: #5a6268;
                transform: translateY(-2px);
            }

            .btn-success {
                background: linear-gradient(135deg, #10b981 0%, #059669 100%);
                color: white;
            }

            .btn-success:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 25px rgba(16, 185, 129, 0.3);
            }

            .btn-warning {
                background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
                color: white;
            }

            .btn-warning:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 25px rgba(245, 158, 11, 0.3);
            }

            /* ===== Design Area ===== */
            .design-area {
                flex: 1;
                display: flex;
                flex-direction: column;
                gap: 20px;
            }

            .design-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 0 10px;
            }

            .design-header h2 {
                font-size: 20px;
                font-weight: 700;
                color: #1a202c;
            }

            .room-info {
                background: #f8f9fa;
                border: 1px solid #e2e8f0;
                border-radius: 12px;
                padding: 15px 20px;
                display: flex;
                gap: 30px;
                font-size: 14px;
            }

            .info-item {
                display: flex;
                flex-direction: column;
                gap: 4px;
            }

            .info-label {
                color: #6b7280;
                font-weight: 500;
                font-size: 12px;
                text-transform: uppercase;
                letter-spacing: 1px;
            }

            .info-value {
                color: #1a202c;
                font-weight: 600;
                font-size: 16px;
            }

            /* ===== Cinema Screen ===== */
            .cinema-screen {
                background: linear-gradient(135deg, #4b5563 0%, #6b7280 100%);
                color: white;
                text-align: center;
                padding: 20px;
                border-radius: 12px;
                margin: 0 40px 30px 40px;
                font-weight: 600;
                font-size: 18px;
                box-shadow: 0 8px 25px rgba(0, 0, 0, 0.2);
                position: relative;
            }

            .cinema-screen::before {
                content: '';
                position: absolute;
                top: -10px;
                left: 20px;
                right: 20px;
                height: 20px;
                background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
                border-radius: 50%;
                filter: blur(10px);
                opacity: 0.6;
            }

            /* ===== Seat Grid ===== */
            .seat-grid-container {
                flex: 1;
                background: #f8f9fa;
                border: 1px solid #e2e8f0;
                border-radius: 16px;
                padding: 30px;
                overflow: auto;
                position: relative;
            }

            .seat-grid {
                display: grid;
                gap: 8px;
                margin: 0 auto;
                max-width: max-content;
            }

            .grid-row {
                display: flex;
                gap: 8px;
                align-items: center;
            }

            .row-label {
                width: 30px;
                text-align: center;
                font-weight: 600;
                color: #4a5568;
                font-size: 14px;
            }

            .grid-cell {
                width: 40px;
                height: 40px;
                border: 2px dashed #e2e8f0;
                border-radius: 6px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 10px;
                color: #9ca3af;
                background: #ffffff;
                transition: all 0.3s ease;
                position: relative;
                overflow: visible !important;
            }

            .grid-cell.occupied {
                border-style: solid;
                border-color: transparent;
                background: transparent;
            }

            .grid-cell.drop-zone {
                background: #e6f7ff !important;
                border-color: #007bff !important;
                border-style: dashed !important;
            }

            .grid-cell.occupied {
                cursor: not-allowed;
            }

            /* ===== SEAT STYLES - CHỈ MỘT ĐỊNH NGHĨA DUY NHẤT ===== */
            .seat {
                width: 100%;
                height: 100%;
                border: 2px solid;
                border-radius: 6px;
                display: flex !important;
                align-items: center !important;
                justify-content: center !important;
                font-size: 10px !important;
                font-weight: 700 !important;
                color: white !important;
                cursor: grab;
                transition: all 0.3s ease;
                position: relative;
                user-select: none;
                text-shadow: 1px 1px 1px rgba(0,0,0,0.7);
                text-align: center;
                line-height: 1.2;
                padding: 2px;
                overflow: visible !important;
                z-index: 1;
                box-sizing: border-box;
                -webkit-text-fill-color: white !important;
                text-rendering: optimizeLegibility;
                -webkit-font-smoothing: antialiased;
                -moz-osx-font-smoothing: grayscale;
            }

            .seat:hover {
                transform: scale(1.1);
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
                z-index: 10;
            }

            .seat:active {
                cursor: grabbing;
            }

            .seat.dragging {
                opacity: 0.7;
                transform: scale(1.05);
            }

            .seat.double {
                width: calc(200% + 8px) !important;
                position: relative;
                z-index: 10;
                font-size: 9px !important;
                line-height: 1.1;
            }

            .seat.disabled {
                opacity: 0.5;
                cursor: not-allowed;
            }

            /* Fix double seat positioning */
            .grid-cell.occupied:nth-child(n+2) .seat.double {
                margin-left: -100%;
            }

            /* ===== Seat Colors - ĐẢM BẢO MÀU HIỂN THỊ ĐÚNG ===== */
            .seat[style*="#1e90ff"] {
                background: #1e90ff !important;
                border-color: #1e90ff !important;
            }

            .seat[style*="#ffd700"] {
                background: #ffd700 !important;
                border-color: #ffd700 !important;
            }

            .seat[style*="#ff69b4"] {
                background: #ff69b4 !important;
                border-color: #ff69b4 !important;
            }

            .seat[style*="#32CD32"] {
                background: #32CD32 !important;
                border-color: #32CD32 !important;
            }

            .seat[style*="#a11212"] {
                background: #a11212 !important;
                border-color: #a11212 !important;
            }

            /* Seat type preview colors */
            .seat-type-item[data-color="#1e90ff"] .seat-preview {
                background: #1e90ff;
                border-color: #1e90ff;
            }

            .seat-type-item[data-color="#ffd700"] .seat-preview {
                background: #ffd700;
                border-color: #ffd700;
            }

            .seat-type-item[data-color="#ff69b4"] .seat-preview {
                background: #ff69b4;
                border-color: #ff69b4;
            }

            .seat-type-item[data-color="#32CD32"] .seat-preview {
                background: #32CD32;
                border-color: #32CD32;
            }

            .seat-type-item[data-color="#a11212"] .seat-preview {
                background: #a11212;
                border-color: #a11212;
            }

            /* ===== Alert Messages ===== */
            .alert {
                padding: 15px 20px;
                border-radius: 12px;
                margin-bottom: 25px;
                font-weight: 600;
            }

            .alert-success {
                background: rgba(16, 185, 129, 0.2);
                color: #10b981;
                border: 1px solid rgba(16, 185, 129, 0.3);
            }

            .alert-error {
                background: rgba(239, 68, 68, 0.2);
                color: #ef4444;
                border: 1px solid rgba(239, 68, 68, 0.3);
            }

            /* ===== Footer ===== */
            footer {
                background: #ffffff;
                border-top: 1px solid #e2e8f0;
                color: #6b7280;
                text-align: center;
                padding: 25px;
                margin-left: 280px;
                margin-top: 40px;
                font-size: 14px;
            }

            /* ===== Drag and Drop ===== */
            .seat-type-item[draggable="true"] {
                cursor: grab;
            }

            .seat-type-item[draggable="true"]:active {
                cursor: grabbing;
            }

            /* ===== Responsive ===== */
            @media (max-width: 1024px) {
                .designer-container {
                    flex-direction: column;
                }
                .tool-panel {
                    width: 100%;
                }
            }

            @media (max-width: 768px) {
                .sidebar {
                    width: 100%;
                    height: auto;
                    position: relative;
                }
                header, .content, footer {
                    margin-left: 0;
                }
                .room-info {
                    flex-direction: column;
                    gap: 15px;
                }
                .cinema-screen {
                    margin: 0 20px 20px 20px;
                    font-size: 16px;
                }
            }
        </style>
    </head>
    <body>

        <div class="sidebar">
            <div class="sidebar-logo">
                <h2>🎬 CINEMA PRO</h2>
                <p>Staff Panel</p>
            </div>
            <nav>
                <a href="${pageContext.request.contextPath}/staffdashboard">🏢 Thông tin rạp của tôi</a>
                <a href="${pageContext.request.contextPath}/staff/rooms">🎭 Quản lý phòng chiếu</a>
                <a href="${pageContext.request.contextPath}/staff/seat-design?roomId=<%= roomId %>" class="active">💺 Thiết kế ghế trong phòng</a>
               <a href="${pageContext.request.contextPath}/staff/schedules">📅 Quản lý lịch chiếu</a>
                <a href="${pageContext.request.contextPath}/views/staff/bookingManager.jsp">🎫 Quản lý đặt vé</a>
                <a href="${pageContext.request.contextPath}/views/staff/cinemaReports.jsp">📈 Báo cáo rạp của tôi</a>
            </nav>
            <a href="${pageContext.request.contextPath}/logout" class="logout">🚪 Đăng xuất</a>
        </div>

        <header>
            <h1>💺 Thiết kế Ghế - <%= roomLayout.get("name") %></h1>
            <div class="header-right">
                <span>👤 Staff: <%= session.getAttribute("staffName") != null ? session.getAttribute("staffName") : "Nhân viên" %></span>
                <span>⏰ <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %></span>
            </div>
        </header>

        <div class="content">

            <% if (success != null) { %>
            <div class="alert alert-success">
                <% 
                    switch(success) {
                        case "generate": 
                            out.print("✅ Tạo layout ghế mặc định thành công!");
                            break;
                        case "save":
                            out.print("✅ Lưu thiết kế ghế thành công!");
                            break;
                    }
                %>
            </div>
            <% } %>

            <% if (error != null) { %>
            <div class="alert alert-error">
                ❌ <%= error %>
            </div>
            <% } %>

            <div class="designer-container">
                <!-- Tool Panel -->
                <div class="tool-panel">
                    <div class="panel-section">
                        <h3>🎨 Loại Ghế</h3>
                        <div class="seat-type-list" id="seatTypeList">
                            <% for (SeatType seatType : seatTypes) { %>
                            <div class="seat-type-item" data-type-id="<%= seatType.getId() %>" 
                                 data-color="<%= seatType.getColor() %>" 
                                 data-width="<%= "COUPLE".equals(seatType.getCode()) ? 2 : 1 %>">
                                <div class="seat-preview" style="color: <%= seatType.getColor() %>;"></div>
                                <div class="seat-type-info">
                                    <div class="seat-type-name"><%= seatType.getName() %></div>
                                    <div class="seat-type-price">Phụ phí: +<%= String.format("%,.0f", seatType.getSurcharge()) %> đ</div>
                                </div>
                            </div>
                            <% } %>
                        </div>
                    </div>

                    <div class="panel-section">
                        <h3>🛠️ Công cụ</h3>
                        <div class="tool-actions">
                            <button type="button" class="btn btn-warning" id="btnGenerateDefault">
                                🔄 Tạo Layout Mặc định
                            </button>
                            <button type="button" class="btn btn-secondary" id="btnClearAll">
                                🗑️ Xóa Tất cả
                            </button>
                            <button type="button" class="btn btn-success" id="btnSaveDesign">
                                💾 Lưu Thiết kế
                            </button>
                        </div>
                    </div>

                    <div class="panel-section">
                        <h3>ℹ️ Hướng dẫn</h3>
                        <div style="font-size: 13px; color: #6b7280; line-height: 1.5;">
                            <p>• <strong>Kéo thả</strong> ghế từ danh sách vào lưới</p>
                            <p>• <strong>Di chuyển</strong> ghế bằng cách kéo</p>
                            <p>• <strong>Xóa</strong> ghế bằng cách kéo ra khỏi lưới</p>
                            <p>• Ghế <strong>đôi</strong> chiếm 2 ô ngang</p>
                        </div>
                    </div>
                </div>

                <!-- Design Area -->
                <div class="design-area">
                    <div class="design-header">
                        <h2>Thiết kế Layout Ghế</h2>
                        <div class="room-info">
                            <div class="info-item">
                                <span class="info-label">Phòng</span>
                                <span class="info-value"><%= roomLayout.get("code") %></span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Layout</span>
                                <span class="info-value"><%= roomLayout.get("rows") %> x <%= roomLayout.get("columns") %></span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Sức chứa</span>
                                <span class="info-value"><%= roomLayout.get("capacity") %> ghế</span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Loại phòng</span>
                                <span class="info-value"><%= roomLayout.get("screenType") %></span>
                            </div>
                        </div>
                    </div>

                    <!-- Cinema Screen -->
                    <div class="cinema-screen">
                        🎬 MÀN HÌNH CHÍNH 🎬
                    </div>

                    <!-- Seat Grid -->
                    <div class="seat-grid-container">
                        <div class="seat-grid" id="seatGrid">
                            <!-- Grid will be generated by JavaScript -->
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <footer>
            © 2025 Cinema Booking System - Staff Panel | Powered by Modern Technology
        </footer>
        <script>
            console.log('=== STARTING SEAT DESIGNER ===');
            // Basic configuration
            const config = {
                roomId: <%= roomId %>,
                rows: <%= roomLayout.get("rows") %>,
                columns: <%= roomLayout.get("columns") %>,
                capacity: <%= roomLayout.get("capacity") %>
            };
            console.log('Config loaded:', config);
            // Simple state
            let currentSeatType = null;
            let seats = [];
            // Try to load seats from server safely
            try {
                seats = <%= seats != null ? "[" + seats.stream()
       .map(s -> String.format("{id: %d, code: '%s', typeId: %d, color: '%s', x: %d, y: %d, width: %d, height: %d}", 
           s.getId(), s.getCode() != null ? s.getCode() : "EMPTY_CODE", s.getSeatTypeId(), 
           s.getCustomColor() != null ? s.getCustomColor() : s.getTypeColor(), 
           s.getPositionX(), s.getPositionY(), s.getWidthUnits(), s.getHeightUnits()))
       .reduce((a, b) -> a + "," + b).orElse("") + "]" : "[]" %>;
                console.log('🔵 Seats loaded from server:', seats);
                console.log('🔵 First seat sample:', seats.length > 0 ? seats[0] : 'No seats');
            } catch (error) {
                console.error('❌ Error loading seats:', error);
                seats = [];
            }

            // Basic initialization
            document.addEventListener('DOMContentLoaded', function () {
                console.log('🔵 DOM loaded, initializing...');
                try {
                    initializeSeatTypes();
                    initializeGrid();
                    initializeDragAndDrop();
                    attachEventListeners();
                    console.log('✅ Initialization completed');
                } catch (error) {
                    console.error('❌ Initialization error:', error);
                }
            });
            function initializeSeatTypes() {
                console.log('🔵 Initializing seat types...');
                const seatTypeItems = document.querySelectorAll('.seat-type-item');
                console.log('🔵 Found seat types:', seatTypeItems.length);
                seatTypeItems.forEach((item, index) => {
                    const typeId = parseInt(item.dataset.typeId);
                    const color = item.dataset.color;
                    const width = parseInt(item.dataset.width);
                    console.log(`🔵 Seat type ${index}:`, {typeId, color, width});
                    item.addEventListener('click', function () {
                        seatTypeItems.forEach(i => i.classList.remove('active'));
                        this.classList.add('active');
                        currentSeatType = {
                            id: typeId,
                            color: color,
                            width: width
                        };
                        console.log('🔵 Current seat type set:', currentSeatType);
                    });
                });
                // Select first seat type by default
                if (seatTypeItems.length > 0) {
                    seatTypeItems[0].click();
                }
            }
            function generateRowLetters(numRows) {
                const letters = [];
                for (let i = 0; i < numRows; i++) {
                    if (i < 26) {
                        // A-Z
                        letters.push(String.fromCharCode(65 + i));
                    } else {
                        // AA, AB, AC, ... BA, BB, ...
                        const firstLetter = String.fromCharCode(65 + Math.floor((i - 26) / 26));
                        const secondLetter = String.fromCharCode(65 + ((i - 26) % 26));
                        letters.push(firstLetter + secondLetter);
                    }
                }
                return letters;
            }
            function initializeGrid() {
                console.log('🔵 Initializing grid...');
                const grid = document.getElementById('seatGrid');
                if (!grid) {
                    console.error('❌ Grid element not found!');
                    return;
                }

                const rows = config.rows;
                const columns = config.columns;
                console.log('🔵 Creating grid:', rows + 'x' + columns);

                // Clear existing grid
                grid.innerHTML = '';

                // SỬA: Generate row letters dynamic theo số rows
                const rowLetters = generateRowLetters(rows);

                for (let y = 0; y < rows; y++) {
                    const rowDiv = document.createElement('div');
                    rowDiv.className = 'grid-row';

                    // Add row label
                    const rowLabel = document.createElement('div');
                    rowLabel.className = 'row-label';
                    rowLabel.textContent = rowLetters[y];
                    rowDiv.appendChild(rowLabel);

                    // Add cells
                    for (let x = 0; x < columns; x++) {
                        const cell = document.createElement('div');
                        cell.className = 'grid-cell';
                        cell.dataset.x = x;
                        cell.dataset.y = y;

                        // Check if this cell has a seat and render it immediately
                        const seat = findSeatAtPosition(x, y);
                        if (seat) {
                            cell.classList.add('occupied');
                            const seatElement = createSeatElement(seat);
                            cell.appendChild(seatElement);
                            console.log('🟢 Rendered existing seat:', seat.code, 'at', x, y, 'color:', seat.color);
                        }
                        rowDiv.appendChild(cell);
                    }
                    grid.appendChild(rowDiv);
                }

                console.log('✅ Grid created successfully with', seats.length, 'seats');
                initializeDragAndDrop();
                updateSeatCounter();
            }
            function refreshGrid() {
                console.log('🔵 Refreshing grid display...');
                initializeGrid(); // Use initializeGrid instead of manual refresh
            }

            function findSeatAtPosition(x, y) {
                const seat = seats.find(seat => seat.x === x && seat.y === y);
                console.log('🔍 Finding seat at position:', x, y, 'found:', seat);
                return seat;
            }

            function createSeatElement(seat) {
                console.log('🎨 Creating seat element for:', seat);
                const seatElement = document.createElement('div');
                seatElement.className = 'seat';
                // Set color
                seatElement.style.borderColor = seat.color;
                seatElement.style.backgroundColor = seat.color;
                seatElement.style.color = getContrastColor(seat.color);
                // FALLBACK TEXT NẾU CODE RỖNG
                let displayText = seat.code;
                if (!displayText || displayText.trim() === '') {
                    const rowLetters = generateRowLetters(config.rows);
                    const rowLetter = rowLetters[seat.y] || `R${seat.y+1}`;
                    displayText = `${rowLetter}${seat.x+1}`;
                    console.log('🔄 Using fallback display text:', displayText);
                }

                seatElement.textContent = displayText;
                console.log('🎨 Final seat text:', seatElement.textContent);
                seatElement.draggable = true;
                seatElement.dataset.seatId = seat.id;
                if (seat.width > 1) {
                    seatElement.classList.add('double');
                    seatElement.style.width = `calc(${seat.width * 100}% + ${(seat.width - 1) * 8}px)`;
                }

                // Add events
                seatElement.addEventListener('dragstart', handleSeatDragStart);
                seatElement.addEventListener('dragend', handleSeatDragEnd);
                seatElement.addEventListener('dblclick', function () {
                    removeSeat(seat.id);
                });
                return seatElement;
            }

            function clearAllSeats() {
                if (confirm('Bạn có chắc muốn xóa tất cả ghế?')) {
                    seats = [];
                    refreshGrid();
                    updateSeatCounter();
                }
            }

            function initializeDragAndDrop() {
                console.log('🔵 Initializing drag and drop...');
                const seatTypeItems = document.querySelectorAll('.seat-type-item');
                const gridCells = document.querySelectorAll('.grid-cell');
                console.log('🔵 Making seat types draggable:', seatTypeItems.length);
                // Make seat types draggable
                seatTypeItems.forEach(item => {
                    item.setAttribute('draggable', 'true');
                    item.addEventListener('dragstart', function (e) {
                        if (!currentSeatType) {
                            e.preventDefault();
                            console.log('❌ No seat type selected');
                            return;
                        }

                        const dragData = {
                            typeId: currentSeatType.id,
                            color: currentSeatType.color,
                            width: currentSeatType.width,
                            action: 'create'
                        };
                        e.dataTransfer.setData('text/plain', JSON.stringify(dragData));
                        e.dataTransfer.effectAllowed = 'copy';
                        console.log('🔵 Drag started with:', dragData, 'Color:', currentSeatType.color);
                        this.style.opacity = '0.4';
                    });
                    item.addEventListener('dragend', function (e) {
                        this.style.opacity = '1';
                        console.log('🔵 Drag ended');
                    });
                });
                console.log('🔵 Making grid cells drop targets:', gridCells.length);
                // Make grid cells drop targets with better visual feedback
                gridCells.forEach(cell => {
                    cell.addEventListener('dragover', function (e) {
                        e.preventDefault();
                        if (!cell.classList.contains('occupied')) {
                            this.style.backgroundColor = '#e6f7ff';
                            this.style.borderColor = '#007bff';
                            this.style.borderStyle = 'dashed';
                            this.classList.add('drop-zone');
                        }
                    });
                    cell.addEventListener('dragleave', function (e) {
                        if (!cell.classList.contains('occupied')) {
                            this.style.backgroundColor = '#ffffff';
                            this.style.borderColor = '#e2e8f0';
                            this.style.borderStyle = 'dashed';
                            this.classList.remove('drop-zone');
                        }
                    });
                    cell.addEventListener('drop', function (e) {
                        e.preventDefault();
                        this.style.backgroundColor = '#ffffff';
                        this.style.borderColor = '#e2e8f0';
                        this.style.borderStyle = 'dashed';
                        this.classList.remove('drop-zone');
                        const x = parseInt(this.dataset.x);
                        const y = parseInt(this.dataset.y);
                        console.log('🎯 Drop at:', x, y, 'Occupied:', cell.classList.contains('occupied'));
                        if (cell.classList.contains('occupied')) {
                            alert('Vị trí này đã có ghế!');
                            return;
                        }

                        if (!currentSeatType) {
                            alert('Vui lòng chọn loại ghế trước!');
                            return;
                        }

                        try {
                            const data = JSON.parse(e.dataTransfer.getData('text/plain'));
                            console.log('🎯 Drop data:', data, 'Color:', data.color);
                            if (data.action === 'create') {
                                createSeatAtPosition(x, y, data);
                            }
                        } catch (error) {
                            console.error('❌ Error parsing drop data:', error);
                        }
                    });
                });
            }

            function handleSeatDragStart(e) {
                const seatId = e.target.dataset.seatId;
                const dragData = {
                    action: 'move',
                    seatId: seatId
                };
                e.dataTransfer.setData('text/plain', JSON.stringify(dragData));
                e.dataTransfer.effectAllowed = 'move';
                console.log('🔵 Seat drag started:', seatId);
                e.target.style.opacity = '0.4';
            }

            function handleSeatDragEnd(e) {
                e.target.style.opacity = '1';
                console.log('🔵 Seat drag ended');
            }

            function createSeatAtPosition(x, y, seatData) {
                console.log('🆕 Creating seat at:', x, y, 'with data:', seatData, 'Color:', seatData.color);

                // Kiểm tra vị trí có khả dụng không
                if (!isPositionAvailable(x, y, seatData.width, 1)) {
                    alert('Vị trí không khả dụng! Có thể đã có ghế khác hoặc không đủ chỗ cho ghế đôi.');
                    return;
                }

                // SỬA: Generate row letters dynamic
                const rowLetters = generateRowLetters(config.rows);

                // Kiểm tra y có trong range không
                if (y >= rowLetters.length || y < 0) {
                    console.error('❌ Invalid row index:', y);
                    alert('Hàng không hợp lệ!');
                    return;
                }

                const rowLetter = rowLetters[y];
                console.log('🔤 Row letter for y=' + y + ':', rowLetter);

                if (!rowLetter) {
                    console.error('❌ Row letter is undefined for y=' + y);
                    alert('Lỗi: Không thể xác định tên hàng!');
                    return;
                }

                // Lấy số thứ tự tiếp theo cho hàng
                let seatNumber = getNextSeatNumberInRow(y);
                console.log('🔢 Seat number for row', y, ':', seatNumber);

                // Đối với ghế đôi, đảm bảo số là lẻ (1, 3, 5,...)
                if (seatData.width > 1) {
                    if (seatNumber % 2 === 0) {
                        seatNumber += 1;
                    }
                    console.log('🔢 Adjusted seat number for couple seat:', seatNumber);
                }

                // Tạo mã ghế - THÊM KIỂM TRA CHẶT CHẼ
                let seatCode;
                if (seatData.width > 1) {
                    // Sử dụng string concatenation thay vì template string
                    seatCode = rowLetter + seatNumber + '-' + (seatNumber + 1);
                } else {
                    seatCode = rowLetter + seatNumber;
                }

                console.log('🏷️ Final seat code:', seatCode);
                console.log('🔍 Debug seat code parts:', {rowLetter, seatNumber, seatCode});

                if (!seatCode || seatCode.trim() === '' || seatCode.includes('undefined') || seatCode.includes('null')) {
                    console.error('❌ INVALID seatCode:', seatCode);
                    console.log('🔍 Type of rowLetter:', typeof rowLetter, 'value:', rowLetter);
                    console.log('🔍 Type of seatNumber:', typeof seatNumber, 'value:', seatNumber);

                    // Fallback cứng
                    seatCode = 'A' + seatNumber;
                    console.log('🔄 Using hardcoded fallback seatCode:', seatCode);
                }

                const newSeat = {
                    id: 'temp_' + Date.now(),
                    code: seatCode,
                    typeId: seatData.typeId,
                    color: seatData.color,
                    x: x,
                    y: y,
                    width: seatData.width,
                    height: 1
                };

                console.log('🆕 New seat created:', newSeat);

                seats.push(newSeat);

                // Cập nhật hiển thị
                initializeGrid();
                updateSeatCounter();

                console.log('✅ Seat added successfully:', seatCode);
            }
            function renderSeatOnGrid(seat) {
                console.log('🎨 Rendering seat:', seat.code, 'at:', seat.x, seat.y, 'color:', seat.color, 'width:', seat.width);
                // Chỉ render ở ô đầu tiên cho ghế đôi
                const cell = document.querySelector(`.grid-cell[data-x="${seat.x}"][data-y="${seat.y}"]`);
                if (!cell) {
                    console.error('❌ Cell not found at:', seat.x, seat.y);
                    return;
                }

                // Đánh dấu tất cả các ô bị chiếm
                for (let i = 0; i < seat.width; i++) {
                    const occupiedCell = document.querySelector(`.grid-cell[data-x="${seat.x + i}"][data-y="${seat.y}"]`);
                    if (occupiedCell) {
                        occupiedCell.classList.add('occupied');
                        // Clear nội dung các ô bị chiếm (trừ ô đầu tiên)
                        if (i > 0) {
                            occupiedCell.innerHTML = '';
                        }
                    }
                }

                // Chỉ tạo element ghế ở ô đầu tiên
                cell.innerHTML = '';
                const seatElement = document.createElement('div');
                seatElement.className = `seat ${seat.width > 1 ? 'double' : ''}`;
                // Set màu và text với font size phù hợp
                seatElement.style.borderColor = seat.color;
                seatElement.style.backgroundColor = seat.color;
                seatElement.style.color = getContrastColor(seat.color);
                seatElement.textContent = seat.code || 'DEBUG-' + seat.id; // DEBUG: Fallback text
                seatElement.style.fontSize = seat.width > 1 ? '9px' : '10px';
                seatElement.style.fontWeight = '700';
                seatElement.dataset.seatId = seat.id;
                seatElement.draggable = true;
                // Set width cho ghế đôi
                if (seat.width > 1) {
                    seatElement.style.width = `calc(${seat.width * 100}% + ${(seat.width - 1) * 8}px)`;
                    seatElement.style.zIndex = '10';
                }

                // Add events
                seatElement.addEventListener('dragstart', handleSeatDragStart);
                seatElement.addEventListener('dragend', handleSeatDragEnd);
                seatElement.addEventListener('dblclick', function () {
                    removeSeat(seat.id);
                });
                cell.appendChild(seatElement);
                console.log('✅ Seat rendered successfully:', seat.code);
            }

            function getContrastColor(hexcolor) {
                // Remove the # if present
                hexcolor = hexcolor.replace("#", "");
                // Convert to RGB
                const r = parseInt(hexcolor.substr(0, 2), 16);
                const g = parseInt(hexcolor.substr(2, 2), 16);
                const b = parseInt(hexcolor.substr(4, 2), 16);
                // Calculate luminance
                const luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
                // Return black or white based on luminance
                return luminance > 0.5 ? '#000000' : '#ffffff';
            }

            function isPositionAvailable(x, y, width, height) {
                console.log('🔍 Checking position availability:', x, y, 'size:', width, height);
                // Kiểm tra xem có vượt quá biên không (index bắt đầu từ 0)
                if (x < 0 || y < 0 || x + width > config.columns || y + height > config.rows) {
                    console.log('❌ Position out of bounds');
                    return false;
                }

                // Kiểm tra từng ô
                for (let i = 0; i < width; i++) {
                    for (let j = 0; j < height; j++) {
                        const checkX = x + i;
                        const checkY = y + j;
                        // Kiểm tra nếu ô đã bị chiếm
                        const existingSeat = findSeatAtPosition(checkX, checkY);
                        if (existingSeat) {
                            console.log('❌ Position occupied by seat:', existingSeat.code, 'at', checkX, checkY);
                            return false;
                        }
                    }
                }

                console.log('✅ Position available');
                return true;
            }

            function getNextSeatNumberInRow(row) {
                console.log('🔄 getNextSeatNumberInRow CALLED for row:', row);
                const seatsInRow = seats.filter(s => s.y === row);

                console.log('🔢 Seats in row', row, ':', seatsInRow.map(s => ({code: s.code, x: s.x})));

                if (seatsInRow.length === 0) {
                    console.log('🔢 No seats in row, starting from 1');
                    return 1;
                }

                // Tìm số lớn nhất hiện có
                let maxNumber = 0;
                seatsInRow.forEach(seat => {
                    console.log('🔢 Processing seat code:', seat.code);

                    if (seat.code && seat.code.trim() !== '') {
                        // Xử lý đặc biệt cho ghế đôi (A1-2) và ghế đơn (A1)
                        let seatNumbers = [];

                        if (seat.code.includes('-')) {
                            const parts = seat.code.split('-');
                            parts.forEach(part => {
                                const num = parseInt(part.replace(/[^\d]/g, ''));
                                if (!isNaN(num))
                                    seatNumbers.push(num);
                            });
                        } else {
                            const num = parseInt(seat.code.replace(/[^\d]/g, ''));
                            if (!isNaN(num))
                                seatNumbers.push(num);
                        }

                        console.log('🔢 Extracted numbers:', seatNumbers);

                        seatNumbers.forEach(num => {
                            if (num > maxNumber) {
                                maxNumber = num;
                            }
                        });
                    }
                });

                console.log('🔢 Max number found:', maxNumber);
                const nextNumber = maxNumber + 1;
                console.log('🔢 Next seat number:', nextNumber, 'type:', typeof nextNumber);
                return nextNumber;
            }

            function removeSeat(seatId) {
                console.log('🗑️ Removing seat:', seatId);
                if (!confirm('Bạn có chắc muốn xóa ghế này?'))
                    return;
                const seatIndex = seats.findIndex(s => s.id === seatId);
                if (seatIndex === -1)
                    return;
                const seat = seats[seatIndex];
                // Clear all cells occupied by this seat
                for (let i = 0; i < seat.width; i++) {
                    const cellX = seat.x + i;
                    const cellY = seat.y;
                    const cell = document.querySelector(`.grid-cell[data-x="${cellX}"][data-y="${cellY}"]`);
                    if (cell) {
                        cell.classList.remove('occupied');
                        cell.innerHTML = '';
                    }
                }

                seats.splice(seatIndex, 1);
                // Use refreshGrid to update the entire layout
                refreshGrid();
                updateSeatCounter();
                console.log('✅ Seat removed');
            }

            function updateSeatCounter() {
                const seatCount = seats.length;
                const capacity = config.capacity;
                const counterElement = document.getElementById('seatCounter') || createSeatCounter();
                counterElement.innerHTML = `
           <strong>${seatCount}/${capacity} ghế</strong>
           <br>
           <span style="color: ${seatCount > capacity ? '#ef4444' : '#10b981'}; font-size: 12px;">
            ${seatCount > capacity ? '⚠️ Vượt quá sức chứa!' : '✅ Đạt sức chứa'}
           </span>
       `;
            }

            function createSeatCounter() {
                const counterElement = document.createElement('div');
                counterElement.id = 'seatCounter';
                counterElement.style.cssText = `
           position: fixed;
           bottom: 20px;
           right: 20px;
           background: white;
           border: 1px solid #e2e8f0;
           border-radius: 12px;
           padding: 15px;
           box-shadow: 0 4px 12px rgba(0,0,0,0.1);
           z-index: 1000;
           font-size: 14px;
           text-align: center;
       `;
                document.body.appendChild(counterElement);
                return counterElement;
            }

            function attachEventListeners() {
                // Clear all seats
                const clearBtn = document.getElementById('btnClearAll');
                if (clearBtn) {
                    clearBtn.addEventListener('click', clearAllSeats);
                }

                // Save design - SỬA LẠI PHẦN NÀY
                const saveBtn = document.getElementById('btnSaveDesign');
                if (saveBtn) {
                    saveBtn.addEventListener('click', function () {
                        if (seats.length === 0) {
                            alert('Vui lòng thêm ít nhất một ghế trước khi lưu!');
                            return;
                        }

                        // Hiển thị loading
                        saveBtn.innerHTML = '⏳ Đang lưu...';
                        saveBtn.disabled = true;

                        saveSeatDesign();
                    });
                }

                // Generate default
                const generateBtn = document.getElementById('btnGenerateDefault');
                if (generateBtn) {
                    generateBtn.addEventListener('click', function () {
                        if (confirm('Tạo layout mặc định? Hành động này sẽ xóa tất cả ghế hiện tại.')) {
                            window.location.href = '${pageContext.request.contextPath}/staff/seat-design?action=generate-default&roomId=' + config.roomId;
                        }
                    });
                }
            }

// HÀM LƯU THIẾT KẾ GHẾ
            function saveSeatDesign() {
                console.log('💾 Bắt đầu lưu thiết kế ghế...');
                console.log('🔢 Tổng số ghế:', seats.length);

                // Log từng ghế để kiểm tra
                seats.forEach((seat, index) => {
                    console.log(`   🪑 Ghế ${index + 1}:`, {
                        id: seat.id,
                        code: seat.code,
                        typeId: seat.typeId,
                        x: seat.x,
                        y: seat.y,
                        width: seat.width,
                        color: seat.color
                    });
                });

                // Chuẩn bị dữ liệu để gửi
                const seatData = {
                    roomId: config.roomId,
                    seats: seats.map(seat => ({
                            id: seat.id && !seat.id.toString().startsWith('temp_') ? seat.id : null,
                            code: seat.code || 'UNKNOWN',
                            typeId: seat.typeId !== undefined ? seat.typeId : 1,
                            x: seat.x !== undefined ? seat.x : 0,
                            y: seat.y !== undefined ? seat.y : 0,
                            width: seat.width !== undefined ? seat.width : 1,
                            height: seat.height !== undefined ? seat.height : 1, // THÊM DÒNG NÀY
                            color: seat.color || '#1e90ff'
                        }))
                };

                console.log('📦 Dữ liệu gửi đi:', JSON.stringify(seatData, null, 2));

                // Hiển thị loading
                const saveBtn = document.getElementById('btnSaveDesign');
                if (saveBtn) {
                    saveBtn.innerHTML = '⏳ Đang lưu...';
                    saveBtn.disabled = true;
                }

                // Gửi request đến server
                fetch('${pageContext.request.contextPath}/staff/seat-design?action=save-design', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify(seatData)
                })
                        .then(response => {
                            if (!response.ok) {
                                throw new Error('Lỗi kết nối server: ' + response.status);
                            }
                            return response.json();
                        })
                        .then(data => {
                            console.log('📨 Response từ server:', data);
                            if (data.success) {
                                console.log('✅ Lưu thành công:', data.message);
                                showSuccessMessage('✅ ' + data.message);

                                setTimeout(() => {
                                    window.location.href = '${pageContext.request.contextPath}/staff/seat-design?roomId=' + config.roomId + '&success=save';
                                }, 1500);

                            } else {
                                throw new Error(data.message || 'Lỗi không xác định');
                            }
                        })
                        .catch(error => {
                            console.error('❌ Lỗi khi lưu:', error);
                            showErrorMessage('❌ Lỗi khi lưu: ' + error.message);
                        })
                        .finally(() => {
                            // Khôi phục trạng thái nút
                            if (saveBtn) {
                                saveBtn.innerHTML = '💾 Lưu Thiết kế';
                                saveBtn.disabled = false;
                            }
                        });
            }

// HIỂN THỊ THÔNG BÁO THÀNH CÔNG
            function showSuccessMessage(message) {
                showMessage(message, 'success');
            }

// HIỂN THỊ THÔNG BÁO LỖI
            function showErrorMessage(message) {
                showMessage(message, 'error');
            }

// HIỂN THỊ THÔNG BÁO
            function showMessage(message, type) {
                // Tạo hoặc tìm message container
                let messageContainer = document.getElementById('messageContainer');
                if (!messageContainer) {
                    messageContainer = document.createElement('div');
                    messageContainer.id = 'messageContainer';
                    messageContainer.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 10000;
            max-width: 400px;
        `;
                    document.body.appendChild(messageContainer);
                }

                // Tạo message element
                const messageElement = document.createElement('div');

                // Set CSS dựa trên type
                let backgroundColor, textColor, borderColor;
                if (type === 'success') {
                    backgroundColor = 'rgba(16, 185, 129, 0.2)';
                    textColor = '#10b981';
                    borderColor = 'rgba(16, 185, 129, 0.3)';
                } else {
                    backgroundColor = 'rgba(239, 68, 68, 0.2)';
                    textColor = '#ef4444';
                    borderColor = 'rgba(239, 68, 68, 0.3)';
                }

                messageElement.style.cssText = `
        padding: 15px 20px;
        margin-bottom: 10px;
        border-radius: 12px;
        font-weight: 600;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        animation: slideIn 0.3s ease-out;
        background: ${backgroundColor};
        color: ${textColor};
        border: 1px solid ${borderColor};
    `;

                messageElement.textContent = message;

                messageContainer.appendChild(messageElement);

                // Tự động xóa sau 5 giây
                setTimeout(() => {
                    messageElement.style.animation = 'slideOut 0.3s ease-in';
                    setTimeout(() => {
                        if (messageElement.parentNode) {
                            messageElement.parentNode.removeChild(messageElement);
                        }
                    }, 300);
                }, 5000);
            }

// CẬP NHẬT ID CHO GHẾ SAU KHI LƯU
            function updateSeatIds(updatedSeats) {
                updatedSeats.forEach(updatedSeat => {
                    const existingSeatIndex = seats.findIndex(s =>
                        s.code === updatedSeat.code && s.x === updatedSeat.positionX && s.y === updatedSeat.positionY
                    );
                    if (existingSeatIndex !== -1) {
                        seats[existingSeatIndex].id = updatedSeat.id;
                    }
                });
            }

// THÊM CSS ANIMATION
            const style = document.createElement('style');
            style.textContent = `
    @keyframes slideIn {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    @keyframes slideOut {
        from {
            transform: translateX(0);
            opacity: 1;
        }
        to {
            transform: translateX(100%);
            opacity: 0;
        }
    }
`;
            document.head.appendChild(style);
        </script>                   
    </body>
</html>
