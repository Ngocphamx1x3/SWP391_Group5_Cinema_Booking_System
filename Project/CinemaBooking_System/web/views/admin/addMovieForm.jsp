<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Thêm phim mới</title>
    <style>
        body { font-family: Arial; background: #0f1419; color: #e4e9f0; }
        form { width: 600px; margin: 50px auto; background: #1a1f2e; padding: 30px; border-radius: 12px; }
        label { display: block; margin-top: 15px; font-weight: bold; }
        input, textarea, select {
            width: 100%; padding: 10px; border: none; border-radius: 6px; margin-top: 5px;
            background: #0f1419; color: #e4e9f0;
        }
        button {
            margin-top: 25px; padding: 12px 20px; border: none; border-radius: 10px;
            background: linear-gradient(135deg, #00d4ff, #0099ff); color: #0f1419; font-weight: bold; cursor: pointer;
        }
    </style>
</head>
<body>
    <form action="${pageContext.request.contextPath}/admin/movies?action=add" method="post">
        <h2>🎬 Thêm phim mới</h2>

        <label>Tên phim</label>
        <input type="text" name="movieTitle" required>

        <label>Mô tả</label>
        <textarea name="movieDescription" rows="4"></textarea>

        <label>Poster URL</label>
        <input type="text" name="posterUrl">

        <label>Trailer URL</label>
        <input type="text" name="trailerUrl">

        <label>Thời lượng (phút)</label>
        <input type="number" name="movieDuration" min="1" required>

        <label>Ngày phát hành</label>
        <input type="date" name="releaseDate" required>

        <label>Trạng thái</label>
        <select name="movieStatus">
            <option value="Đang chiếu">Đang chiếu</option>
            <option value="Sắp chiếu">Sắp chiếu</option>
        </select>

        <label>Đạo diễn</label>
        <div style="display: flex; gap: 10px; align-items: center;">
            <select name="directors" multiple size="3" style="flex: 1;">
                <c:forEach var="d" items="${directorList}">
                    <option value="${d.id}">${d.name}</option>
                </c:forEach>
            </select>
        </div>
        <button type="button" onclick="toggleDirectorForm()" style="padding: 8px 12px; background: #28a745; color: white; border: none; border-radius: 6px; cursor: pointer; margin-top: 10px;">
            ➕ Thêm mới
        </button>
        </div>
        
        <!-- Form thêm đạo diễn mới (ẩn ban đầu) -->
        <div id="directorForm" style="display: none; margin-top: 15px; padding: 15px; background: #2a2f3e; border-radius: 8px; border: 1px solid #444;">
            <h4 style="margin-top: 0; color: #00d4ff;">🎬 Thêm đạo diễn mới</h4>
            
            <label style="margin-top: 10px;">Mã đạo diễn</label>
            <input type="text" name="directorCode" placeholder="VD: DIR001">
            
            <label style="margin-top: 10px;">Tên đạo diễn</label>
            <input type="text" name="directorName" placeholder="Nhập tên đạo diễn">
            
            <div style="margin-top: 15px; display: flex; gap: 10px;">
                <button type="button" onclick="addDirector()" style="background: #28a745; color: white; border: none; padding: 8px 16px; border-radius: 6px; cursor: pointer;">
                    💾 Lưu đạo diễn
                </button>
                <button type="button" onclick="toggleDirectorForm()" style="background: #6c757d; color: white; border: none; padding: 8px 16px; border-radius: 6px; cursor: pointer;">
                    ❌ Hủy
                </button>
            </div>
        </div>

        <label>Ngôn ngữ</label>
        <div style="display: flex; gap: 10px; align-items: center;">
            <select name="languages" multiple size="3" style="flex: 1;">
                <c:forEach var="l" items="${languageList}">
                    <option value="${l.id}">${l.name}</option>
                </c:forEach>
            </select>
        </div>
        <button type="button" onclick="toggleLanguageForm()" style="padding: 8px 12px; background: #28a745; color: white; border: none; border-radius: 6px; cursor: pointer; margin-top: 10px;">
            ➕ Thêm mới
        </button>
        </div>
        
        <!-- Form thêm ngôn ngữ mới (ẩn ban đầu) -->
        <div id="languageForm" style="display: none; margin-top: 15px; padding: 15px; background: #2a2f3e; border-radius: 8px; border: 1px solid #444;">
            <h4 style="margin-top: 0; color: #00d4ff;">🌐 Thêm ngôn ngữ mới</h4>
            
            <label style="margin-top: 10px;">Mã ngôn ngữ</label>
            <input type="text" name="languageCode" placeholder="VD: LANG001">
            
            <label style="margin-top: 10px;">Tên ngôn ngữ</label>
            <input type="text" name="languageName" placeholder="Nhập tên ngôn ngữ">
            
            <div style="margin-top: 15px; display: flex; gap: 10px;">
                <button type="button" onclick="addLanguage()" style="background: #28a745; color: white; border: none; padding: 8px 16px; border-radius: 6px; cursor: pointer;">
                    💾 Lưu ngôn ngữ
                </button>
                <button type="button" onclick="toggleLanguageForm()" style="background: #6c757d; color: white; border: none; padding: 8px 16px; border-radius: 6px; cursor: pointer;">
                    ❌ Hủy
                </button>
            </div>
        </div>

        <label>Thể loại</label>
        <select name="movieTypes" multiple size="3">
            <c:forEach var="t" items="${movieTypeList}">
                <option value="${t.id}">${t.name}</option>
            </c:forEach>
        </select>

        <button type="submit">💾 Lưu phim</button>
    </form>

    <script>
        function toggleDirectorForm() {
            const form = document.getElementById('directorForm');
            if (form.style.display === 'none') {
                form.style.display = 'block';
            } else {
                form.style.display = 'none';
                // Reset form
                document.querySelector('input[name="directorCode"]').value = '';
                document.querySelector('input[name="directorName"]').value = '';
            }
        }

        function addDirector() {
            const directorCode = document.querySelector('input[name="directorCode"]').value.trim();
            const directorName = document.querySelector('input[name="directorName"]').value.trim();

            if (!directorCode || !directorName) {
                alert('Vui lòng nhập đầy đủ mã và tên đạo diễn!');
                return;
            }

            // Tạo form để gửi request
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = '${pageContext.request.contextPath}/admin/movies?action=addDirector';
            
            const codeInput = document.createElement('input');
            codeInput.type = 'hidden';
            codeInput.name = 'directorCode';
            codeInput.value = directorCode;
            
            const nameInput = document.createElement('input');
            nameInput.type = 'hidden';
            nameInput.name = 'directorName';
            nameInput.value = directorName;
            
            form.appendChild(codeInput);
            form.appendChild(nameInput);
            document.body.appendChild(form);
            form.submit();
        }

        function toggleLanguageForm() {
            const form = document.getElementById('languageForm');
            if (form.style.display === 'none') {
                form.style.display = 'block';
            } else {
                form.style.display = 'none';
                // Reset form
                document.querySelector('input[name="languageCode"]').value = '';
                document.querySelector('input[name="languageName"]').value = '';
            }
        }

        function addLanguage() {
            const languageCode = document.querySelector('input[name="languageCode"]').value.trim();
            const languageName = document.querySelector('input[name="languageName"]').value.trim();

            if (!languageCode || !languageName) {
                alert('Vui lòng nhập đầy đủ mã và tên ngôn ngữ!');
                return;
            }

            // Tạo form để gửi request
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = '${pageContext.request.contextPath}/admin/movies?action=addLanguage';
            
            const codeInput = document.createElement('input');
            codeInput.type = 'hidden';
            codeInput.name = 'languageCode';
            codeInput.value = languageCode;
            
            const nameInput = document.createElement('input');
            nameInput.type = 'hidden';
            nameInput.name = 'languageName';
            nameInput.value = languageName;
            
            form.appendChild(codeInput);
            form.appendChild(nameInput);
            document.body.appendChild(form);
            form.submit();
        }

        // Hiển thị thông báo lỗi/thành công nếu có
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