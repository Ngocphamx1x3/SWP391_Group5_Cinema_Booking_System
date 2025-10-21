package controller;

import dal.MovieDAO;
import model.Movie;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.List;

@WebServlet(urlPatterns = {"/admin/movies"})
public class MovieController extends HttpServlet {

    private MovieDAO movieDAO;

    @Override
    public void init() throws ServletException {
        movieDAO = new MovieDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        try {
            if (action == null) {
                listMovies(request, response);
                return;
            }

            switch (action) {
                case "delete":
                    deleteMovie(request, response);
                    break;
                case "edit":
                    showEditForm(request, response);
                    break;
                default:
                    listMovies(request, response);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi khi xử lý yêu cầu: " + e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        try {
            if (action == null) {
                listMovies(request, response);
                return;
            }

            switch (action) {
                case "add":
                    insertMovie(request, response);
                    break;
                case "update":
                    updateMovie(request, response);
                    break;
                default:
                    listMovies(request, response);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi khi xử lý yêu cầu POST: " + e.getMessage());
        }
    }

    // ======================= DANH SÁCH PHIM =======================
    private void listMovies(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Movie> list = movieDAO.getAllMovies();
        request.setAttribute("movieList", list);
        RequestDispatcher rd = request.getRequestDispatcher("/views/admin/movieManager.jsp");
        rd.forward(request, response);
    }

    // ======================= THÊM PHIM =======================
    private void insertMovie(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        Movie m = new Movie();

        // Tự sinh code phim (dạng mv12345)
        m.setCode("mv" + (int) (Math.random() * 100000));
        m.setName(request.getParameter("movieTitle"));
        m.setDescription(request.getParameter("movieDescription"));
        m.setImage(request.getParameter("posterUrl"));
        m.setTrailer(null);
        m.setMovieDuration(Integer.parseInt(request.getParameter("movieDuration")));
        m.setPremiereDate(sdf.parse(request.getParameter("releaseDate")));
        m.setStatus(request.getParameter("movieStatus"));
        m.setRatedId(1);

        movieDAO.addMovie(m);

        response.sendRedirect(request.getContextPath() + "/admin/movies");
    }

    // ======================= CẬP NHẬT PHIM =======================
    private void updateMovie(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        Movie m = new Movie();

        m.setId(Integer.parseInt(request.getParameter("id")));
        m.setName(request.getParameter("movieTitle"));
        m.setDescription(request.getParameter("movieDescription"));
        m.setImage(request.getParameter("posterUrl"));
        m.setMovieDuration(Integer.parseInt(request.getParameter("movieDuration")));
        m.setPremiereDate(sdf.parse(request.getParameter("releaseDate")));
        m.setStatus(request.getParameter("movieStatus"));

        movieDAO.updateMovie(m);
        response.sendRedirect(request.getContextPath() + "/admin/movies");
    }

    // ======================= XÓA PHIM =======================
    private void deleteMovie(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int id = Integer.parseInt(request.getParameter("id"));
        movieDAO.deleteMovie(id);
        response.sendRedirect(request.getContextPath() + "/admin/movies");
    }

    // ======================= FORM CHỈNH SỬA =======================
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id = Integer.parseInt(request.getParameter("id"));
        Movie movie = movieDAO.getMovieById(id);

        if (movie == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy phim có ID = " + id);
            return;
        }

        request.setAttribute("movie", movie);
        RequestDispatcher rd = request.getRequestDispatcher("/views/admin/movieForm.jsp");
        rd.forward(request, response);
    }
}
