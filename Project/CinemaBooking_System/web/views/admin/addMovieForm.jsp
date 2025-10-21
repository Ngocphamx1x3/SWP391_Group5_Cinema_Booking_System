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
        <select name="directors" multiple size="3">
            <c:forEach var="d" items="${directorList}">
                <option value="${d.id}">${d.name}</option>
            </c:forEach>
        </select>

        <label>Ngôn ngữ</label>
        <select name="languages" multiple size="3">
            <c:forEach var="l" items="${languageList}">
                <option value="${l.id}">${l.name}</option>
            </c:forEach>
        </select>

        <label>Thể loại</label>
        <select name="movieTypes" multiple size="3">
            <c:forEach var="t" items="${movieTypeList}">
                <option value="${t.id}">${t.name}</option>
            </c:forEach>
        </select>

        <button type="submit">💾 Lưu phim</button>
    </form>
</body>
</html>