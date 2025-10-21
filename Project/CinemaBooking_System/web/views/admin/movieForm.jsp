<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>${movie != null ? "Chỉnh sửa phim" : "Thêm phim mới"}</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/admin/css/style.css">
    <style>
        body {
            font-family: "Segoe UI", sans-serif;
            margin: 40px;
            background: #f9f9f9;
        }
        .container {
            max-width: 700px;
            margin: auto;
            background: #fff;
            padding: 30px;
            border-radius: 16px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
        }
        h2 {
            text-align: center;
            margin-bottom: 30px;
        }
        label {
            font-weight: bold;
            display: block;
            margin-top: 15px;
        }
        input[type="text"], input[type="number"], input[type="date"], textarea, select {
            width: 100%;
            padding: 10px;
            border-radius: 8px;
            border: 1px solid #ccc;
            margin-top: 5px;
        }
        textarea {
            height: 100px;
        }
        .poster-preview {
            margin-top: 15px;
            text-align: center;
        }
        .poster-preview img {
            width: 150px;
            border-radius: 12px;
            border: 1px solid #ddd;
        }
        button {
            margin-top: 25px;
            width: 100%;
            padding: 12px;
            background: #007bff;
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            cursor: pointer;
            transition: 0.3s;
        }
        button:hover {
            background: #0056b3;
        }
        .back-link {
            display: inline-block;
            margin-bottom: 15px;
            text-decoration: none;
            color: #555;
        }
        .back-link:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="container">
        <a href="${pageContext.request.contextPath}/admin/movies" class="back-link">← Quay lại danh sách phim</a>

        <h2>${movie != null ? "✏️ Chỉnh sửa phim" : "➕ Thêm phim mới"}</h2>

        <form action="${pageContext.request.contextPath}/admin/movies?action=${movie != null ? 'update' : 'add'}" method="post">
            
            <c:if test="${movie != null}">
                <input type="hidden" name="id" value="${movie.id}">
            </c:if>

            <label for="movieTitle">Tên phim:</label>
            <input type="text" id="movieTitle" name="movieTitle" required 
                   value="${movie != null ? movie.name : ''}">

            <label for="movieDescription">Mô tả:</label>
            <textarea id="movieDescription" name="movieDescription">${movie != null ? movie.description : ''}</textarea>

            <label for="movieDuration">Thời lượng (phút):</label>
            <input type="number" id="movieDuration" name="movieDuration" required min="1"
                   value="${movie != null ? movie.movieDuration : ''}">

            <label for="releaseDate">Ngày khởi chiếu:</label>
            <input type="date" id="releaseDate" name="releaseDate" required 
                   value="${movie != null ? movie.premiereDate : ''}">

            <label for="movieStatus">Trạng thái:</label>
            <select id="movieStatus" name="movieStatus">
                <option value="Đang chiếu" ${movie != null && movie.status == 'Đang chiếu' ? 'selected' : ''}>Đang chiếu</option>
                <option value="Sắp chiếu" ${movie != null && movie.status == 'Sắp chiếu' ? 'selected' : ''}>Sắp chiếu</option>
            </select>

            <label for="posterUrl">Poster (URL hoặc tên file ảnh):</label>
            <input type="text" id="posterUrl" name="posterUrl" 
                   value="${movie != null ? movie.image : ''}" 
                   oninput="updatePreview(this.value)" placeholder="VD: avatar.jpg hoặc /assets/admin/img/img/avatar.jpg">

            <div class="poster-preview">
                <c:choose>
                    <c:when test="${movie != null && movie.image != null}">
                        <img id="posterImg" src="${pageContext.request.contextPath}/assets/admin/img/img/${movie.image}" alt="Poster phim">
                    </c:when>
                    <c:otherwise>
                        <img id="posterImg" src="${pageContext.request.contextPath}/assets/admin/img/img/default.jpg" alt="Poster mặc định">
                    </c:otherwise>
                </c:choose>
            </div>

            <button type="submit">${movie != null ? "💾 Cập nhật phim" : "➕ Thêm phim mới"}</button>
        </form>
    </div>

    <script>
        function updatePreview(url) {
            const img = document.getElementById('posterImg');
            if (url.trim() === '') {
                img.src = '${pageContext.request.contextPath}/assets/admin/img/img/default.jpg';
            } else {
                // Nếu chỉ nhập tên file, thêm đường dẫn tự động
                if (!url.startsWith('http') && !url.startsWith('${pageContext.request.contextPath}')) {
                    img.src = '${pageContext.request.contextPath}/assets/admin/img/img/' + url;
                } else {
                    img.src = url;
                }
            }
        }
    </script>
</body>
</html>