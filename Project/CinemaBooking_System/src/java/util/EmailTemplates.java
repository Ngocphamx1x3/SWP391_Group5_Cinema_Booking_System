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

        // Parse danh sách ghế: "A1,A2" -> ["A1", "A2"]
        String[] seatArray = seats.split(",");
        java.util.List<String> seatList = new java.util.ArrayList<>();
        for (String seat : seatArray) {
            String trimmedSeat = seat.trim();
            if (!trimmedSeat.isEmpty()) {
                seatList.add(trimmedSeat);
            }
        }
        
        // Tạo QR code cho mỗi ghế
        String qrCodeHtml = "";
        if (seatList.isEmpty()) {
            qrCodeHtml = "<div style='margin: 20px 0; text-align: center; padding: 15px; background: #fff3cd; border: 1px solid #ffc107; border-radius: 5px;'>"
                    + "<p style='color: #856404;'>Không có thông tin ghế</p>"
                    + "</div>";
        } else {
            System.out.println("📧 EmailTemplates: Generating QR codes for " + seatList.size() + " seat(s)");
            
            qrCodeHtml = "<div style='margin: 20px 0;'>"
                    + "<p style='font-weight: bold; margin-bottom: 15px; text-align: center;'>Mã QR Code vé của bạn:</p>";
            
            // Tạo QR code cho mỗi ghế
            for (int idx = 0; idx < seatList.size(); idx++) {
                String seatCode = seatList.get(idx);
                // Tạo mã định danh cho mỗi ghế: seatCode + orderCode (ví dụ: A1ORD1763180838168)
                String ticketIdentifier = seatCode + i.orderCode;
                
                // Tạo QR code từ chuỗi định danh
                String qrCodeBase64 = QRCodeUtil.generateQRCodeBase64(ticketIdentifier);
                
                if (qrCodeBase64 != null && !qrCodeBase64.isEmpty()) {
                    System.out.println("📧 EmailTemplates: QR code generated for seat " + seatCode + ", length: " + qrCodeBase64.length());
                    
                    // Hiển thị QR code cho mỗi ghế
                    qrCodeHtml += "<div style='margin: 15px 0; text-align: center; padding: 15px; background: white; border: 1px solid #ddd; border-radius: 5px;'>"
                            + "<p style='font-weight: bold; margin-bottom: 10px; color: #333;'>Ghế: <strong>" + escape(seatCode) + "</strong></p>"
                            + "<div style='display: inline-block; border: 2px solid #333; padding: 10px; background: white;'>"
                            + "<img src=\"" + qrCodeBase64 + "\" alt=\"QR Code Ticket: " + escape(ticketIdentifier) + "\" "
                            + "style='max-width: 250px; width: 250px; height: 250px; display: block;' />"
                            + "</div>";    
                } else {
                    System.out.println("⚠️ EmailTemplates: QR code is null or empty for seat " + seatCode);
                    // Fallback nếu không tạo được QR code
                    qrCodeHtml += "<div style='margin: 15px 0; text-align: center; padding: 15px; background: #fff3cd; border: 1px solid #ffc107; border-radius: 5px;'>"
                            + "<p style='font-weight: bold; margin-bottom: 10px; color: #856404;'>Ghế: <strong>" + escape(seatCode) + "</strong></p>"
                            + "<p style='font-size: 16px; font-weight: bold; color: #856404; font-family: monospace; letter-spacing: 2px;'>" + escape(ticketIdentifier) + "</p>"
                            + "<p style='font-size: 11px; color: #856404; margin-top: 10px;'>Vui lòng trình mã này khi vào rạp</p>"
                            + "</div>";
                }
            }
            
            qrCodeHtml += "<p style='margin-top: 15px; font-size: 11px; color: #999; text-align: center;'>Vui lòng trình mã QR tương ứng với ghế của bạn khi vào rạp</p>"
                    + "</div>";
        }

        return "<html><body style='font-family:Arial,sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;'>"
                + "<div style='background: #f5f5f5; padding: 20px; border-radius: 10px;'>"
                + "<h2 style='color: #2c3e50; margin-top: 0;'>🎟️ Xác nhận đặt vé thành công</h2>"
                + "<p>Xin chào <b>" + escape(user) + "</b>,</p>"
                + "<p>Đơn hàng <b>" + escape(i.orderCode) + "</b> đã thanh toán thành công.</p>"
                + "<div style='background: white; padding: 15px; border-radius: 5px; margin: 15px 0;'>"
                + "<ul style='list-style: none; padding: 0; margin: 0;'>"
                + "<li style='margin: 8px 0;'><strong>Phim:</strong> " + escape(nullToEmpty(i.movieName)) + "</li>"
                + "<li style='margin: 8px 0;'><strong>Rạp/Phòng:</strong> " + escape(nullToEmpty(i.cinemaName)) + " - " + escape(nullToEmpty(i.roomName)) + "</li>"
                + "<li style='margin: 8px 0;'><strong>Suất chiếu:</strong> " + when + "</li>"
                + "<li style='margin: 8px 0;'><strong>Ghế:</strong> " + escape(seats) + "</li>"
                + "<li style='margin: 8px 0;'><strong>Tổng tiền:</strong> " + formatMoney(i.totalMoney) + " VND</li>"
                + "</ul>"
                + "</div>"
                + qrCodeHtml
                + "<p style='margin-top: 20px; color: #666;'>Cảm ơn bạn đã đặt vé tại CinemaBooking.</p>"
                + "</div>"
                + "</body></html>";
    }
    
    private static String formatMoney(long amount) {
        return String.format("%,d", amount);
    }
    
    private static String escape(String s) {
        return s==null ? "" : s.replace("&","&amp;").replace("<","&lt;")
                .replace(">","&gt;").replace("\"","&quot;").replace("'","&#x27;");
    }
    private static String nullToEmpty(String s){ return s==null? "": s; }
}