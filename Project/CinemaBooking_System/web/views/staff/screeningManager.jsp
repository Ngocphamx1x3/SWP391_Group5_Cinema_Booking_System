<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý lịch chiếu</title>
    <style>
        /* ------------------------------------------
           Phần thiết lập các class cho layout, style
           ------------------------------------------ */

        body {
            font-family: Arial, sans-serif;
            background: #f6f8fb;
            color: #222;
        }

        /* Lớp bao ngoài cho nội dung trang */
        .container {
            max-width: 1100px;
            margin: 0 auto;
            background: #fff;
            border-radius: 16px;
            padding: 26px;
            margin-top: 36px;
            box-shadow: 0 0 14px #e3ecff;
        }

        h1 {
            color: #0098ef;
        }

        /* Bảng hiển thị dữ liệu */
        table {
            width: 100%;
            border-collapse: collapse;
            background: #fff;
            margin-top: 22px;
        }

        th, td {
            border: 1px solid #e2e6ee;
            padding: 10px 8px;
            text-align: center;
        }

        th {
            background-color: #e3ecff;
        }

        /* Lớp cho các nút thao tác trong bảng */
        .actions button {
            padding: 4px 15px;
            border-radius: 4px;
            border: none;
            background: #09c;
            color: #fff;
            margin-left: 4px;
            cursor: pointer;
        }

        /* Nút hủy lịch */
        .actions .del {
            background: #e53935;
        }

        /* Nút chỉnh sửa lịch */
        .actions .edit {
            background: #fbc02d;
            color: #1a1a1a;
        }

        /* Form thêm lịch chiếu mới */
        .add-container {
            margin-bottom: 26px;
            background: #f7faff;
            border: 1px solid #e3ecff;
            border-radius: 9px;
            padding: 22px 18px;
        }

        /* Style cho input, select */
        select,
        input[type="number"],
        input[type="date"],
        input[type="time"],
        input[type="text"] {
            padding: 7px 10px;
            border: 1px solid #d7e2ee;
            border-radius: 5px;
            margin-right: 8px;
            margin-bottom: 10px;
        }

        /* Style cho label */
        label {
            font-weight: bold;
            margin-right: 6px;
        }

        /* Bar lọc tìm kiếm lịch chiếu */
        .filter-bar {
            margin-bottom: 18px;
        }

        .filter-bar form {
            display: flex;
            gap: 16px;
            flex-wrap: wrap;
            align-items: center;
        }

        /* Nút tìm kiếm */
        .search-btn {
            padding: 6px 16px;
            border-radius: 4px;
            background: #0098ef;
            border: none;
            color: #fff;
            font-weight: bold;
        }

        /* Popup nền mờ */
        .popup-bg {
            /* Lớp phủ nền popup xác nhận/chỉnh sửa */
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            background: rgba(37, 52, 76, 0.25);
            z-index: 10;
            display: none;
            justify-content: center;
            align-items: center;
        }

        /* Nội dung popup */
        .popup {
            background: #fff;
            padding: 30px 22px 18px;
            border-radius: 16px;
            box-shadow: 0 2px 30px rgba(0,48,150,0.15);
            min-width: 350px;
            text-align: center;
        }

        /* Khoảng cách nút trong popup */
        .popup button {
            margin: 0 10px;
        }

        /* Dòng bị vô hiệu hóa (disabled: kết thúc, đã hủy, không hoạt động) */
        tr.disabled {
            opacity: 0.5;
            background: #f7f7f7;
        }
    </style>
    <script>
        /**
         * Hiển thị form chỉnh sửa lịch chiếu theo id
         * @param {string|number} id 
         */
        function showEditForm(id) {
            // Điều hướng tới form chỉnh sửa với scheduleId
            window.location.href = 'screeningManager?action=edit&scheduleId=' + id;
        }

        /**
         * Đóng/bỏ form chỉnh sửa, quay lại trang chính
         */
        function hideEditForm() {
            window.location.href = 'screeningManager';
        }

        /**
         * Hiện popup xác nhận xóa lịch chiếu theo id
         * @param {string|number} id 
         */
        function confirmDelete(id) {
            document.getElementById('delete-popup-bg').style.display = 'flex';
            document.getElementById('deleteScheduleId').value = id;
        }

        /**
         * Đóng popup xác nhận xóa
         */
        function hideDeletePopup() {
            document.getElementById('delete-popup-bg').style.display = 'none';
        }

        /**
         * Tự động submit form bộ lọc khi chọn rạp để reload danh sách phòng
         */
        function loadRooms() {
            // Submit form đầu tiên nằm trong .filter-bar
            var form = document.querySelector('.filter-bar form');
            if (form)
                form.submit();
        }
    </script>
</head>
<body>
<div class="container">

    <h1>🎬 Quản lý lịch chiếu</h1>

    <!-- Hiển thị thông báo thành công/lỗi -->
    <c:if test="${not empty success}">
        <div style="background: #d4edda; color: #155724; padding: 12px; border-radius: 6px; margin-bottom: 20px; border: 1px solid #c3e6cb;">
            ✅ ${success}
        </div>
    </c:if>
    <c:if test="${not empty error}">
        <div style="background: #f8d7da; color: #721c24; padding: 12px; border-radius: 6px; margin-bottom: 20px; border: 1px solid #f5c6cb;">
            ❌ ${error}
        </div>
    </c:if>

    <!-- Bộ lọc tìm kiếm lịch chiếu -->
    <div class="filter-bar">
        <form action="" method="get">
            <label>Ngày:</label>
            <input type="date" name="filterDate" value="${param.filterDate}" />
            <label>Phim:</label>
            <select name="filterMovie">
                <option value="">-- Tất cả --</option>
                <c:forEach var="mv" items="${movieList}">
                    <option value="${mv.id}" <c:if test="${param.filterMovie == mv.id}">selected</c:if>>${mv.name}</option>
                </c:forEach>
            </select>
            <label>Rạp:</label>
            <select name="theaterId" onchange="loadRooms()">
                <option value="">-- Tất cả --</option>
                <c:forEach var="th" items="${theaterList}">
                    <option value="${th.id}" <c:if test="${param.theaterId == th.id}">selected</c:if>>${th.name}</option>
                </c:forEach>
            </select>
            <label>Phòng:</label>
            <select name="filterRoom">
                <option value="">-- Tất cả --</option>
                <c:forEach var="r" items="${roomList}">
                    <c:if test="${empty param.theaterId || r.cinemaId == param.theaterId}">
                        <option value="${r.id}" <c:if test="${param.filterRoom == r.id}">selected</c:if>>${r.name}</option>
                    </c:if>
                </c:forEach>
            </select>
            <label>Trạng thái:</label>
            <select name="filterStatus">
                <option value="">-- Tất cả --</option>
                <option value="Active" <c:if test="${param.filterStatus == 'Active'}">selected</c:if>>Đang hoạt động</option>
                <option value="Cancelled" <c:if test="${param.filterStatus == 'Cancelled'}">selected</c:if>>Đã hủy</option>
                <option value="Inactive" <c:if test="${param.filterStatus == 'Inactive'}">selected</c:if>>Ngừng hoạt động</option>
            </select>
            <button class="search-btn" type="submit">Tìm kiếm</button>
        </form>
    </div>

    <!-- Form thêm mới lịch chiếu -->
    <div class="add-container">
        <form action="screeningManager?action=add" method="post">
            <label>Phim:</label>
            <select name="movieId" required>
                <option value="">-- Chọn phim sắp chiếu --</option>
                <c:forEach var="m" items="${upcomingMovies}">
                    <option value="${m.id}">${m.name}</option>
                </c:forEach>
            </select>
            <label>Rạp chiếu:</label>
            <select name="theaterId" required>
                <option value="">-- Chọn rạp --</option>
                <c:forEach var="th" items="${theaterList}">
                    <option value="${th.id}" <c:if test="${param.theaterId == th.id}">selected</c:if>>${th.name}</option>
                </c:forEach>
            </select>
            <label>Phòng chiếu:</label>
            <select name="roomId" required>
                <option value="">-- Chọn phòng --</option>
                <c:forEach var="r" items="${roomList}">
                    <c:if test="${r.cinemaId == param.theaterId || empty param.theaterId}">
                        <option value="${r.id}">${r.name}</option>
                    </c:if>
                </c:forEach>
            </select>
            <label>Thời gian bắt đầu:</label>
            <input type="datetime-local" name="startAt" required />
            <label>Định dạng:</label>
            <select name="format" required>
                <option value="2D-Phụ đề">2D - Phụ đề</option>
                <option value="2D-Lồng tiếng">2D - Lồng tiếng</option>
                <option value="3D-Phụ đề">3D - Phụ đề</option>
                <option value="3D-Lồng tiếng">3D - Lồng tiếng</option>
            </select>
            <label>Giá vé (VNĐ):</label>
            <input type="number" min="0" name="price" value="80000" required />
            <label>Trạng thái:</label>
            <select name="status" required>
                <option value="Active" selected>Đang hoạt động</option>
                <option value="Cancelled">Đã hủy</option>
                <option value="Inactive">Ngừng hoạt động</option>
            </select>
            <!-- Ẩn operatingStatus trong form thêm mới (chắc chắn KHÔNG gửi từ client) -->
            <input type="hidden" name="operatingStatus" value="" />
            <button type="submit">➕ Tạo lịch chiếu</button>
        </form>
        <div style="font-size:13px;color:#999; margin-top:5px;">
            * Nếu chọn rạp trước, phòng sẽ lọc theo rạp.<br>
            * Hệ thống kiểm tra trùng giờ/phòng trước khi lưu<br>
            * Trạng thái hoạt động sẽ tự động cập nhật theo thời gian chiếu thực tế
        </div>
    </div>

    <!-- Bảng danh sách lịch chiếu -->
    <table>
        <thead>
        <tr>
            <th>ID</th>
            <th>Code</th>
            <th>Bắt đầu</th>
            <th>Kết thúc</th>
            <th>Giá vé</th>
            <th>Trạng thái</th>
            <th>Hoạt động</th>
            <th>Phim</th>
            <th>Phòng</th>
            <th>Thao tác</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="s" items="${scheduleList}">
            <tr class="<c:if test='${s.operatingStatus == 0 || s.status eq "Cancelled"}'>disabled</c:if>">
                <td>${s.id}</td>
                <td>${s.code}</td>
                <td>${s.formattedStartAt}</td>
                <td>${s.formattedFinishAt}</td>
                <td><fmt:formatNumber value="${s.price}" pattern="#,###"/> VNĐ</td>
                <td>
                    <c:choose>
                        <c:when test="${s.status eq 'active'}">
                            <span style="color:green;">Đang hoạt động</span>
                        </c:when>
                        <c:when test="${s.status eq 'Cancelled'}">
                            <span style="color:red;">Đã hủy</span>
                        </c:when>
                        <c:otherwise>
                            <span style="color:gray;">Ngừng hoạt động</span>
                        </c:otherwise>
                    </c:choose>
                </td>
                <td>
                    <!-- Lấy label từ getOperatingStatusLabel() -->
                    <span>
                        <c:out value="${s.operatingStatusLabel}" />
                    </span>
                </td>
                <td>
                    <c:forEach var="m" items="${movieList}">
                        <c:if test="${m.id == s.movieId}">${m.name}</c:if>
                    </c:forEach>
                </td>
                <td>
                    <c:forEach var="r" items="${roomList}">
                        <c:if test="${r.id == s.roomId}">${r.name}</c:if>
                    </c:forEach>
                </td>
                <td class="actions">
                    <button type="button" class="edit" onclick="showEditForm('${s.id}')">Chỉnh sửa</button>
                    <!-- Chỉ cho phép hủy lịch khi trạng thái đang hoạt động và đang chạy -->
                    <c:if test="${s.status eq 'Active' && s.operatingStatus == 1}">
                        <button type="button" class="del" onclick="confirmDelete('${s.id}')">Hủy</button>
                    </c:if>
                </td>
            </tr>
        </c:forEach>
        <c:if test="${empty scheduleList}">
            <tr><td colspan="10">Không có lịch chiếu</td></tr>
        </c:if>
        </tbody>
    </table>

    <!-- Popup chỉnh sửa lịch chiếu -->
    <c:if test="${not empty editSchedule}">
        <div id="edit-popup-bg" class="popup-bg" style="display: flex;">
            <div class="popup">
                <h2>Chỉnh sửa lịch chiếu</h2>
                <form action="screeningManager?action=edit" method="post">
                    <input type="hidden" name="scheduleId" value="${editSchedule.id}" />
                    <label>Phòng:</label>
                    <select name="editRoomId" required>
                        <c:forEach var="r" items="${roomList}">
                            <option value="${r.id}" <c:if test="${editSchedule.roomId == r.id}">selected</c:if>>${r.name}</option>
                        </c:forEach>
                    </select>
                    <label>Giờ bắt đầu:</label>
                    <input type="datetime-local" name="editStartAt" value="${editSchedule.startAtLocal}" required />
                    <label>Giá vé:</label>
                    <input type="number" min="0" name="editPrice" value="${editSchedule.price}" required />
                    <label>Trạng thái:</label>
                    <select name="editStatus">
                        <option value="Active" <c:if test="${editSchedule.status == 'Active'}">selected</c:if>>Đang hoạt động</option>
                        <option value="Cancelled" <c:if test="${editSchedule.status == 'Cancelled'}">selected</c:if>>Đã hủy</option>
                        <option value="Inactive" <c:if test="${editSchedule.status == 'Inactive'}">selected</c:if>>Ngừng hoạt động</option>
                    </select>
                    <!-- Hiện operatingStatus readonly, staff không chỉnh được -->
                    <label>Hoạt động (tự động):</label>
                    <input type="text" value="${editSchedule.operatingStatusLabel}" readonly style="color:#666;background:#f5f6fa;" />
                    <!-- Không gửi operatingStatus lên server -->
                    <input type="hidden" name="editOperatingStatus" value="${editSchedule.operatingStatus}" />
                    <br><br>
                    <button type="submit">Lưu thay đổi</button>
                    <button type="button" onclick="hideEditForm()">Hủy</button>
                </form>
                <div style="font-size:13px;color:#969; margin-top:7px;">
                    * Chỉ có thể chỉnh sửa giờ, phòng, giá, trạng thái<br>
                    * Trạng thái hoạt động sẽ tự động cập nhật theo thời gian chiếu thực tế
                </div>
            </div>
        </div>
    </c:if>

    <!-- Popup xác nhận hủy lịch chiếu -->
    <div id="delete-popup-bg" class="popup-bg">
        <div class="popup">
            <h3>Bạn có chắc muốn hủy lịch chiếu này không?</h3>
            <form action="screeningManager?action=delete" method="post" style="margin-top:22px;">
                <input type="hidden" name="scheduleId" id="deleteScheduleId" value="" />
                <button type="submit" class="del">Xác nhận hủy</button>
                <button type="button" onclick="hideDeletePopup()">Không</button>
            </form>
            <div style="font-size:13px;color:#666; margin-top:10px;">
                * Lịch chiếu có vé đã bán sẽ không thể xóa (chính sách có thể bổ sung sau)
            </div>
        </div>
    </div>

</div>
<script>
    // Đóng popup khi click vào nền mờ phía ngoài popup
    window.addEventListener('click', function (e) {
        ['edit-popup-bg', 'delete-popup-bg'].forEach(function (id) {
            var el = document.getElementById(id);
            if (el && e.target === el)
                el.style.display = 'none';
        });
    });
</script>
</body>
</html>