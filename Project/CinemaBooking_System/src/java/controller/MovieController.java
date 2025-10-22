package controller;

import dal.MovieDAO;
import model.Movie;
import model.Director;
import model.Language;

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
                case "addForm":
                    showAddForm(request, response);
                    break;
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
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Lỗi khi xử lý yêu cầu: " + e.getMessage());
        }
    }

    // =============== HIỂN THỊ FORM THÊM PHIM ===============
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

    // ======================= DANH SÁCH PHIM =======================
    private void listMovies(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Movie> list = movieDAO.getAllMovies(); // chỉ lấy phim chưa ngưng hoạt động
        request.setAttribute("movieList", list);
        RequestDispatcher rd = request.getRequestDispatcher("/views/admin/movieManager.jsp");
        rd.forward(request, response);
    }

    // ======================= THÊM PHIM =======================
    private void insertMovie(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        Movie m = new Movie();

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

    // ======================= XÓA PHIM (chuyển sang “Ngưng hoạt động”) =======================
    private void deleteMovie(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int id = Integer.parseInt(request.getParameter("id"));
        movieDAO.deleteMovie(id); // đổi tên hàm cho dễ hiểu
        response.sendRedirect(request.getContextPath() + "/admin/movies");
    }

    // ======================= FORM CHỈNH SỬA =======================
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

    // ======================= THÊM ĐẠO DIỄN MỚI =======================
    private void addDirector(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String directorName = request.getParameter("directorName");
            String directorCode = request.getParameter("directorCode");

            // Validation
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

            // Kiểm tra đạo diễn đã tồn tại
            if (movieDAO.isDirectorExists(directorName)) {
                request.setAttribute("error", "Đạo diễn '" + directorName + "' đã tồn tại");
                showAddForm(request, response);
                return;
            }

            // Tạo đạo diễn mới
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

    // ======================= THÊM NGÔN NGỮ MỚI =======================
    private void addLanguage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String languageName = request.getParameter("languageName");
            String languageCode = request.getParameter("languageCode");

            // Validation
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

            // Kiểm tra ngôn ngữ đã tồn tại
            if (movieDAO.isLanguageExists(languageName)) {
                request.setAttribute("error", "Ngôn ngữ '" + languageName + "' đã tồn tại");
                showAddForm(request, response);
                return;
            }

            // Tạo ngôn ngữ mới
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