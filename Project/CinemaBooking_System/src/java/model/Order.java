/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
// Order.java
package model;

import dal.OrderDAO;
import java.sql.Timestamp;
import java.util.List;

public class Order {

    private int id;
    private int userId;
    private Timestamp orderDate;
    private String status;
    private long totalMoney;
    private String orderCode;
    private Timestamp expiresAt;
    private Timestamp paidAt;
    private String providerRef;
    private List<OrderCombo> orderCombos;

    // Constructors
    public Order() {
    }

    public Order(int id, int userId, Timestamp orderDate, String status, long totalMoney,
            String orderCode, Timestamp expiresAt, Timestamp paidAt, String providerRef) {
        this.id = id;
        this.userId = userId;
        this.orderDate = orderDate;
        this.status = status;
        this.totalMoney = totalMoney;
        this.orderCode = orderCode;
        this.expiresAt = expiresAt;
        this.paidAt = paidAt;
        this.providerRef = providerRef;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public Timestamp getOrderDate() {
        return orderDate;
    }

    public void setOrderDate(Timestamp orderDate) {
        this.orderDate = orderDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public long getTotalMoney() {
        return totalMoney;
    }

    public void setTotalMoney(long totalMoney) {
        this.totalMoney = totalMoney;
    }

    public String getOrderCode() {
        return orderCode;
    }

    public void setOrderCode(String orderCode) {
        this.orderCode = orderCode;
    }

    public Timestamp getExpiresAt() {
        return expiresAt;
    }

    public void setExpiresAt(Timestamp expiresAt) {
        this.expiresAt = expiresAt;
    }

    public Timestamp getPaidAt() {
        return paidAt;
    }

    public void setPaidAt(Timestamp paidAt) {
        this.paidAt = paidAt;
    }

    public String getProviderRef() {
        return providerRef;
    }

    public void setProviderRef(String providerRef) {
        this.providerRef = providerRef;
    }

    public List<OrderCombo> getOrderCombos() {
        return orderCombos;
    }

    public void setOrderCombos(List<OrderCombo> orderCombos) {
        this.orderCombos = orderCombos;
    }

    // Helper methods
    public String getFormattedTotalMoney() {
        return String.format("%,d", this.totalMoney) + " đ";
    }

    public String getFormattedOrderDate() {
        if (orderDate != null) {
            return new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(orderDate);
        }
        return "N/A";
    }

    public String getStatusText() {
        switch (this.status) {
            case "PAID":
                return "Đã thanh toán";
            case "PENDING":
                return "Chờ thanh toán";
            case "CANCELLED":
                return "Đã hủy";
            default:
                return this.status;
        }
    }

    public String getStatusColor() {
        switch (this.status) {
            case "PAID":
                return "success";
            case "PENDING":
                return "warning";
            case "CANCELLED":
                return "danger";
            default:
                return "secondary";
        }
    }

    private List<OrderDAO.TicketInfo> tickets;

    public List<OrderDAO.TicketInfo> getTickets() {
        return tickets;
    }

    public void setTickets(List<OrderDAO.TicketInfo> tickets) {
        this.tickets = tickets;
    }
}
