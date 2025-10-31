<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt"  prefix="fmt" %>
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>Quét mã thanh toán</title>
  <link rel="stylesheet"
        href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"/>
  <style>
    .qr-wrap{display:flex;gap:24px;align-items:center;justify-content:center;margin-top:18px}
    .qr-box{padding:16px;border:1px solid #eee;border-radius:12px;background:#fff;min-width:270px}
  </style>
</head>
<body class="bg-light">
<div class="container py-5">
  <div class="mx-auto bg-white rounded-4 shadow p-4" style="max-width:760px">
    <h4 class="mb-3">Quét mã thanh toán</h4>
    <p class="mb-1">Mã đơn: <strong>${orderCode}</strong></p>
    <p class="mb-3">Số tiền: <strong><fmt:formatNumber value="${amount}" type="number"/> VND</strong></p>

    <div class="qr-wrap">
      <div class="qr-box text-center">
        <c:choose>
          <c:when test="${not empty qrDataUri}">
            <img src="${qrDataUri}" alt="QR PayOS" style="max-width:240px;width:100%;height:auto;" />
          </c:when>

          <c:when test="${empty qrDataUri && not empty qrPlain}">
            <div id="qrBox" style="width:240px;height:240px;margin:0 auto;"></div>
            <div id="qrPlainHolder" data-text="<c:out value='${qrPlain}'/>" style="display:none"></div>
          </c:when>

          <c:otherwise>
            <div class="text-danger small">Không tạo được QR — vui lòng bấm “Mở trang thanh toán”.</div>
          </c:otherwise>
        </c:choose>
        <div class="small text-muted mt-2">Quét QR bằng app ngân hàng</div>
      </div>

      <div>
        <c:choose>
          <c:when test="${not empty checkoutUrl}">
            <a href="${checkoutUrl}" class="btn btn-primary" target="_blank" rel="noopener">Mở trang thanh toán</a>
          </c:when>
          <c:otherwise>
            <button type="button" class="btn btn-secondary" disabled>Không có link thanh toán</button>
          </c:otherwise>
        </c:choose>

        <div class="text-muted small mt-2">Sau khi thanh toán xong, hệ thống sẽ chuyển bạn về lại trang web.</div>

        <c:if test="${not empty expireAt}">
          <div class="text-danger small mt-1">
            Hết hạn lúc: <span id="exp"></span>
          </div>
          <script>
            (function(){
              var ms = Number('${expireAt}');
              if (!isNaN(ms)) {
                var d = new Date(ms);
                document.getElementById('exp').textContent = d.toLocaleString();
              }
            })();
          </script>
        </c:if>
      </div>
    </div>
  </div>
</div>

<!-- JS đặt cuối body -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<!-- qrcode.min.js local -->
<script src="${pageContext.request.contextPath}/assets/admin/js/qrcode.min.js"></script>

<!-- Vẽ QR nếu có qrPlain -->
<c:if test="${empty qrDataUri && not empty qrPlain}">
  <script>
    (function(){
      var holder = document.getElementById('qrPlainHolder');
      var box    = document.getElementById('qrBox');
      if (holder && box && window.QRCode) {
        var text = holder.getAttribute('data-text') || '';
        if (text) {
          new QRCode(box, {
            text: text,
            width: 240,
            height: 240,
            correctLevel: QRCode.CorrectLevel.M
          });
        }
      }
    })();
  </script>
</c:if>
</body>
</html>
