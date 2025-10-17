package controller;

import com.google.gson.Gson;
import dal.MovieDAO;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.Movie;

@WebServlet(name = "SearchMovieAjaxServlet", urlPatterns = {"/searchMovieAjax"})
public class SearchMovieAjaxServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Set UTF-8 encoding
        response.setContentType("application/json;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        // Get query parameter
        String query = request.getParameter("query");
        
        if (query == null || query.trim().isEmpty()) {
            response.getWriter().print("[]");
            return;
        }
        
        try {
            // Search movies
            MovieDAO dao = new MovieDAO();
            List<Movie> movieList = dao.searchMovies(query.trim());
            
            // Debug log
            System.out.println("========== SEARCH ==========");
            System.out.println("Query: " + query);
            System.out.println("Found: " + movieList.size() + " movies");
            for (Movie m : movieList) {
                System.out.println("  - " + m.getName() + " | Image: " + m.getImage());
            }
            System.out.println("============================");
            
            // Convert to JSON
            Gson gson = new Gson();
            String json = gson.toJson(movieList);
            
            // Send response
            response.getWriter().print(json);
            response.getWriter().flush();
            
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().print("[]");
        }
    }
}