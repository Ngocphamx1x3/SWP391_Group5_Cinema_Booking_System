package controller;

import dal.MovieDAO;
import model.Movie;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "HomeController", urlPatterns = {"/home"})
public class HomeController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        MovieDAO dao = new MovieDAO();

        List<Movie> listNowShowing = dao.getNowShowingMovies();
        List<Movie> listComingSoon = dao.getComingSoonMovies();
        
        // Kiểm tra voucher cho từng phim
        Map<Integer, Boolean> movieVoucherStatus = new HashMap<>();
        for (Movie movie : listNowShowing) {
            boolean hasVoucher = dao.hasVoucher(movie.getId());
            movieVoucherStatus.put(movie.getId(), hasVoucher);
        }
        for (Movie movie : listComingSoon) {
            boolean hasVoucher = dao.hasVoucher(movie.getId());
            movieVoucherStatus.put(movie.getId(), hasVoucher);
        }
        
        request.setAttribute("listmovie", listNowShowing);
        request.setAttribute("listmovie1", listComingSoon);
        request.setAttribute("movieVoucherStatus", movieVoucherStatus);

        request.getRequestDispatcher("/views/users/homepage.jsp").forward(request, response);
    }
}