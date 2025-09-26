package controller;

import dal.MovieDAO;
import model.Movie;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet(name = "MovieDetailController", urlPatterns = {"/detail"})
public class MovieDetailController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing movie id");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            MovieDAO dao = new MovieDAO();
            Movie movie = dao.getMovieById(id);

            if (movie == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Movie not found");
                return;
            }

            request.setAttribute("movie", movie);
            request.getRequestDispatcher("/views/users/detail.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid movie id");
        }
    }
}
