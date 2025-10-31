<%@ page contentType="text/html;charset=UTF-8"%>
<!doctype html><html><head><meta charset="utf-8">
<title>Đã hủy thanh toán</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
</head><body class="bg-light">
<div class="container py-5">
  <div class="bg-white rounded-4 shadow p-4 mx-auto" style="max-width:680px">
    <h4>Giao dịch đã hủy</h4>
    <p>Mã đơn: <strong>${orderCode}</strong></p>
    <p>Giữ chỗ đã được trả lại. Bạn có thể đặt lại nếu muốn.</p>
    <a href="${pageContext.request.contextPath}/" class="btn btn-secondary">Về trang chủ</a>
  </div>
</div>
</body></html>
