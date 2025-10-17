package dal;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.Movie;
import model.MovieType;
import model.Director;
import model.Performer;
import model.Language;
import util.DBContext;

public class MovieDAO extends DBContext {

    // ----------------- DANH SÁCH PHIM -----------------
    public List<Movie> getNowShowingMovies() {
        String sql = "SELECT * FROM Movie WHERE Status = N'Đang chiếu'";
        return getMoviesByQuery(sql);
    }

    public List<Movie> getComingSoonMovies() {
        String sql = "SELECT * FROM Movie WHERE Status = N'Sắp chiếu'";
        return getMoviesByQuery(sql);
    }

    public List<Movie> getAllMovies() {
        String sql = "SELECT * FROM Movie";
        return getMoviesByQuery(sql);
    }

    // ----------------- CHI TIẾT PHIM -----------------
    public Movie getMovieById(int id) {
        String sql = "SELECT * FROM Movie WHERE Id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Movie m = mapMovie(rs);
                    // lấy thêm thông tin liên kết
                    m.setMovieTypes(getMovieTypesByMovieId(m.getId()));
                    m.setDirectors(getDirectorsByMovieId(m.getId()));
                    m.setPerformers(getPerformersByMovieId(m.getId()));
                    m.setLanguages(getLanguagesByMovieId(m.getId()));
                    return m;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // ----------------- HỖ TRỢ -----------------
    private List<Movie> getMoviesByQuery(String sql) {
        List<Movie> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Movie m = mapMovie(rs);
                m.setMovieTypes(getMovieTypesByMovieId(m.getId()));
                list.add(m);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private Movie mapMovie(ResultSet rs) throws SQLException {
        Movie m = new Movie();
        m.setId(rs.getInt("Id"));
        m.setCode(rs.getString("Code"));
        m.setName(rs.getString("Name"));
        m.setDescription(rs.getString("Description"));
        m.setImage(rs.getString("Image"));
        m.setTrailer(rs.getString("Trailer"));
        m.setMovieDuration(rs.getInt("MovieDuration"));
        m.setPremiereDate(rs.getDate("PremiereDate"));
        m.setEndDate(rs.getDate("EndDate"));
        m.setStatus(rs.getString("Status"));
        m.setRatedId(rs.getInt("RatedId"));
        return m;
    }

    // ----------------- LIÊN KẾT -----------------
    private List<MovieType> getMovieTypesByMovieId(int movieId) {
        List<MovieType> list = new ArrayList<>();
        String sql = "SELECT mt.Id, mt.Code, mt.Name "
                   + "FROM MovieType mt "
                   + "JOIN Movie_MovieType mmt ON mt.Id = mmt.MovieTypeId "
                   + "WHERE mmt.MovieId = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, movieId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new MovieType(
                        rs.getInt("Id"),
                        rs.getString("Code"),
                        rs.getString("Name")
                    ));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private List<Director> getDirectorsByMovieId(int movieId) {
        List<Director> list = new ArrayList<>();
        String sql = "SELECT d.Id, d.Code, d.Name "
                   + "FROM Director d "
                   + "JOIN Movie_Director md ON d.Id = md.DirectorId "
                   + "WHERE md.MovieId = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, movieId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new Director(
                        rs.getInt("Id"),
                        rs.getString("Code"),
                        rs.getString("Name")
                    ));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private List<Performer> getPerformersByMovieId(int movieId) {
        List<Performer> list = new ArrayList<>();
        String sql = "SELECT p.Id, p.Code, p.Name "
                   + "FROM Performer p "
                   + "JOIN Movie_Performer mp ON p.Id = mp.PerformerId "
                   + "WHERE mp.MovieId = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, movieId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new Performer(
                        rs.getInt("Id"),
                        rs.getString("Code"),
                        rs.getString("Name")
                    ));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private List<Language> getLanguagesByMovieId(int movieId) {
        List<Language> list = new ArrayList<>();
        String sql = "SELECT l.Id, l.Code, l.Name "
                   + "FROM Language l "
                   + "JOIN Movie_Language ml ON l.Id = ml.LanguageId "
                   + "WHERE ml.MovieId = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, movieId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new Language(
                        rs.getInt("Id"),
                        rs.getString("Code"),
                        rs.getString("Name")
                    ));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    // ----------------- SEARCH MOVIES -----------------
public List<Movie> searchMovies(String keyword) {
    List<Movie> list = new ArrayList<>();
    String sql = "SELECT * FROM Movie WHERE Name LIKE ?";

    try (Connection con = getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {

        ps.setString(1, "%" + keyword + "%");
        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            Movie m = new Movie();
            m.setId(rs.getInt("Id"));
            m.setName(rs.getString("Name"));
            m.setImage(rs.getString("Image")); // optional
            list.add(m);
        }

    } catch (Exception e) {
        e.printStackTrace();
    }

    return list;
}

// Thêm các method này vào class MovieDAO của bạn
// Chỉ thêm những method chưa có, nếu đã có thì sửa lại

// Method 1: Lấy phim theo status
public List<Movie> getMovieListByStatus(String status) {
    List<Movie> movies = new ArrayList<>();
    String sql = "SELECT * FROM Movie WHERE Status = ? ORDER BY PremiereDate DESC";
    
    try (Connection conn = getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, status);
        
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Movie movie = extractMovieFromResultSet(rs);
                // Load movie types for this movie
                movie.setMovieTypes(getMovieTypesForMovie(movie.getId()));
                movies.add(movie);
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    
    return movies;
}

// Method 2: Lọc phim theo thể loại và status
public List<Movie> filterMoviesByTypeAndStatus(int typeId, String status) {
    List<Movie> movies = new ArrayList<>();
    String sql = "SELECT DISTINCT m.* FROM Movie m " +
                 "INNER JOIN Movie_MovieType mmt ON m.Id = mmt.MovieId " +
                 "WHERE mmt.MovieTypeId = ? AND m.Status = ? " +
                 "ORDER BY m.PremiereDate DESC";
    
    try (Connection conn = getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, typeId);
        ps.setString(2, status);
        
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Movie movie = extractMovieFromResultSet(rs);
                // Load movie types for this movie
                movie.setMovieTypes(getMovieTypesForMovie(movie.getId()));
                movies.add(movie);
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    
    return movies;
}

// Method 3: Lấy danh sách thể loại của một phim cụ thể
public List<MovieType> getMovieTypesForMovie(int movieId) {
    List<MovieType> types = new ArrayList<>();
    String sql = "SELECT mt.* FROM MovieType mt " +
                 "INNER JOIN Movie_MovieType mmt ON mt.Id = mmt.MovieTypeId " +
                 "WHERE mmt.MovieId = ?";
    
    try (Connection conn = getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, movieId);
        
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                MovieType type = new MovieType();
                type.setId(rs.getInt("Id"));
                type.setCode(rs.getString("Code"));
                type.setName(rs.getString("Name"));
                types.add(type);
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    
    return types;
}

// Method 4: Lấy tất cả thể loại phim - KIỂM TRA xem đã có chưa
// Nếu đã có method getAllMovieTypes() thì KHÔNG cần thêm method này
public List<MovieType> getAllMovieTypes() {
    List<MovieType> types = new ArrayList<>();
    String sql = "SELECT * FROM MovieType ORDER BY Name";
    
    try (Connection conn = getConnection();
         PreparedStatement ps = conn.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {
        
        while (rs.next()) {
            MovieType type = new MovieType();
            type.setId(rs.getInt("Id"));
            type.setCode(rs.getString("Code"));
            type.setName(rs.getString("Name"));
            types.add(type);
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    
    return types;
}

// Helper method: Extract Movie object from ResultSet
// Tránh lặp code khi map ResultSet sang Movie object
private Movie extractMovieFromResultSet(ResultSet rs) throws SQLException {
    Movie movie = new Movie();
    movie.setId(rs.getInt("Id"));
    movie.setCode(rs.getString("Code"));
    movie.setName(rs.getString("Name"));
    movie.setDescription(rs.getString("Description"));
    movie.setImage(rs.getString("Image"));
    movie.setTrailer(rs.getString("Trailer"));
    movie.setMovieDuration(rs.getInt("MovieDuration"));
    movie.setPremiereDate(rs.getDate("PremiereDate"));
    movie.setEndDate(rs.getDate("EndDate"));
    movie.setStatus(rs.getString("Status"));
    movie.setRatedId(rs.getInt("RatedId"));
    return movie;
}
}
