<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>${movie != null ? "Chỉnh sửa phim" : "Thêm phim mới"}</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <%-- Assuming you might want to reuse styles from previous examples --%>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: #f4f7fa; /* Light background */
            color: #2d3748; /* Dark text */
            padding: 40px; /* Add padding for standalone page */
            min-height: 100vh;
        }

        .container {
            max-width: 700px;
            margin: auto;
            background: #ffffff; /* White background */
            padding: 40px; /* Increased padding */
            border-radius: 20px; /* Consistent border radius */
            border: 1px solid #e2e8f0; /* Light border */
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.05); /* Subtle shadow */
        }

        h2 {
            text-align: center;
            margin-bottom: 40px; /* Increased margin */
            font-size: 24px;
            font-weight: 700;
            color: #1a202c; /* Darker heading */
        }

        label {
            display: block;
            color: #4a5568; /* Dark gray label */
            font-size: 13px;
            font-weight: 600;
            margin-bottom: 8px;
            margin-top: 20px; /* Adjusted margin */
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        input[type="text"],
        input[type="number"],
        input[type="date"],
        textarea,
        select {
            width: 100%;
            background: #ffffff; /* White input background */
            border: 1px solid #ced4da; /* Gray border */
            border-radius: 12px; /* Consistent border radius */
            padding: 14px 16px; /* Adjusted padding */
            color: #2d3748; /* Dark text */
            font-size: 14px;
            outline: none;
            transition: all 0.3s ease;
            font-family: 'Inter', sans-serif;
            margin-top: 5px; /* Keep small top margin */
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
            border-color: #007bff; /* Blue border on focus */
            box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.25); /* Focus ring */
        }

        textarea {
            resize: vertical;
            min-height: 120px; /* Increased height */
        }

        .poster-preview {
            margin-top: 20px; /* Adjusted margin */
            text-align: center;
            background: #f8f9fa; /* Light background for preview area */
            border: 1px dashed #ced4da; /* Dashed border */
            padding: 20px;
            border-radius: 12px;
        }

        .poster-preview img {
            max-width: 150px; /* Ensure image fits */
            height: auto;
            border-radius: 8px; /* Slightly smaller radius */
            border: 1px solid #e2e8f0; /* Light border around image */
            display: block; /* Center image */
            margin: 0 auto; /* Center image */
        }

        button[type="submit"] { /* Target submit button specifically */
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
            width: 100%; /* Make button full width */
            margin-top: 30px; /* Increased margin */
        }

        button[type="submit"]:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(0, 123, 255, 0.3); /* Blue shadow on hover */
        }

        .back-link {
            display: inline-block;
            margin-bottom: 25px; /* Increased margin */
            text-decoration: none;
            color: #007bff; /* Blue link color */
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

        <h2>${movie != null ? "✏️ Chỉnh sửa phim" : "➕ Thêm phim mới"}</h2>

        <%-- Display Error Messages --%>
        <c:if test="${not empty error}">
            <div style="padding: 15px 20px; border-radius: 12px; margin-bottom: 25px; font-weight: 600; background: rgba(239, 68, 68, 0.2); color: #ef4444; border: 1px solid rgba(239, 68, 68, 0.3);">
                ❌ ${error}
            </div>
        </c:if>

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
                    <c:when test="${movie != null && movie.image != null && not empty movie.image}">
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
            const defaultImgSrc = '${pageContext.request.contextPath}/assets/admin/img/img/default.jpg';
            const baseImgPath = '${pageContext.request.contextPath}/assets/admin/img/img/';

            if (!url || url.trim() === '') {
                img.src = defaultImgSrc;
                img.onerror = null; // Remove previous error handler
            } else {
                let finalUrl;
                // Check if it's a full URL or just a filename
                if (!url.startsWith('http') && !url.includes('/')) {
                     // Assume it's a filename in the base path
                     finalUrl = baseImgPath + url.trim();
                } else {
                    // Assume it's a full URL or already includes path context
                    finalUrl = url.trim();
                }
                img.src = finalUrl;
                // Handle image loading errors
                img.onerror = function() {
                    console.warn('Failed to load image:', finalUrl, 'Falling back to default.');
                    img.src = defaultImgSrc;
                };
            }
        }

        // Initialize preview on page load if editing
        document.addEventListener('DOMContentLoaded', function() {
            const posterUrlInput = document.getElementById('posterUrl');
            if (posterUrlInput && posterUrlInput.value) {
                updatePreview(posterUrlInput.value);
            }
        });
    </script>
</body>
</html>