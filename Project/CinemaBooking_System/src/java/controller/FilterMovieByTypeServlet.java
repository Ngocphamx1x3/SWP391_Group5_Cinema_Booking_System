package controller;

import dal.MovieDAO;
import model.Movie;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet(name = "FilterMovieByTypeServlet", urlPatterns = {"/filterMovieByType"})
public class FilterMovieByTypeServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        String typeIdStr = request.getParameter("typeId");
        String status = request.getParameter("status");
        
        MovieDAO dao = new MovieDAO();
        List<Movie> movies;
        
        // If typeId is empty, get all movies by status
        if (typeIdStr == null || typeIdStr.isEmpty()) {
            movies = dao.getMovieListByStatus(status);
        } else {
            int typeId = Integer.parseInt(typeIdStr);
            movies = dao.filterMoviesByTypeAndStatus(typeId, status);
        }
        
        // Check if user is logged in
        Object customer = request.getSession().getAttribute("customer");
        boolean isLoggedIn = (customer != null);
        
        // Generate HTML for filtered movies
        for (Movie movie : movies) {
            out.println("<figure class='snip1208'>");
            out.println("    <img src='" + request.getContextPath() + "/assets/admin/img/img/" + movie.getImage() + "' style='width: 100%; height: 459px'>");
            out.println("    <div class='date'>");
            out.println("        <span class='day'>" + movie.getRatedId() + "</span>");
            out.println("        <span class='month'>Trailer</span>");
            out.println("    </div>");
            out.println("    <i class='myBtn' data-toggle='modal' data-target='#modal" + movie.getId() + "'>Xem trailer</i>");
            out.println("    <figcaption>");
            out.println("        <h3>");
            out.println("            <a href='" + request.getContextPath() + "/detail?id=" + movie.getId() + "'>" + movie.getName() + "</a>");
            out.println("        </h3>");
            out.println("        <p>");
            out.println("            - Thể loại: ");
            
            // Display movie types
            List<model.MovieType> types = movie.getMovieTypes();
            for (int i = 0; i < types.size(); i++) {
                out.print(types.get(i).getName());
                if (i < types.size() - 1) out.print(", ");
            }
            
            out.println("            <br>- Thời lượng: " + movie.getMovieDuration() + " phút");
            out.println("            <br>- Ngày khởi chiếu: " + movie.getPremiereDate());
            out.println("        </p>");
            
            // Display appropriate button based on login status
            if (!isLoggedIn) {
                out.println("        <button data-toggle='modal' data-target='#myModalll'>Đặt vé</button>");
            } else if ("Đang chiếu".equals(status)) {
                out.println("        <button><a href='show/cinema?movieId=" + movie.getId() + "'>Mua Vé</a></button>");
            }
            
            out.println("    </figcaption>");
            out.println("</figure>");
            
            // Modal for trailer
            out.println("<div id='modal" + movie.getId() + "' class='modal'>");
            out.println("    <div class='modal-content'>");
            out.println("        <span class='close' data-dismiss='modal'>&times;</span>");
            out.println("        <h2>TRAILER - " + movie.getName() + "</h2>");
            out.println("        <hr style='margin-top: 20px; opacity: 0.5'>");
            out.println("        <div class='embed-responsive embed-responsive-16by9 video'>");
            out.println("            <iframe width='80%' height='315' src='" + movie.getTrailer() + "'");
            out.println("                    title='YouTube video player' frameborder='0'");
            out.println("                    allow='accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture'");
            out.println("                    allowfullscreen></iframe>");
            out.println("        </div>");
            out.println("    </div>");
            out.println("</div>");
        }
        
        // If no movies found
        if (movies.isEmpty()) {
            out.println("<div style='text-align: center; padding: 50px; width: 100%;'>");
            out.println("    <h3>Không tìm thấy phim phù hợp</h3>");
            out.println("</div>");
        }
    }
}