<%@ page contentType="text/html;charset=UTF-8"%>
<!doctype html><html><head><meta charset="utf-8">
<title>Thanh toán thành công</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
</head><body class="bg-light">
<div class="container py-5">
  <div class="bg-white rounded-4 shadow p-4 mx-auto" style="max-width:680px">
    <h4>Thanh toán thành công</h4>
    <p>Mã đơn: <strong>${orderCode}</strong></p>
    <p>Vé đã được xuất. Vui lòng kiểm tra email/mục đơn hàng.</p>
    <a href="${pageContext.request.contextPath}/home" class="btn btn-primary">Về trang chủ</a>
  </div>
</div>
</body></html>
