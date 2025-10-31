package controller;

import dal.OrderDAO;
import dal.TicketDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet(name="PaymentCancelController", urlPatterns={"/payment/cancel"})
public class PaymentCancelController extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
    private final TicketDAO ticketDAO = new TicketDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String ocNumeric = req.getParameter("orderCode"); // PayOS returns numeric
        if (ocNumeric == null || ocNumeric.isBlank()) {
            resp.sendError(400, "Missing orderCode");
            return;
        }

        String displayCode = "ORD" + ocNumeric;

        try {
            int orderId = orderDAO.getOrderIdByCode(displayCode);
            if (orderId > 0) {
                ticketDAO.releaseHeldSeats(orderId);        // delete HOLD
            }
            orderDAO.markCancelledByCode(displayCode);

            req.setAttribute("orderCode", displayCode);
            req.getRequestDispatcher("/views/users/checkout-cancel.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Cannot cancel transaction.");
            req.getRequestDispatcher("/error.jsp").forward(req, resp);
        }
    }
}
