<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.Schedule, model.Movie, model.Room, java.util.List"%>
<%
    Schedule schedule = (Schedule) request.getAttribute("schedule");
    List<Movie> activeMovies = (List<Movie>) request.getAttribute("activeMovies");
    List<Room> staffRooms = (List<Room>) request.getAttribute("staffRooms");
    boolean isEdit = schedule != null;
    String error = (String) request.getAttribute("error");
    
    // Set active page for sidebar highlighting
    request.setAttribute("activePage", "schedules");
    request.setAttribute("pageTitle", isEdit ? "Chỉnh sửa Lịch Chiếu" : "Thêm Lịch Chiếu Mới");
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title><%= isEdit ? "Chỉnh sửa" : "Thêm mới" %> Lịch Chiếu | Cinema Booking</title>
        <jsp:include page="../layout/StaffStyles.jsp"/>
        <style>
            /* ===== Form-specific styles ===== */

            /* ===== Form Container ===== */
            .form-container {
                background: #ffffff; 
                border: 1px solid #e2e8f0; 
                border-radius: 20px;
                padding: 40px;
                max-width: 800px;
                margin: 0 auto;
                box-shadow: 0 10px 20px rgba(0, 0, 0, 0.05); 
            }

            .form-header {
                text-align: center;
                margin-bottom: 40px;
            }

            .form-header h2 {
                font-size: 24px;
                font-weight: 700;
                color: #1a202c; 
                background: none;
                -webkit-background-clip: unset;
                -webkit-text-fill-color: unset;
                margin-bottom: 10px;
            }

            .form-header p {
                color: #6b7280;
                font-size: 14px;
            }

            /* ===== Form Styles ===== */
            .form-group {
                margin-bottom: 25px;
            }

            .form-group label {
                display: block;
                color: #4a5568;
                font-size: 13px;
                font-weight: 600;
                margin-bottom: 8px;
                text-transform: uppercase;
                letter-spacing: 1px;
            }

            .form-group input,
            .form-group select,
            .form-group textarea {
                width: 100%;
                background: #ffffff; 
                border: 1px solid #ced4da; 
                border-radius: 12px;
                padding: 14px 16px;
                color: #2d3748; 
                font-size: 14px;
                outline: none;
                transition: all 0.3s ease;
                font-family: 'Inter', sans-serif;
            }

            .form-group input:focus,
            .form-group select:focus,
            .form-group textarea:focus {
                border-color: #007bff; 
                box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.25); 
            }

            .form-group textarea {
                resize: vertical;
                min-height: 80px;
            }
            
            .form-group select option {
                color: #333;
                background-color: #fff;
            }

            .form-row {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 20px;
            }

            .checkbox-group {
                display: flex;
                align-items: center;
                gap: 10px;
                margin-top: 10px;
            }

            .checkbox-group input[type="checkbox"] {
                width: 18px;
                height: 18px;
                accent-color: #007bff; 
            }

            .checkbox-group label {
                margin-bottom: 0;
                text-transform: none;
                letter-spacing: normal;
                font-size: 14px;
                color: #2d3748;
            }

            /* ===== Movie Info ===== */
            .movie-info {
                background: #f8f9fa;
                border-radius: 12px;
                padding: 15px;
                margin-top: 10px;
                border-left: 4px solid #007bff;
            }

            .movie-info p {
                margin: 5px 0;
                font-size: 13px;
                color: #6b7280;
            }

            /* ===== Form Actions ===== */
            .form-actions {
                display: flex;
                gap: 15px;
                margin-top: 40px;
                padding-top: 30px;
                border-top: 1px solid #e2e8f0; 
            }

            .btn {
                flex: 1;
                padding: 14px 28px;
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

            /* ===== Alert Messages ===== */
            .alert {
                padding: 15px 20px;
                border-radius: 12px;
                margin-bottom: 25px;
                font-weight: 600;
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

            /* ===== Required Field ===== */
            .required::after {
                content: " *";
                color: #ef4444;
            }

            /* ===== Responsive ===== */
            @media (max-width: 768px) {
                .sidebar {
                    width: 100%;
                    height: auto;
                    position: relative;
                }
                header, .content, footer {
                    margin-left: 0;
                }
                .form-row {
                    grid-template-columns: 1fr;
                }
            }
        </style>
    </head>
    <body>

        <jsp:include page="../layout/StaffSidebar.jsp"/>
        <jsp:include page="../layout/StaffHeader.jsp"/>

        <div class="content">
            <div class="form-container">
                <div class="form-header">
                    <h2><%= isEdit ? "Chỉnh sửa Thông Tin Lịch Chiếu" : "Thêm Lịch Chiếu Mới" %></h2>
                    <p><%= isEdit ? "Cập nhật thông tin lịch chiếu hiện có" : "Điền đầy đủ thông tin để thêm lịch chiếu mới" %></p>
                </div>

                <% if (error != null) { %>
                <div class="alert alert-error">
                    <%= error %>
                </div>
                <% } %>

                <form action="${pageContext.request.contextPath}/staff/schedules" method="post" id="scheduleForm">
                    <% if (isEdit) { %>
                    <input type="hidden" name="id" value="<%= schedule.getId() %>">
                    <% } %>
                    <input type="hidden" name="action" value="<%= isEdit ? "update" : "create" %>">

                    <div class="form-group">
                        <label for="name" class="required">Tên lịch chiếu</label>
                        <input type="text" id="name" name="name" 
                               value="<%= isEdit ? schedule.getName() : "" %>" 
                               placeholder="VD: Lịch chiếu sáng, Lịch chiếu tối đặc biệt..."
                               required>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="movieId" class="required">Phim</label>
                            <select id="movieId" name="movieId" required>
                                <option value="">-- Chọn phim --</option>
                                <% if (activeMovies != null) { 
                                    for (Movie movie : activeMovies) { 
                                %>
                                <option value="<%= movie.getId() %>" 
                                        <%= isEdit && schedule.getMovieId() == movie.getId() ? "selected" : "" %>>
                                    <%= movie.getName() %> (<%= movie.getMovieDuration() %> phút)
                                </option>
                                <% } 
                                } %>
                            </select>
                            <div class="movie-info" id="movieInfo" style="display: none;">
                                <p><strong>Thời lượng:</strong> <span id="movieDuration">0</span> phút</p>
                                <p><strong>Ngày khởi chiếu:</strong> <span id="premiereDate">--</span></p>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="roomId" class="required">Phòng chiếu</label>
                            <select id="roomId" name="roomId" required>
                                <option value="">-- Chọn phòng --</option>
                                <% if (staffRooms != null) { 
                                    for (Room room : staffRooms) { 
                                %>
                                <option value="<%= room.getId() %>" 
                                        <%= isEdit && schedule.getRoomId() == room.getId() ? "selected" : "" %>>
                                    <%= room.getName() %> - <%= room.getCinemaName() %>
                                </option>
                                <% } 
                                } %>
                            </select>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="startAt" class="required">Thời gian bắt đầu</label>
                            <input type="datetime-local" id="startAt" name="startAt" 
                                   value="<%= isEdit ? schedule.getStartAtForInput() : "" %>" 
                                   required>
                            <small style="color: #6b7280; margin-top: 5px; display: block;">
                                Thời gian bắt đầu phải sau hiện tại ít nhất 30 phút
                            </small>
                        </div>

                        <div class="form-group">
                            <label for="price" class="required">Giá vé (VND)</label>
                            <input type="number" id="price" name="price" 
                                   value="<%= isEdit ? schedule.getPrice() : "50000" %>" 
                                   min="10000" max="500000" step="10000"
                                   placeholder="50000"
                                   required>
                        </div>
                    </div>

                    <% if (isEdit) { %>
                    <div class="form-group">
                        <label>Trạng thái</label>
                        <div class="checkbox-group">
                            <input type="checkbox" id="status" name="status" value="<%= Schedule.STATUS_ACTIVE %>"
                                   <%= isEdit && Schedule.STATUS_ACTIVE.equals(schedule.getStatus()) ? "checked" : "" %>>
                            <label for="status">Đang hoạt động</label>
                        </div>
                    </div>
                    <% } %>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">
                            <%= isEdit ? "Cập nhật" : "Thêm mới" %>
                        </button>
                        <a href="${pageContext.request.contextPath}/staff/schedules" class="btn btn-secondary">
                            Quay lại
                        </a>
                    </div>
                </form>
            </div>
        </div>

        <jsp:include page="../layout/StaffFooter.jsp"/>

        <script>
            // Movie information display
            const movieSelect = document.getElementById('movieId');
            const movieInfo = document.getElementById('movieInfo');
            const movieDuration = document.getElementById('movieDuration');
            const startAtInput = document.getElementById('startAt');
            
            // Set minimum datetime to current time + 30 minutes
            const now = new Date();
            now.setMinutes(now.getMinutes() + 30);
            const minDateTime = now.toISOString().slice(0, 16);
            startAtInput.min = minDateTime;
            
            // Movie change handler
            movieSelect.addEventListener('change', function() {
                const selectedOption = this.options[this.selectedIndex];
                if (selectedOption.value) {
                    const movieName = selectedOption.text;
                    const durationMatch = movieName.match(/\((\d+) phút\)/);
                    
                    if (durationMatch) {
                        movieDuration.textContent = durationMatch[1];
                        movieInfo.style.display = 'block';
                    }
                } else {
                    movieInfo.style.display = 'none';
                }
            });
            
            // Trigger change on page load if movie is selected
            if (movieSelect.value) {
                movieSelect.dispatchEvent(new Event('change'));
            }
            
            // Form validation
            document.getElementById('scheduleForm').addEventListener('submit', function (e) {
                const name = document.getElementById('name').value.trim();
                const movieId = document.getElementById('movieId').value;
                const roomId = document.getElementById('roomId').value;
                const startAt = document.getElementById('startAt').value;
                const price = document.getElementById('price').value;
                
                if (!name) {
                    alert('Vui lòng nhập tên lịch chiếu');
                    e.preventDefault();
                    return;
                }
                
                if (!movieId) {
                    alert('Vui lòng chọn phim');
                    e.preventDefault();
                    return;
                }
                
                if (!roomId) {
                    alert('Vui lòng chọn phòng chiếu');
                    e.preventDefault();
                    return;
                }
                
                if (!startAt) {
                    alert('Vui lòng chọn thời gian bắt đầu');
                    e.preventDefault();
                    return;
                }
                
                if (price < 10000) {
                    alert('Giá vé phải từ 10,000 VND trở lên');
                    e.preventDefault();
                    return;
                }
                
                // Validate start time is at least 30 minutes from now
                const selectedTime = new Date(startAt);
                const minTime = new Date(now.getTime() + 30 * 60000);
                
                if (selectedTime < minTime) {
                    alert('Thời gian bắt đầu phải sau hiện tại ít nhất 30 phút');
                    e.preventDefault();
                    return;
                }
            });
        </script>
    </body>
</html>