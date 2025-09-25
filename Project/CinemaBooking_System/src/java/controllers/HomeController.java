package controllers;

import dals.MovieDAO;
import models.Movie;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "HomeController", urlPatterns = {"/home"})
public class HomeController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        MovieDAO dao = new MovieDAO();

        // Lấy dữ liệu từ DAO
        List<Movie> listNowShowing = dao.getNowShowingMovies();
        List<Movie> listComingSoon = dao.getComingSoonMovies();

        // Đẩy dữ liệu sang JSP
        request.setAttribute("listmovie", listNowShowing);
        request.setAttribute("listmovie1", listComingSoon);

        // Forward sang homepage.jsp
        request.getRequestDispatcher("/views/users/homepage.jsp").forward(request, response);
    }
}
