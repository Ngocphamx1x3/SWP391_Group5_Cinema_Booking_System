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
}
