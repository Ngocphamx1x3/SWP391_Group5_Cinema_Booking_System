package controller;

import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet(name = "VerifyController", urlPatterns = {"/verify"})
public class VerifyController extends HttpServlet {
    
    private UserDAO userDao;
    
    @Override
    public void init() {
        userDao = new UserDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        
        String email = req.getParameter("email");
        String code = req.getParameter("code");
        
        // Validate input
        if (email == null || email.trim().isEmpty() || 
            code == null || code.trim().isEmpty()) {
            req.setAttribute("error", "Thông tin xác thực không hợp lệ");
            req.setAttribute("errorType", "INVALID_REQUEST");
            req.getRequestDispatcher("/views/users/verify_result.jsp").forward(req, resp);
            return;
        }
        
        try {
            // Trim input để tránh lỗi do khoảng trắng
            email = email.trim();
            code = code.trim();
            
            boolean isVerified = userDao.verifyCode(email, code);
            
            if (isVerified) {
                // Xác thực thành công
                req.setAttribute("success", true);
                req.setAttribute("message", "🎉 Xác thực email thành công!");
                req.setAttribute("subMessage", "Bạn có thể đăng nhập vào hệ thống ngay bây giờ.");
                req.setAttribute("redirectUrl", req.getContextPath() + "/login");
                
                // Optional: Tự động redirect sau 3 giây
                req.setAttribute("autoRedirect", true);
                
            } else {
                // Xác thực thất bại
                req.setAttribute("error", " Xác thực thất bại!");
                req.setAttribute("errorType", "INVALID_CODE");
                req.setAttribute("subMessage", "Mã xác thực không đúng hoặc đã hết hạn. Vui lòng thử lại hoặc đăng ký lại.");
                req.setAttribute("retryUrl", req.getContextPath() + "/register");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", " Lỗi hệ thống!");
            req.setAttribute("errorType", "SERVER_ERROR");
            req.setAttribute("subMessage", "Đã xảy ra lỗi khi xác thực. Vui lòng thử lại sau.");
            req.setAttribute("errorDetail", e.getMessage());
        }
        
        req.getRequestDispatcher("/views/users/verify_result.jsp").forward(req, resp);
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        // Hỗ trợ cả POST request (nếu user submit form)
        doGet(req, resp);
    }
}