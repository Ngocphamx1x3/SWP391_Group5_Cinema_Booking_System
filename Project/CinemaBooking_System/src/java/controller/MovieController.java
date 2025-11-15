package controller;

import dal.MovieDAO;
import model.Movie;
import model.Director;
import model.Language;

import jakarta.servlet.*;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet(urlPatterns = {"/admin/movies"})
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2,
        maxFileSize = 1024 * 1024 * 10,
        maxRequestSize = 1024 * 1024 * 50)
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
                case "addForm":
                    showAddForm(request, response);
                    break;
                case "delete":
                    deleteMovie(request, response);
                    break;
                case "edit":
                    showEditForm(request, response);
                    break;
                case "search":
                    searchMovies(request, response);
                    break;
                default:
                    listMovies(request, response);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Lỗi khi xử lý yêu cầu: " + e.getMessage());
        }
    }

    // form them phim
    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute("directorList", movieDAO.getAllDirectors());
        request.setAttribute("languageList", movieDAO.getAllLanguages());
        request.setAttribute("movieTypeList", movieDAO.getAllMovieTypes());

        RequestDispatcher rd = request.getRequestDispatcher("/views/admin/addMovieForm.jsp");
        rd.forward(request, response);
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
                case "addDirector":
                    addDirector(request, response);
                    break;
                case "addLanguage":
                    addLanguage(request, response);
                    break;
                default:
                    listMovies(request, response);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Lỗi khi xử lý yêu cầu POST: " + e.getMessage());
        }
    }

    // chuan hoa
    private String normalizeMovieStatus(String status) {
        if (status == null) {
            return Movie.STATUS_SHOWING;
        }

        switch (status.trim().toLowerCase()) {
            case "đang chiếu":
            case "dang chieu":
            case "active":
                return Movie.STATUS_SHOWING;

            case "sắp chiếu":
            case "sap chieu":
            case "comingsoon":
                return Movie.STATUS_COMING_SOON;

            case "ngưng chiếu":
            case "ngung chieu":
            case "inactive":
            case "stopped":
                return Movie.STATUS_STOPPED;

            default:
                return Movie.STATUS_SHOWING;
        }
    }

    // gui du lieu phim
    private Movie buildMovieFromRequest(HttpServletRequest request, boolean isUpdate) throws Exception {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        Movie m = new Movie();

        if (isUpdate) {
            String idStr = getValueFromPart(request, "id");
            m.setId(Integer.parseInt(idStr));
        } else {
            m.setCode("mv" + (int) (Math.random() * 100000));
            m.setRatedId(1);
        }

        m.setName(getValueFromPart(request, "movieTitle"));
        m.setDescription(getValueFromPart(request, "movieDescription"));

        String trailer = getValueFromPart(request, "trailerUrl");
        m.setTrailer(trailer != null ? trailer : null);

        String imageUrl = getValueFromPart(request, "posterUrl");
        m.setImage(imageUrl);

        String endDateStr = request.getParameter("endDate");
        if (endDateStr != null && !endDateStr.isEmpty()) {
            m.setEndDate(sdf.parse(endDateStr));
        }

        String durationStr = getValueFromPart(request, "movieDuration");
        if (durationStr == null || durationStr.isEmpty()) {
            throw new IllegalArgumentException("Thời lượng phim không được để trống");
        }
        m.setMovieDuration(Integer.parseInt(durationStr));

        String releaseDateStr = getValueFromPart(request, "releaseDate");
        if (releaseDateStr == null || releaseDateStr.isEmpty()) {
            throw new IllegalArgumentException("Ngày khởi chiếu không được để trống");
        }
        m.setPremiereDate(sdf.parse(releaseDateStr));

        m.setStatus(normalizeMovieStatus(getValueFromPart(request, "movieStatus")));

        return m;
    }

    private String getValueFromPart(HttpServletRequest request, String fieldName) throws IOException, ServletException {
        Part part = request.getPart(fieldName);
        if (part == null) {
            return null;
        }
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(part.getInputStream(), "UTF-8"))) {
            return reader.lines().collect(Collectors.joining("\n"));
        }
    }

    // danh sach phim
    private void listMovies(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Movie> list = movieDAO.getAllMovies();
        request.setAttribute("movieList", list);
        RequestDispatcher rd = request.getRequestDispatcher("/views/admin/movieManager.jsp");
        rd.forward(request, response);
    }

    // tim kiem phim
    private void searchMovies(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String movieName = request.getParameter("searchName");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");

        List<Movie> list = movieDAO.searchMovies(movieName, startDate, endDate);
        request.setAttribute("movieList", list);

        request.setAttribute("searchName", movieName);
        request.setAttribute("startDate", startDate);
        request.setAttribute("endDate", endDate);

        RequestDispatcher rd = request.getRequestDispatcher("/views/admin/movieManager.jsp");
        rd.forward(request, response);
    }

    // them
    private void insertMovie(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        Movie m = buildMovieFromRequest(request, false);
        movieDAO.addMovie(m);
        response.sendRedirect(request.getContextPath() + "/admin/movies");
    }

    private void updateMovie(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        Movie m = buildMovieFromRequest(request, true);
        movieDAO.updateMovie(m);
        response.sendRedirect(request.getContextPath() + "/admin/movies");
    }

    private void deleteMovie(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int id = Integer.parseInt(request.getParameter("id"));
        movieDAO.deleteMovie(id);
        response.sendRedirect(request.getContextPath() + "/admin/movies");
    }

    // form sua phim
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id = Integer.parseInt(request.getParameter("id"));
        Movie movie = movieDAO.getMovieById(id);

        if (movie == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND,
                    "Không tìm thấy phim có ID = " + id);
            return;
        }

        request.setAttribute("movie", movie);
        RequestDispatcher rd = request.getRequestDispatcher("/views/admin/movieForm.jsp");
        rd.forward(request, response);
    }

    private void addDirector(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String directorName = request.getParameter("directorName");
            String directorCode = request.getParameter("directorCode");

            if (directorName == null || directorName.trim().isEmpty()) {
                request.setAttribute("error", "Tên đạo diễn không được để trống");
                showAddForm(request, response);
                return;
            }

            if (directorCode == null || directorCode.trim().isEmpty()) {
                request.setAttribute("error", "Mã đạo diễn không được để trống");
                showAddForm(request, response);
                return;
            }

            if (movieDAO.isDirectorExists(directorName)) {
                request.setAttribute("error", "Đạo diễn '" + directorName + "' đã tồn tại");
                showAddForm(request, response);
                return;
            }

            Director director = new Director();
            director.setCode(directorCode);
            director.setName(directorName);

            int directorId = movieDAO.addDirector(director);

            if (directorId > 0) {
                request.setAttribute("success", "Đạo diễn '" + directorName + "' đã được thêm thành công!");
                showAddForm(request, response);
            } else {
                request.setAttribute("error", "Lỗi khi thêm đạo diễn");
                showAddForm(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi khi xử lý: " + e.getMessage());
            showAddForm(request, response);
        }
    }

    private void addLanguage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String languageName = request.getParameter("languageName");
            String languageCode = request.getParameter("languageCode");

            if (languageName == null || languageName.trim().isEmpty()) {
                request.setAttribute("error", "Tên ngôn ngữ không được để trống");
                showAddForm(request, response);
                return;
            }

            if (languageCode == null || languageCode.trim().isEmpty()) {
                request.setAttribute("error", "Mã ngôn ngữ không được để trống");
                showAddForm(request, response);
                return;
            }

            if (movieDAO.isLanguageExists(languageName)) {
                request.setAttribute("error", "Ngôn ngữ '" + languageName + "' đã tồn tại");
                showAddForm(request, response);
                return;
            }

            Language language = new Language();
            language.setCode(languageCode);
            language.setName(languageName);

            int languageId = movieDAO.addLanguage(language);

            if (languageId > 0) {
                request.setAttribute("success", "Ngôn ngữ '" + languageName + "' đã được thêm thành công!");
                showAddForm(request, response);
            } else {
                request.setAttribute("error", "Lỗi khi thêm ngôn ngữ");
                showAddForm(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi khi xử lý: " + e.getMessage());
            showAddForm(request, response);
        }
    }
}



