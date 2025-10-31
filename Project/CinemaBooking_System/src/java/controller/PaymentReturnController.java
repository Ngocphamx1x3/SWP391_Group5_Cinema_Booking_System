package controller;

import dal.OrderDAO;
import dal.TicketDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import util.EmailTemplates;
import util.EmailUtil;

import java.io.IOException;
import java.time.Instant;

@WebServlet(name = "PaymentReturnController", urlPatterns = {"/payment/return"})
public class PaymentReturnController extends HttpServlet {

    private static final String TAG = "[PaymentReturn] ";

    private final OrderDAO orderDAO = new OrderDAO();
    private final TicketDAO ticketDAO = new TicketDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        System.out.println(TAG + "----- START @ " + Instant.now() + " -----");

        // 0) Log toàn bộ tham số PayOS trả về
        final String resultCode  = req.getParameter("code");        // "00" nếu thành công
        final String status      = req.getParameter("status");      // "PAID" nếu thành công
        final String ocNumeric   = req.getParameter("orderCode");   // mã numeric đã gửi sang PayOS
        final String providerRef = req.getParameter("id");          // paymentLinkId
        final String cancelFlag  = req.getParameter("cancel");      // có thể có

        System.out.println(TAG + "params: code=" + resultCode
                + ", status=" + status
                + ", orderCode(numeric)=" + ocNumeric
                + ", providerRef(id)=" + providerRef
                + ", cancel=" + cancelFlag);

        if (ocNumeric == null || ocNumeric.isBlank()) {
            System.out.println(TAG + "ERROR: Missing orderCode");
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing orderCode");
            return;
        }

        final boolean ok = "00".equals(resultCode) && "PAID".equalsIgnoreCase(status);
        System.out.println(TAG + "computed ok=" + ok);

        try {
            if (ok) {
                // 1) Đánh dấu đã thanh toán và lấy orderId
                int orderId;
                if (providerRef != null && !providerRef.isBlank()) {
                    System.out.println(TAG + "Mark paid by providerRef: " + providerRef);
                    orderDAO.markPaidByProviderRef(providerRef);
                    orderId = orderDAO.getOrderIdByProviderRef(providerRef);
                } else {
                    String displayCode = "ORD" + ocNumeric;
                    System.out.println(TAG + "Mark paid by displayCode: " + displayCode);
                    orderDAO.markPaidByCode(displayCode);
                    orderId = orderDAO.getOrderIdByCode(displayCode);
                }
                System.out.println(TAG + "resolved orderId=" + orderId);

                // 2) Confirm vé (HOLD -> CONFIRMED)
                if (orderId > 0) {
                    boolean confirmed = false;
                    try {
                        confirmed = ticketDAO.confirmTicketsByOrder(orderId);
                    } catch (Exception ee) {
                        System.out.println(TAG + "EX while confirmTicketsByOrder: " + ee.getMessage());
                        ee.printStackTrace();
                    }
                    System.out.println(TAG + "confirmTicketsByOrder(orderId=" + orderId + ") => " + confirmed);

                    // 3) Gửi email (không chặn luồng nếu lỗi)
                    try {
                        boolean sent = sendTicketEmail(orderId);
                        System.out.println(TAG + "sendTicketEmail(orderId=" + orderId + ") => " + sent);
                    } catch (Exception mailEx) {
                        System.out.println(TAG + "EX while sendTicketEmail: " + mailEx.getMessage());
                        mailEx.printStackTrace();
                    }
                } else {
                    System.out.println(TAG + "WARN: orderId==0, skip confirm & email");
                }

                // 4) Forward trang success
                req.setAttribute("orderCode", "ORD" + ocNumeric);
                System.out.println(TAG + "forward -> /views/users/checkout-success.jsp");
                req.getRequestDispatcher("/views/users/checkout-success.jsp").forward(req, resp);
                System.out.println(TAG + "----- END (success) -----");
                return;
            }

            // ---- Không OK: coi như huỷ / thất bại
            String displayCode = "ORD" + ocNumeric;
            System.out.println(TAG + "Not OK. Cancel flow for " + displayCode);

            int orderId = orderDAO.getOrderIdByCode(displayCode);
            System.out.println(TAG + "resolved orderId=" + orderId + " for cancel");

            if (orderId > 0) {
                try {
                    boolean released = ticketDAO.releaseHeldSeats(orderId);
                    System.out.println(TAG + "releaseHeldSeats(orderId=" + orderId + ") => " + released);
                } catch (Exception ee) {
                    System.out.println(TAG + "EX while releaseHeldSeats: " + ee.getMessage());
                    ee.printStackTrace();
                }
            }
            orderDAO.markCancelledByCode(displayCode);
            System.out.println(TAG + "Order marked CANCELLED: " + displayCode);

            req.setAttribute("orderCode", displayCode);
            System.out.println(TAG + "forward -> /views/users/checkout-cancel.jsp");
            req.getRequestDispatcher("/views/users/checkout-cancel.jsp").forward(req, resp);
            System.out.println(TAG + "----- END (cancel) -----");

        } catch (Exception e) {
            System.out.println(TAG + "EX top-level: " + e.getMessage());
            e.printStackTrace();
            req.setAttribute("error", "Cannot verify payment.");
            req.getRequestDispatcher("/error.jsp").forward(req, resp);
            System.out.println(TAG + "----- END (error) -----");
        }
    }

    /** Gửi email xác nhận vé sau khi order đã PAID & vé CONFIRMED */
    private boolean sendTicketEmail(int orderId) throws Exception {
        System.out.println(TAG + "[Mail] prepare for orderId=" + orderId);
        OrderDAO.OrderEmailInfo info = orderDAO.getOrderEmailInfoByOrderId(orderId);

        if (info == null) {
            System.out.println(TAG + "[Mail] info == null");
            return false;
        }
        System.out.println(TAG + "[Mail] info -> email=" + info.userEmail
                + ", orderCode=" + info.orderCode
                + ", seats=" + info.seatCodes
                + ", movie=" + info.movieName
                + ", cinema=" + info.cinemaName
                + ", room=" + info.roomName
                + ", time=" + info.startAt);

        if (info.userEmail == null || info.userEmail.isBlank()) {
            System.out.println(TAG + "[Mail] empty recipient");
            return false;
        }

        String subject = " YOUR TICKET - "
                + (info.movieName != null ? info.movieName : "Cinema Booking")
                + " (" + info.orderCode + ")";

        String html = EmailTemplates.ticketSuccess(info);
        boolean ok = EmailUtil.sendHtmlEmail(info.userEmail, subject, html);
        System.out.println(TAG + "[Mail] sent=" + ok + " to=" + info.userEmail);
        return ok;
    }
}
