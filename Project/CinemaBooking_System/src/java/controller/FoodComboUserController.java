package controller;

import dal.FoodComboDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "FoodComboUserController", urlPatterns = {"/food-combo"})
public class FoodComboUserController extends HttpServlet {

    private FoodComboDAO foodComboDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        this.foodComboDAO = new FoodComboDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Load active food combos
        request.setAttribute("foodCombos", foodComboDAO.getActiveFoodCombos());
        
        // Forward to FoodCombo.jsp
        request.getRequestDispatcher("/views/users/FoodCombo.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}

