/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author admin
 */
import java.util.Date;
import java.util.List;

public class Booking {

    private String ticketCode;
    private String customerName;
    private String customerEmail;
    private String customerPhone;
    private String movieName;
    private Date showtime;
    private List<String> seats;
    private double totalAmount;
    private String status;
    private Date orderDate;
    private String roomName;
    private String cinemaName;

    public Booking() {
    }

    // Getters and Setters
    public String getTicketCode() {
        return ticketCode;
    }

    public void setTicketCode(String ticketCode) {
        this.ticketCode = ticketCode;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getCustomerEmail() {
        return customerEmail;
    }

    public void setCustomerEmail(String customerEmail) {
        this.customerEmail = customerEmail;
    }

    public String getCustomerPhone() {
        return customerPhone;
    }

    public void setCustomerPhone(String customerPhone) {
        this.customerPhone = customerPhone;
    }

    public String getMovieName() {
        return movieName;
    }

    public void setMovieName(String movieName) {
        this.movieName = movieName;
    }

    public Date getShowtime() {
        return showtime;
    }

    public void setShowtime(Date showtime) {
        this.showtime = showtime;
    }

    public List<String> getSeats() {
        return seats;
    }

    public void setSeats(List<String> seats) {
        this.seats = seats;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Date getOrderDate() {
        return orderDate;
    }

    public void setOrderDate(Date orderDate) {
        this.orderDate = orderDate;
    }

    public String getRoomName() {
        return roomName;
    }

    public void setRoomName(String roomName) {
        this.roomName = roomName;
    }

    public String getCinemaName() {
        return cinemaName;
    }

    public void setCinemaName(String cinemaName) {
        this.cinemaName = cinemaName;
    }

    // Helper methods
    public String getSeatsFormatted() {
        if (seats == null || seats.isEmpty()) {
            return "";
        }
        return String.join(", ", seats);
    }

    public String getTotalAmountFormatted() {
        return String.format("%,.0f₫", totalAmount);
    }

    public String getStatusFormatted() {
        if ("PAID".equalsIgnoreCase(status)) {
            return "PAID";
        } else if ("PENDING".equalsIgnoreCase(status)) {
            return "PENDING";
        } else {
            return status;
        }
    }

    public String getStatusBadgeClass() {
        if ("CONFIRMED".equalsIgnoreCase(status)) {
            return "status-active";
        } else if ("PENDING".equalsIgnoreCase(status)) {
            return "status-pending";
        } else if ("CANCELLED".equalsIgnoreCase(status)) {
            return "status-inactive";
        } else if ("COMPLETED".equalsIgnoreCase(status)) {
            return "status-completed";
        } else {
            return "status-pending";
        }
    }
}
