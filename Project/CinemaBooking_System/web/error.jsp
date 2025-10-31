<%@ page contentType="text/html; charset=UTF-8" language="java" isErrorPage="true" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!doctype html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Đã xảy ra lỗi</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <style>
    body { background:#f7f7f9; }
    .card { border-radius: 14px; }
    .mono { font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace; }
    .small-muted { font-size: .9rem; color:#6c757d; }
  </style>
</head>
<body>
<div class="container py-5">
  <div class="row justify-content-center">
    <div class="col-lg-7">
      <div class="card shadow-sm">
        <div class="card-header bg-danger text-white">
          <h5 class="mb-0">Đã xảy ra lỗi</h5>
        </div>
        <div class="card-body">
          <p class="small-muted mb-2">Thông điệp:</p>
          <div class="alert alert-warning">
            <c:choose>
              <c:when test="${not empty error}">
                ${error}
              </c:when>
              <c:when test="${not empty pageContext.exception}">
                ${pageContext.exception.message}
              </c:when>
              <c:otherwise>
                Có lỗi không xác định. Vui lòng thử lại sau.
              </c:otherwise>
            </c:choose>
          </div>

          <c:if test="${not empty pageContext.exception}">
            <details class="mb-3">
              <summary>Xem chi tiết kỹ thuật (stacktrace)</summary>
              <pre class="mono mt-2"><%
                  if (exception != null) {
                      exception.printStackTrace(new java.io.PrintWriter(out));
                  }
              %></pre>
            </details>
          </c:if>

          <div class="d-flex gap-2">
            <button class="btn btn-outline-secondary" onclick="history.back()">⬅ Quay lại</button>
            <a class="btn btn-primary" href="${pageContext.request.contextPath}/">Về trang chủ</a>
          </div>
        </div>
        <div class="card-footer text-muted small">
          Thời gian: <span class="mono"><%= new java.util.Date() %></span>
        </div>
      </div>
    </div>
  </div>
</div>
</body>
</html>
