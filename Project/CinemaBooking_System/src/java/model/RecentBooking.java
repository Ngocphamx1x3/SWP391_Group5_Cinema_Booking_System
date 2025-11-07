package model;

import java.util.Date;
import java.util.List;

public class RecentBooking {
    private String ticketCode;
    private String customerName;
    private String movieName;
    private Date showtime;
    private List<String> seats;
    private double totalAmount;
    private String status;
    
    public RecentBooking() {
    }
    
    public RecentBooking(String ticketCode, String customerName, String movieName, 
                       Date showtime, List<String> seats, double totalAmount, String status) {
        this.ticketCode = ticketCode;
        this.customerName = customerName;
        this.movieName = movieName;
        this.showtime = showtime;
        this.seats = seats;
        this.totalAmount = totalAmount;
        this.status = status;
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
    
    // Helper method to format seats as string
    public String getSeatsFormatted() {
        if (seats == null || seats.isEmpty()) {
            return "";
        }
        return String.join(", ", seats);
    }
    
    // Helper method to format currency
    public String getTotalAmountFormatted() {
        return String.format("%,.0f₫", totalAmount);
    }
    
    // Helper method to format status with Vietnamese text
    public String getStatusFormatted() {
        if ("CONFIRMED".equalsIgnoreCase(status)) {
            return "✅ Đã check-in";
        } else if ("PENDING".equalsIgnoreCase(status)) {
            return "PENDING";
        } else if ("CANCELLED".equalsIgnoreCase(status)) {
            return "CANCELLED";
        } else {
            return status;
        }
    }
}