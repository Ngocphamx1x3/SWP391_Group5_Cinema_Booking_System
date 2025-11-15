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
    .discount-info {background: #f8fff9; border: 1px solid #28a745; border-radius: 8px; padding: 10px; margin: 10px 0;}
  </style>
</head>
<body class="bg-light">
<div class="container py-5">
  <div class="mx-auto bg-white rounded-4 shadow p-4" style="max-width:760px">
    <h4 class="mb-3">Quét mã thanh toán</h4>
    <p class="mb-1">Mã đơn: <strong>${orderCode}</strong></p>
    <!-- Thêm vào đầu trang checkout.jsp -->
<script>
console.log("=== CHECKOUT PAGE DEBUG ===");
console.log("JSP EL Values:");
console.log("  - amount: ${amount}");
console.log("  - originalAmount: ${originalAmount}");
console.log("  - discountAmount: ${discountAmount}");
console.log("  - voucherCode: ${voucherCode}");
console.log("  - orderCode: ${orderCode}");

// Kiểm tra xem có discount không
console.log("Discount Info:");
console.log("  - Has discount: ${not empty discountAmount && discountAmount > 0}");
console.log("  - Discount amount: ${discountAmount}");
console.log("  - Original amount: ${originalAmount}");
console.log("  - Final amount: ${amount}");
</script>
    <!-- Hiển thị thông tin giảm giá -->
<c:if test="${not empty discountAmount && discountAmount > 0}">
  <div class="discount-info">
    <div class="row">
      <c:if test="${not empty originalAmount}">
        <div class="col-6">
          <small class="text-muted">Tổng gốc:</small>
          <div class="text-decoration-line-through"><fmt:formatNumber value="${originalAmount}" type="number"/> VND</div>
        </div>
      </c:if>
      <div class="col-6">
        <small class="text-muted">Giảm giá:</small>
        <div class="text-success">-<fmt:formatNumber value="${discountAmount}" type="number"/> VND</div>
      </div>
    </div>
    <c:if test="${not empty voucherCode}">
      <small class="text-muted">Mã khuyến mãi: ${voucherCode}</small>
    </c:if>
  </div>
</c:if>

<p class="mb-3">Số tiền thanh toán: <strong><fmt:formatNumber value="${amount}" type="number"/> VND</strong></p>
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
            <div class="text-danger small">Không tạo được QR — vui lòng bấm "Mở trang thanh toán".</div>
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

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/admin/js/qrcode.min.js"></script>

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