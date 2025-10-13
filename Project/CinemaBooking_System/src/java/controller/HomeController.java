package controller;

import dal.MovieDAO;
import model.Movie;

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

        List<Movie> listNowShowing = dao.getNowShowingMovies();
        List<Movie> listComingSoon = dao.getComingSoonMovies();

        request.setAttribute("listmovie", listNowShowing);
        request.setAttribute("listmovie1", listComingSoon);

        request.getRequestDispatcher("/views/users/homepage.jsp").forward(request, response);
    }
}
