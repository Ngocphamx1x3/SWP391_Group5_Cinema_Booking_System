package controller;

import dal.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Order;
import model.Users;
import java.io.IOException;
import java.util.List;

@WebServlet("/orderHistory")
public class OrderHistoryController extends HttpServlet {

    private OrderDAO orderDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        this.orderDAO = new OrderDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Users user = (Users) session.getAttribute("account");

        // Check if user is logged in
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            System.out.println("Fetching order history for userId: " + user.getId());

            // Get order history for the logged-in user only
            List<Order> orders = orderDAO.getOrderHistoryByUserId(user.getId());

            System.out.println("Total orders found: " + orders.size());

            // Load combo items and tickets for each order
            for (Order order : orders) {
                System.out.println("Loading details for order: " + order.getOrderCode());

                // Load combos - cho tất cả đơn hàng
                order.setOrderCombos(orderDAO.getOrderCombosByOrderId(order.getId()));

                // Load tickets - cho tất cả đơn hàng
                order.setTickets(orderDAO.getTicketInfoByOrderId(order.getId()));
            }

            request.setAttribute("orders", orders);
            request.setAttribute("totalOrders", orders.size());

            // Forward to order history page
            request.getRequestDispatcher("/views/users/orderHistory.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("Error in OrderHistoryController: " + e.getMessage());
            request.setAttribute("error", "Lỗi khi tải lịch sử đơn hàng. Vui lòng thử lại sau.");
            request.getRequestDispatcher("/views/users/orderHistory.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
