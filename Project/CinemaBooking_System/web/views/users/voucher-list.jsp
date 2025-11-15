<%-- 
    Document   : voucher-list
    Created on : Nov 4, 2025, 8:17:38 PM
    Author     : admin
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<div class="voucher-section">
    <h5> Khuyến mãi có sẵn</h5>
    
    <c:choose>
        <c:when test="${empty vouchers}">
            <div class="no-vouchers">
                <p class="text-muted">Không có khuyến mãi nào khả dụng cho phim này</p>
            </div>
        </c:when>
        <c:otherwise>
            <div class="voucher-list">
                <c:forEach var="voucher" items="${vouchers}">
                    <div class="voucher-item" 
                         data-voucher-id="${voucher.id}"
                         data-voucher-code="${voucher.code}"
                         data-discount-type="${voucher.discountType}"
                         data-discount-value="${voucher.discountValue}"
                         data-max-discount="${voucher.maxDiscountAmount}"
                         data-min-order="${voucher.minOrderAmount}">
                        
                        <div class="voucher-header">
                            <div class="voucher-code">${voucher.code}</div>
                            <div class="voucher-badge">
                                <c:choose>
                                    <c:when test="${voucher.discountType == 1}">
                                        -${voucher.discountValue}%
                                    </c:when>
                                    <c:otherwise>
                                        -<fmt:formatNumber value="${voucher.discountValue}" pattern="#,###"/>₫
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        
                        <div class="voucher-name">${voucher.name}</div>
                        
                        <c:if test="${not empty voucher.description}">
                            <div class="voucher-desc">${voucher.description}</div>
                        </c:if>
                        
                        <div class="voucher-conditions">
                            <small class="text-muted">
                                Đơn tối thiểu: <fmt:formatNumber value="${voucher.minOrderAmount}" pattern="#,###"/>₫
                                <c:if test="${voucher.discountType == 1 && voucher.maxDiscountAmount > 0}">
                                    • Giảm tối đa: <fmt:formatNumber value="${voucher.maxDiscountAmount}" pattern="#,###"/>₫
                                </c:if>
                            </small>
                        </div>
                        
                        <div class="voucher-expiry">
                            <small class="text-muted">
                                HSĐ: <fmt:formatDate value="${voucher.endDate}" pattern="dd/MM/yyyy"/>
                            </small>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<style>
.voucher-section {
    margin: 20px 0;
    padding: 15px;
    background: #f8f9fa;
    border-radius: 10px;
    border: 1px solid #e9ecef;
}

.voucher-section h5 {
    color: #D0010B;
    margin-bottom: 15px;
    font-weight: bold;
}

.no-vouchers {
    text-align: center;
    padding: 20px;
    color: #6c757d;
}

.voucher-list {
    display: flex;
    flex-direction: column;
    gap: 12px;
}

.voucher-item {
    background: white;
    border: 2px solid #e9ecef;
    border-radius: 8px;
    padding: 15px;
    cursor: pointer;
    transition: all 0.3s ease;
    position: relative;
}

.voucher-item:hover {
    border-color: #D0010B;
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(208, 1, 11, 0.1);
}

.voucher-item.selected {
    border-color: #28a745;
    background: #f8fff9;
}

.voucher-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 8px;
}

.voucher-code {
    font-weight: bold;
    color: #D0010B;
    font-size: 16px;
}

.voucher-badge {
    background: #28a745;
    color: white;
    padding: 4px 8px;
    border-radius: 4px;
    font-size: 12px;
    font-weight: bold;
}

.voucher-name {
    font-weight: 600;
    color: #333;
    margin-bottom: 5px;
}

.voucher-desc {
    color: #666;
    font-size: 14px;
    margin-bottom: 8px;
}

.voucher-conditions, .voucher-expiry {
    font-size: 12px;
}

.voucher-item.selected::after {
    content: "✓";
    position: absolute;
    top: 10px;
    right: 10px;
    background: #28a745;
    color: white;
    width: 20px;
    height: 20px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 12px;
}
</style>
