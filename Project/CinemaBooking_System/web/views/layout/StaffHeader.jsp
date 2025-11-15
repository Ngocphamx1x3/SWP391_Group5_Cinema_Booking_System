<%@ page contentType="text/html;charset=UTF-8" %>
<%
    // Lấy title từ request attribute, nếu không có thì dùng title mặc định
    String pageTitle = (String) request.getAttribute("pageTitle");
    if (pageTitle == null) {
        pageTitle = "Staff Dashboard";
    }
    
    // Lấy staff name từ session
    String staffName = (String) session.getAttribute("staffName");
    if (staffName == null) {
        staffName = "Nhân viên";
    }
%>
<!-- Staff Header -->
<header>
    <h1><%= pageTitle %></h1>
    <div class="header-right">
        <span>Staff: <%= staffName %></span>
        <span><%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %></span>
    </div>
</header>

