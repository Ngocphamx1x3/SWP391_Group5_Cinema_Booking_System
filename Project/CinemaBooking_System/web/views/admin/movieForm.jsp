<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>${movie != null ? "Chỉnh sửa phim" : "Thêm phim mới"}</title>
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
                padding: 40px;
                min-height: 100vh;
            }

            .container {
                max-width: 700px;
                margin: auto;
                background: #ffffff;
                padding: 40px;
                border-radius: 20px;
                border: 1px solid #e2e8f0;
                box-shadow: 0 10px 20px rgba(0, 0, 0, 0.05);
            }

            h2 {
                text-align: center;
                margin-bottom: 40px;
                font-size: 24px;
                font-weight: 700;
                color: #1a202c;
            }

            label {
                display: block;
                color: #4a5568;
                font-size: 13px;
                font-weight: 600;
                margin-bottom: 8px;
                margin-top: 20px;
                text-transform: uppercase;
                letter-spacing: 1px;
            }

            input[type="text"],
            input[type="number"],
            input[type="date"],
            textarea,
            select {
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
                margin-top: 5px;
            }

            select option {
                color: #333;
                background-color: #fff;
            }

            input[type="text"]:focus,
            input[type="number"]:focus,
            input[type="date"]:focus,
            textarea:focus,
            select:focus {
                border-color: #007bff;
                box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.25);
            }

            textarea {
                resize: vertical;
                min-height: 120px;
            }

            .poster-preview {
                margin-top: 20px;
                text-align: center;
                background: #f8f9fa;
                border: 1px dashed #ced4da;
                padding: 20px;
                border-radius: 12px;
            }

            .poster-preview img {
                max-width: 150px;
                height: auto;
                border-radius: 8px;
                border: 1px solid #e2e8f0;
                display: block;
                margin: 0 auto;
            }

            button[type="submit"] {
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
                background: linear-gradient(135deg, #00d4ff 0%, #0099ff 100%);
                color: white;
                width: 100%;
                margin-top: 30px;
            }

            button[type="submit"]:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 25px rgba(0, 123, 255, 0.3);
            }

            .back-link {
                display: inline-block;
                margin-bottom: 25px;
                text-decoration: none;
                color: #007bff;
                font-weight: 500;
                font-size: 14px;
            }

            .back-link:hover {
                text-decoration: underline;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <a href="${pageContext.request.contextPath}/admin/movies" class="back-link">← Quay lại danh sách phim</a>

            <h2>${movie != null ? " Chỉnh sửa phim" : " Thêm phim mới"}</h2>


            <c:if test="${not empty error}">
                <div style="padding: 15px 20px; border-radius: 12px; margin-bottom: 25px; font-weight: 600; background: rgba(239, 68, 68, 0.2); color: #ef4444; border: 1px solid rgba(239, 68, 68, 0.3);">
                     ${error}
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/admin/movies?action=${movie != null ? 'update' : 'add'}"
                  method="post" 
                  enctype="multipart/form-data">

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

                <label for="posterUrl">Poster URL:</label>
                <input type="text" id="posterUrl" name="posterUrl"
                       value="${movie != null ? movie.image : ''}"
                       oninput="updatePreview(this.value)">

                <div class="poster-preview">
                    <img id="posterImg" src="${pageContext.request.contextPath}/assets/admin/img/img/${movie.image != null ? movie.image : 'default.jpg'}">
                </div>

                <button type="submit">${movie != null ? " Cập nhật phim" : " Thêm phim mới"}</button>
            </form>

        </div>

        <script>
            function updatePreview(url) {
                const img = document.getElementById('posterImg');
                const defaultImgSrc = '${pageContext.request.contextPath}/assets/admin/img/img/default.jpg';
                const baseImgPath = '${pageContext.request.contextPath}/assets/admin/img/img/';

                if (!url || url.trim() === '') {
                    img.src = defaultImgSrc;
                    img.onerror = null;
                    r
                } else {
                    let finalUrl;

                    if (!url.startsWith('http') && !url.includes('/')) {

                        finalUrl = baseImgPath + url.trim();
                    } else {

                        finalUrl = url.trim();
                    }
                    img.src = finalUrl;

                    img.onerror = function () {
                        console.warn('Failed to load image:', finalUrl, 'Falling back to default.');
                        img.src = defaultImgSrc;
                    };
                }
            }


            document.addEventListener('DOMContentLoaded', function () {
                const posterUrlInput = document.getElementById('posterUrl');
                if (posterUrlInput && posterUrlInput.value) {
                    updatePreview(posterUrlInput.value);
                }
            });
        </script>
    </body>
</html>


