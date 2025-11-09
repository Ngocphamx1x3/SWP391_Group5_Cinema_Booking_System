<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.FoodCombo, java.util.List"%>
<%@page import="dal.FoodComboDAO"%>
<%!
    private boolean isValidImageFile(String imageName) {
        if (imageName == null || imageName.trim().isEmpty()) return false;
        String lower = imageName.toLowerCase();
        return lower.endsWith(".jpg") || lower.endsWith(".jpeg") || 
               lower.endsWith(".png") || lower.endsWith(".gif") || 
               lower.endsWith(".webp") || lower.endsWith(".svg");
    }
%>
<%
    List<FoodCombo> foodCombos = (List<FoodCombo>) request.getAttribute("foodCombos");
    if (foodCombos == null) {
        FoodComboDAO fcDao = new FoodComboDAO();
        foodCombos = fcDao.getActiveFoodCombos();
        request.setAttribute("foodCombos", foodCombos);
    }
    int pageSize = 9;
    int totalItems = (foodCombos != null) ? foodCombos.size() : 0;
    int totalPages = Math.max(1, (int) Math.ceil(totalItems / (double) pageSize));
    int currentPage = 1;
    try {
        String pageParam = request.getParameter("page");
        if (pageParam != null) currentPage = Integer.parseInt(pageParam);
    } catch (Exception ignore) {}
    currentPage = Math.max(1, Math.min(currentPage, totalPages));
    int startIndex = (currentPage - 1) * pageSize;
    int endIndex = Math.min(startIndex + pageSize, totalItems);
    request.setAttribute("pageTitle", "🍿 Chọn Combo");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chọn Combo | Cinema Booking</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/user/css/web.css">
    <link rel="icon" href="${pageContext.request.contextPath}/assets/user/img/logo.png" type="image/x-icon"/>
    <style>
        body {
            background: #f8fafc;
            font-family: 'Inter', sans-serif;
            color: #1e293b;
        }

        .container {
            max-width: 1180px;
            margin: 0 auto;
            padding: 32px 24px;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .toolbar {
            background: #fff;
            border-radius: 16px;
            padding: 16px 20px;
            display: flex;
            justify-content: space-between;
            flex-wrap: wrap;
            align-items: center;
            gap: 12px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.06);
            margin-bottom: 28px;
            width: 100%;
        }

        .search-box {
            display: flex;
            flex: 1;
            gap: 8px;
            min-width: 260px;
        }

        .search-box input {
            flex: 1;
            border: 1px solid #cbd5e1;
            border-radius: 10px;
            padding: 10px 14px;
            font-size: 14px;
            outline: none;
            transition: 0.2s;
        }

        .search-box input:focus {
            border-color: #3b82f6;
            box-shadow: 0 0 0 3px rgba(59,130,246,0.2);
        }

        .btn {
            background: linear-gradient(135deg, #3b82f6, #2563eb);
            color: white;
            border: none;
            border-radius: 10px;
            padding: 9px 16px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 14px rgba(37,99,235,0.25);
        }

        .btn-ghost {
            background: white;
            color: #2563eb;
            border: 2px solid #3b82f6;
            border-radius: 10px;
            padding: 9px 16px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
            text-decoration: none;
            display: inline-block;
        }

        .btn-ghost:hover {
            background: #eff6ff;
            border-color: #2563eb;
            color: #1e40af;
            transform: translateY(-1px);
            box-shadow: 0 4px 8px rgba(59, 130, 246, 0.15);
        }

        .btn-ghost:active {
            transform: translateY(0);
            box-shadow: 0 2px 4px rgba(59, 130, 246, 0.1);
        }

        .content-wrap {
            display: grid;
            grid-template-columns: 1.7fr 1fr;
            gap: 20px;
            width: 100%;
            max-width: 100%;
            align-items: start;
        }

        .card {
            background: #fff;
            border-radius: 16px;
            padding: 20px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.05);
            width: 100%;
        }

        .card:first-child {
            max-width: 100%;
            margin-right: 0;
            padding: 18px;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(235px, 1fr));
            gap: 16px;
            justify-items: center;
        }

        .combo-item {
            background: #f9fafb;
            border-radius: 16px;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            width: 100%;
            transition: 0.2s ease;
        }

        .combo-item:hover {
            transform: translateY(-3px);
            box-shadow: 0 6px 12px rgba(0,0,0,0.08);
        }

        .combo-thumb {
            width: 100%;
            height: 160px;
            object-fit: cover;
            background: #e2e8f0;
        }

        .combo-body {
            padding: 14px 16px;
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .combo-title {
            font-weight: 700;
            font-size: 15px;
            color: #0f172a;
        }

        .combo-desc {
            font-size: 13px;
            color: #64748b;
            line-height: 1.5;
            min-height: 36px;
        }

        .combo-actions {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 10px;
        }

        .combo-price {
            font-weight: 700;
            color: #16a34a;
            font-size: 15px;
        }

        .qty {
            display: inline-flex;
            align-items: center;
            border: 1px solid #e2e8f0;
            border-radius: 10px;
            overflow: hidden;
        }

        .qty button {
            background: #f1f5f9;
            border: none;
            padding: 6px 10px;
            font-weight: bold;
            cursor: pointer;
        }

        .qty input {
            width: 40px;
            border: none;
            text-align: center;
            padding: 6px 0;
            outline: none;
        }

        .cart {
            position: sticky;
            top: 24px;
            display: flex;
            flex-direction: column;
            gap: 12px;
            height: fit-content;
            max-width: 100%;
        }

        .cart-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .cart-list {
            display: flex;
            flex-direction: column;
            gap: 10px;
            max-height: 420px;
            overflow-y: auto;
        }

        .cart-item {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 10px;
            padding: 10px 12px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .cart-item-title { font-weight: 600; font-size: 14px; }
        .cart-item-sub { font-size: 12px; color: #6b7280; }

        .cart-total {
            display: flex;
            justify-content: space-between;
            font-weight: 700;
            font-size: 15px;
            border-top: 1px solid #e2e8f0;
            padding-top: 10px;
        }

        .empty {
            text-align: center;
            color: #94a3b8;
            padding: 20px;
            border: 1px dashed #cbd5e1;
            border-radius: 12px;
        }

        @media (max-width: 1024px) {
            .content-wrap { 
                grid-template-columns: 1fr; 
                gap: 24px;
            }
            .cart { 
                position: static; 
                max-width: 100%;
            }
            .container {
                max-width: 100%;
                padding: 24px 16px;
            }
        }

        @media (min-width: 1025px) and (max-width: 1400px) {
            .container {
                max-width: 1120px;
            }
            .content-wrap {
                grid-template-columns: 1.65fr 1fr;
                gap: 18px;
            }
        }

        @media (min-width: 1401px) {
            .container {
                max-width: 1180px;
            }
        }

        .pagination {
            display: flex;
            gap: 8px;
            align-items: center;
            justify-content: center;
            margin-top: 16px;
            flex-wrap: wrap;
        }

        .page-link {
            padding: 8px 12px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            text-decoration: none;
            color: #334155;
            background: #fff;
        }

        .page-link.active {
            background: #2563eb;
            color: #fff;
            border-color: #2563eb;
        }

        .page-info {
            text-align: center;
            color: #64748b;
            margin-top: 8px;
        }
    </style>
</head>
<body>
<jsp:include page="/views/layout/Header.jsp"/>

<div class="container">
    <div class="toolbar">
        <div class="search-box">
            <input type="text" id="keyword" placeholder="🔍 Tìm kiếm combo popcorn, drink, snack...">
            <button id="btnSearch" class="btn">Tìm</button>
            <button id="btnReset" class="btn-ghost">Reset</button>
        </div>
        <a href="${pageContext.request.contextPath}/" class="btn-ghost">🏠 Trang chủ</a>
    </div>

    <div class="content-wrap">
        <div class="card">
            <h3 style="margin-bottom: 16px;">Danh sách Combo</h3>
            <div id="comboGrid" class="grid">
                <% if (foodCombos != null && !foodCombos.isEmpty()) { 
                    for (int i = startIndex; i < endIndex; i++) { 
                        FoodCombo c = foodCombos.get(i); %>
                    <div class="combo-item" data-name="<%= c.getName() %>"
                         data-price="<%= c.getPrice() %>" data-id="<%= c.getComboID() %>">
                        <% if (isValidImageFile(c.getImage())) { %>
                            <img class="combo-thumb"
                                 src="${pageContext.request.contextPath}/assets/user/img/<%= c.getImage() %>"
                                 alt="<%= c.getName() %>"
                                 onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                            <div class="combo-thumb" style="display:none;align-items:center;justify-content:center;color:#64748b;">Không có ảnh</div>
                        <% } else { %>
                            <div class="combo-thumb" style="display:flex;align-items:center;justify-content:center;color:#64748b;">Không có ảnh</div>
                        <% } %>
                        <div class="combo-body">
                            <div class="combo-title"><%= c.getName() %></div>
                            <div class="combo-desc"><%= c.getDescription() != null ? c.getDescription() : "Combo đồ ăn/uống" %></div>
                            <div class="combo-actions">
                                <div class="combo-price"><%= c.getFormattedPrice() %></div>
                                <div style="display:flex;align-items:center;gap:8px;">
                                    <div class="qty">
                                        <button class="btnDec">-</button>
                                        <input type="text" class="qtyInput" value="1" inputmode="numeric">
                                        <button class="btnInc">+</button>
                                    </div>
                                    <button class="btn btnAdd">Thêm</button>
                                </div>
                            </div>
                        </div>
                    </div>
                <% } } else { %>
                    <div class="empty" style="grid-column:1/-1;">Chưa có combo nào để hiển thị</div>
                <% } %>
            </div>
            <% if (foodCombos != null && totalItems > 0) { %>
            <div class="pagination">
                <%
                    String baseUrl = request.getRequestURI();
                    int prev = (currentPage > 1) ? currentPage - 1 : 1;
                    int next = (currentPage < totalPages) ? currentPage + 1 : totalPages;
                %>
                <a class="page-link" href="<%= baseUrl %>?page=<%= prev %>">« Trước</a>
                <% for (int pIndex = 1; pIndex <= totalPages; pIndex++) { %>
                    <a class="page-link <%= (pIndex==currentPage?"active":"") %>" href="<%= baseUrl %>?page=<%= pIndex %>"><%= pIndex %></a>
                <% } %>
                <a class="page-link" href="<%= baseUrl %>?page=<%= next %>">Sau »</a>
            </div>
            <div class="page-info">Trang <%= currentPage %> / <%= totalPages %></div>
            <% } %>
        </div>

        <div class="cart card" id="cart">
            <div class="cart-header">
                <span style="font-weight:700;">🛒 Giỏ hàng</span>
                <button id="btnClear" class="btn-ghost" type="button">Xóa hết</button>
            </div>
            <div id="cartList" class="cart-list">
                <div class="empty">Chưa có sản phẩm nào</div>
            </div>
            <div class="cart-total">
                <span>Tổng</span>
                <span id="cartTotal">0 ₫</span>
            </div>
            <button id="btnCheckout" class="btn" style="margin-top:10px;">Thanh toán</button>
        </div>
    </div>
</div>

<jsp:include page="/views/layout/Footer.jsp"/>

<script>
// Placeholder JS giữ nguyên
</script>
</body>
</html>
