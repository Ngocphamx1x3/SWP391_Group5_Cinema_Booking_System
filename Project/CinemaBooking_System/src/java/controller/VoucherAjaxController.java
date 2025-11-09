package controller;

import dal.VoucherDAO;
import model.Voucher;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "VoucherAjaxController", urlPatterns = {"/voucher-ajax"})
public class VoucherAjaxController extends HttpServlet {

    private VoucherDAO voucherDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        this.voucherDAO = new VoucherDAO();
    }

    @Override
protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

    // SET UTF-8 ENCODING
    response.setContentType("text/html;charset=UTF-8");
    request.setCharacterEncoding("UTF-8");
    
    String movieIdStr = request.getParameter("movieId");
    String totalAmountStr = request.getParameter("totalAmount");

    System.out.println("🎫 ===== VOUCHER AJAX CALLED =====");
    System.out.println("🔍 movieId: " + movieIdStr);
    System.out.println("🔍 totalAmount: " + totalAmountStr);
    System.out.println("🔍 Full URL: " + request.getRequestURL() + "?" + request.getQueryString());

    if (movieIdStr == null || movieIdStr.trim().isEmpty()) {
        System.out.println("❌ ERROR: Missing movieId parameter");
        response.getWriter().write("<div class='no-vouchers'>Lỗi: Thiếu thông tin phim</div>");
        return;
    }

    try {
        int movieId = Integer.parseInt(movieIdStr.trim());
        double totalAmount = 0;
        
        if (totalAmountStr != null && !totalAmountStr.trim().isEmpty()) {
            totalAmount = Double.parseDouble(totalAmountStr.trim());
        }

        System.out.println("🔍 Parsed - movieId: " + movieId + ", totalAmount: " + totalAmount);

        // Lấy danh sách voucher
        List<Voucher> vouchers = voucherDAO.getActiveVouchersByMovieId(movieId);
        System.out.println("📊 Database returned " + vouchers.size() + " vouchers");

        // Lọc theo điều kiện đơn hàng tối thiểu
        List<Voucher> applicableVouchers = new ArrayList<>();
        for (Voucher voucher : vouchers) {
            System.out.println("🔍 Checking voucher: " + voucher.getCode() + " - Min: " + voucher.getMinOrderAmount());
            if (totalAmount >= voucher.getMinOrderAmount()) {
                applicableVouchers.add(voucher);
                System.out.println("✅ Voucher applicable: " + voucher.getCode());
            } else {
                System.out.println("❌ Voucher NOT applicable: " + voucher.getCode() + " - Required: " + voucher.getMinOrderAmount() + " - Current: " + totalAmount);
            }
        }

        System.out.println("🎯 Final applicable vouchers: " + applicableVouchers.size());

        request.setAttribute("vouchers", applicableVouchers);
        request.setAttribute("totalAmount", totalAmount);
        
        // Forward đến JSP
        RequestDispatcher dispatcher = request.getRequestDispatcher("/views/users/voucher-list.jsp");
        if (dispatcher != null) {
            dispatcher.forward(request, response);
            System.out.println("✅ Successfully forwarded to voucher-list.jsp");
        } else {
            System.out.println("❌ ERROR: Could not find voucher-list.jsp");
            response.getWriter().write("<div class='no-vouchers'>Lỗi: Không tìm thấy template</div>");
        }

    } catch (NumberFormatException e) {
        System.out.println("❌ ERROR: Invalid movieId format: " + movieIdStr);
        e.printStackTrace();
        response.getWriter().write("<div class='no-vouchers'>Lỗi: ID phim không hợp lệ</div>");
    } catch (Exception e) {
        System.out.println("❌ ERROR: " + e.getMessage());
        e.printStackTrace();
        response.getWriter().write("<div class='no-vouchers'>Lỗi server: " + e.getMessage() + "</div>");
    }
}
}