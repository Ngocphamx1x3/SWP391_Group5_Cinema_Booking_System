<%@ page contentType="text/html;charset=UTF-8" %>
<%
    // Lấy footer text từ request attribute nếu có, nếu không dùng default
    String footerText = (String) request.getAttribute("footerText");
    if (footerText == null) {
        footerText = "© 2025 Cinema Booking System - Staff Panel | Powered by Modern Technology";
    }
%>
<!-- Staff Footer -->
<footer>
    <%= footerText %>
</footer>

