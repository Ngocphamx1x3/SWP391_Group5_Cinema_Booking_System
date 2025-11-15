<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Thêm phim mới</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                background: #f4f6f8;
                color: #222;
            }
            form {
                width: 650px;
                margin: 50px auto;
                background: #ffffff;
                padding: 35px;
                border-radius: 12px;
                box-shadow: 0 3px 10px rgba(0, 0, 0, 0.1);
            }
            label {
                display: block;
                margin-top: 15px;
                font-weight: bold;
                color: #333;
            }
            input, textarea, select {
                width: 100%;
                padding: 10px;
                border: 1px solid #ccc;
                border-radius: 6px;
                margin-top: 5px;
                background: #fff;
                color: #222;
                font-size: 14px;
            }
            textarea {
                resize: vertical;
            }

            button {
                margin-top: 25px;
                padding: 12px 20px;
                border: none;
                border-radius: 8px;
                background: linear-gradient(135deg, #007bff, #0056d2);
                color: white;
                font-weight: bold;
                cursor: pointer;
            }
            button:hover {
                background: linear-gradient(135deg, #0069d9, #004bb5);
            }

            .btn-green {
                background: #28a745;
            }
            .btn-green:hover {
                background: #218838;
            }

            .btn-gray {
                background: #6c757d;
            }
            .btn-gray:hover {
                background: #5a6268;
            }

            .sub-form {
                display: none;
                margin-top: 15px;
                padding: 15px;
                background: #f1f3f6;
                border-radius: 8px;
                border: 1px solid #ccc;
            }

            h2 {
                text-align: center;
                color: #007bff;
            }

            h4 {
                margin-top: 0;
                color: #007bff;
            }
        </style>
    </head>
    <body>
        <form action="${pageContext.request.contextPath}/admin/movies?action=add"
              method="post"
              enctype="multipart/form-data">
            <a href="${pageContext.request.contextPath}/admin/movies" class="back-link">← Quay lại danh sách phim</a>

            <h2> Thêm phim mới</h2>

            <label>Tên phim</label>
            <input type="text" name="movieTitle" required>

            <label>Mô tả</label>
            <textarea name="movieDescription" rows="4"></textarea>

            <label>Poster:</label>
            <input type="text" name="posterUrl" placeholder="...jsp">
            <img id="posterPreview" style="max-width:150px;display:none;margin-top:10px;" alt="Preview Poster">

            <label>Trailer URL</label>
            <input type="text" name="trailerUrl" placeholder="https://...">

            <label>Thời lượng (phút)</label>
            <input type="number" name="movieDuration" min="1" required>

            <label>Ngày phát hành</label>
            <input type="date" name="releaseDate" required>

            <label>Ngày kết thúc</label>
            <input type="date" name="endDate">


            <label>Trạng thái</label>
            <select name="movieStatus">
                <option value="Đang chiếu">Đang chiếu</option>
                <option value="Sắp chiếu">Sắp chiếu</option>
            </select>


            <label>Đạo diễn</label>
            <div style="display:flex;gap:10px;align-items:center;">
                <select name="directors[]" multiple size="3" style="flex:1;">
                    <c:forEach var="d" items="${directorList}">
                        <option value="${d.id}">${d.name}</option>
                    </c:forEach>
                </select>
            </div>
            <button type="button" onclick="toggleDirectorForm()" class="btn-green" style="margin-top:10px;"> Thêm đạo diễn</button>

            <div id="directorForm" class="sub-form">
                <h4> Thêm đạo diễn mới</h4>
                <label>Mã đạo diễn</label>
                <input type="text" name="directorCode" placeholder="VD: DIR001">
                <label>Tên đạo diễn</label>
                <input type="text" name="directorName" placeholder="Nhập tên đạo diễn">
                <div style="margin-top:15px;display:flex;gap:10px;">
                    <button type="button" onclick="addDirector()" class="btn-green"> Lưu</button>
                    <button type="button" onclick="toggleDirectorForm()" class="btn-gray"> Hủy</button>
                </div>
            </div>


            <label>Ngôn ngữ</label>
            <div style="display:flex;gap:10px;align-items:center;">
                <select name="languages[]" multiple size="3" style="flex:1;">
                    <c:forEach var="l" items="${languageList}">
                        <option value="${l.id}">${l.name}</option>
                    </c:forEach>
                </select>
            </div>
            <button type="button" onclick="toggleLanguageForm()" class="btn-green" style="margin-top:10px;"> Thêm ngôn ngữ</button>

            <div id="languageForm" class="sub-form">
                <h4>Thêm ngôn ngữ mới</h4>
                <label>Mã ngôn ngữ</label>
                <input type="text" name="languageCode" placeholder="VD: LANG001">
                <label>Tên ngôn ngữ</label>
                <input type="text" name="languageName" placeholder="Nhập tên ngôn ngữ">
                <div style="margin-top:15px;display:flex;gap:10px;">
                    <button type="button" onclick="addLanguage()" class="btn-green"> Lưu</button>
                    <button type="button" onclick="toggleLanguageForm()" class="btn-gray"> Hủy</button>
                </div>
            </div>


            <label>Thể loại</label>
            <select name="movieTypes[]" multiple size="4">
                <c:forEach var="t" items="${movieTypeList}">
                    <option value="${t.id}">${t.name}</option>
                </c:forEach>
            </select>

            <button type="submit"> Lưu phim</button>
        </form>


        <script>
            function toggleDirectorForm() {
                const form = document.getElementById('directorForm');
                form.style.display = form.style.display === 'none' || form.style.display === '' ? 'block' : 'none';
            }

            function addDirector() {
                const directorCode = document.querySelector('input[name="directorCode"]').value.trim();
                const directorName = document.querySelector('input[name="directorName"]').value.trim();

                if (!directorCode || !directorName) {
                    alert('Vui lòng nhập đầy đủ mã và tên đạo diễn!');
                    return;
                }

                const form = document.createElement('form');
                form.method = 'POST';
                form.action = '${pageContext.request.contextPath}/admin/movies?action=addDirector';

                const code = document.createElement('input');
                code.type = 'hidden';
                code.name = 'directorCode';
                code.value = directorCode;

                const name = document.createElement('input');
                name.type = 'hidden';
                name.name = 'directorName';
                name.value = directorName;

                form.appendChild(code);
                form.appendChild(name);
                document.body.appendChild(form);
                form.submit();
            }

            function toggleLanguageForm() {
                const form = document.getElementById('languageForm');
                form.style.display = form.style.display === 'none' || form.style.display === '' ? 'block' : 'none';
            }

            function addLanguage() {
                const languageCode = document.querySelector('input[name="languageCode"]').value.trim();
                const languageName = document.querySelector('input[name="languageName"]').value.trim();

                if (!languageCode || !languageName) {
                    alert('Vui lòng nhập đầy đủ mã và tên ngôn ngữ!');
                    return;
                }

                const form = document.createElement('form');
                form.method = 'POST';
                form.action = '${pageContext.request.contextPath}/admin/movies?action=addLanguage';

                const code = document.createElement('input');
                code.type = 'hidden';
                code.name = 'languageCode';
                code.value = languageCode;

                const name = document.createElement('input');
                name.type = 'hidden';
                name.name = 'languageName';
                name.value = languageName;

                form.appendChild(code);
                form.appendChild(name);
                document.body.appendChild(form);
                form.submit();
            }

            document.querySelector('form').addEventListener('submit', function (e) {
                const dateInput = document.querySelector('input[name="releaseDate"]');
                const today = new Date();
                today.setHours(0, 0, 0, 0); // bỏ phần giờ phút
                const selectedDate = new Date(dateInput.value);

                if (selectedDate < today) {
                    e.preventDefault(); // chặn gửi form
                    alert("Ngày phát hành không được là ngày trong quá khứ!");
                    dateInput.focus();
                }
            });

            <c:choose>
                <c:when test="${not empty error}">
            alert('Lỗi: ${error}');
                </c:when>
                <c:when test="${not empty success}">
            alert('Thành công: ${success}');
                </c:when>
            </c:choose>
        </script>
    </body>
</html>



