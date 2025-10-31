package util;

import dal.OrderDAO;

import java.text.SimpleDateFormat;

public class EmailTemplates {
    public static String ticketSuccess(OrderDAO.OrderEmailInfo i) {
        String when = (i.startAt != null)
                ? new SimpleDateFormat("HH:mm dd/MM/yyyy").format(i.startAt)
                : "(updating)";
        String seats = (i.seatCodes == null || i.seatCodes.isBlank()) ? "(updating)" : i.seatCodes;
        String user  = (i.userName != null && !i.userName.isBlank()) ? i.userName : "bạn";

        return "<html><body style='font-family:Arial,sans-serif'>"
                + "<h2>🎟️ Xác nhận đặt vé thành công</h2>"
                + "<p>Xin chào " + escape(user) + ",</p>"
                + "<p>Đơn hàng <b>" + escape(i.orderCode) + "</b> đã thanh toán thành công.</p>"
                + "<ul>"
                + "<li>Phim: <b>" + escape(nullToEmpty(i.movieName)) + "</b></li>"
                + "<li>Rạp/Phòng: <b>" + escape(nullToEmpty(i.cinemaName)) + " - " + escape(nullToEmpty(i.roomName)) + "</b></li>"
                + "<li>Suất chiếu: <b>" + when + "</b></li>"
                + "<li>Ghế: <b>" + escape(seats) + "</b></li>"
                + "<li>Tổng tiền: <b>" + i.totalMoney + " VND</b></li>"
                + "</ul>"
                + "<p>Cảm ơn bạn đã đặt vé tại CinemaBooking.</p>"
                + "</body></html>";
    }
    private static String escape(String s) {
        return s==null ? "" : s.replace("&","&amp;").replace("<","&lt;")
                .replace(">","&gt;").replace("\"","&quot;").replace("'","&#x27;");
    }
    private static String nullToEmpty(String s){ return s==null? "": s; }
}