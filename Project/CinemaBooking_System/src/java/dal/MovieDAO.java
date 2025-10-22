package dal;

import model.Movie;
import model.Director;
import model.Language;
import model.MovieType;
import util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MovieDAO extends DBContext {

    // ✅ Lấy tất cả phim (trừ phim đã ngưng hoạt động)
    public List<Movie> getAllMovies() {
        List<Movie> list = new ArrayList<>();
        String sql = "SELECT * FROM Movie WHERE Status IS NULL OR Status != N'Ngưng hoạt động'";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Movie m = new Movie();
                m.setId(rs.getInt("Id"));
                m.setName(rs.getString("Name"));
                m.setMovieDuration(rs.getInt("MovieDuration"));
                m.setPremiereDate(rs.getDate("PremiereDate"));
                m.setStatus(rs.getString("Status"));
                m.setImage(rs.getString("Image"));
                m.setDescription(rs.getString("Description"));
                list.add(m);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ✅ Lấy phim theo ID
    public Movie getMovieById(int id) {
        String sql = "SELECT * FROM Movie WHERE Id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Movie m = new Movie();
                    m.setId(rs.getInt("Id"));
                    m.setName(rs.getString("Name"));
                    m.setMovieDuration(rs.getInt("MovieDuration"));
                    m.setPremiereDate(rs.getDate("PremiereDate"));
                    m.setStatus(rs.getString("Status"));
                    m.setImage(rs.getString("Image"));
                    m.setDescription(rs.getString("Description"));
                    return m;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // ✅ Thêm phim mới (đơn giản)
    public void addMovie(Movie m) {
        String sql = "INSERT INTO Movie (Name, MovieDuration, PremiereDate, Status, Image, Description) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, m.getName());
            ps.setInt(2, m.getMovieDuration());
            ps.setDate(3, new java.sql.Date(m.getPremiereDate().getTime()));
            ps.setString(4, m.getStatus());
            ps.setString(5, m.getImage());
            ps.setString(6, m.getDescription());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ✅ Cập nhật phim
    public void updateMovie(Movie m) {
        String sql = "UPDATE Movie SET Name=?, MovieDuration=?, PremiereDate=?, Status=?, Image=?, Description=? WHERE Id=?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, m.getName());
            ps.setInt(2, m.getMovieDuration());
            ps.setDate(3, new java.sql.Date(m.getPremiereDate().getTime()));
            ps.setString(4, m.getStatus());
            ps.setString(5, m.getImage());
            ps.setString(6, m.getDescription());
            ps.setInt(7, m.getId());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ✅ Xóa mềm (soft delete)
    public void deleteMovie(int id) {
        String sql = "UPDATE Movie SET Status = N'Ngưng hoạt động' WHERE Id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ✅ Lấy phim đang chiếu
    public List<Movie> getNowShowingMovies() {
        return getMoviesByStatus("Đang chiếu");
    }

    // ✅ Lấy phim sắp chiếu
    public List<Movie> getComingSoonMovies() {
        return getMoviesByStatus("Sắp chiếu");
    }

    // ✅ Hàm phụ chung để tránh lặp code
    private List<Movie> getMoviesByStatus(String status) {
        List<Movie> list = new ArrayList<>();
        String sql = "SELECT * FROM Movie WHERE Status = N'" + status + "'";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Movie m = new Movie();
                m.setId(rs.getInt("Id"));
                m.setName(rs.getString("Name"));
                m.setMovieDuration(rs.getInt("MovieDuration"));
                m.setPremiereDate(rs.getDate("PremiereDate"));
                m.setStatus(rs.getString("Status"));
                m.setImage(rs.getString("Image"));
                m.setDescription(rs.getString("Description"));
                list.add(m);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ✅ Lấy danh sách đạo diễn
    public List<Director> getAllDirectors() {
        List<Director> list = new ArrayList<>();
        String sql = "SELECT * FROM Director";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new Director(rs.getInt("Id"), rs.getString("Code"), rs.getString("Name")));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ✅ Lấy danh sách ngôn ngữ
    public List<Language> getAllLanguages() {
        List<Language> list = new ArrayList<>();
        String sql = "SELECT * FROM Language";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new Language(rs.getInt("Id"), rs.getString("Code"), rs.getString("Name")));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ✅ Lấy danh sách thể loại
    public List<MovieType> getAllMovieTypes() {
        List<MovieType> list = new ArrayList<>();
        String sql = "SELECT * FROM MovieType";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new MovieType(rs.getInt("Id"), rs.getString("Code"), rs.getString("Name")));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ✅ Thêm phim + quan hệ (đạo diễn, ngôn ngữ, thể loại)
    public void addMovieWithRelations(Movie m, String[] directorIds, String[] languageIds, String[] movieTypeIds) {
        String insertMovie = "INSERT INTO Movie (Code, Name, Description, Image, Trailer, MovieDuration, PremiereDate, Status, RatedId) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        String insertDirector = "INSERT INTO Movie_Director (MovieId, DirectorId) VALUES (?, ?)";
        String insertLanguage = "INSERT INTO Movie_Language (MovieId, LanguageId) VALUES (?, ?)";
        String insertType = "INSERT INTO Movie_MovieType (MovieId, MovieTypeId) VALUES (?, ?)";

        try (Connection con = getConnection()) {
            con.setAutoCommit(false);

            try (PreparedStatement ps = con.prepareStatement(insertMovie, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, m.getCode());
                ps.setString(2, m.getName());
                ps.setString(3, m.getDescription());
                ps.setString(4, m.getImage());
                ps.setString(5, m.getTrailer());
                ps.setInt(6, m.getMovieDuration());
                ps.setDate(7, new java.sql.Date(m.getPremiereDate().getTime()));
                ps.setString(8, m.getStatus());
                ps.setInt(9, m.getRatedId());
                ps.executeUpdate();

                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        int movieId = rs.getInt(1);

                        insertRelations(con, insertDirector, movieId, directorIds);
                        insertRelations(con, insertLanguage, movieId, languageIds);
                        insertRelations(con, insertType, movieId, movieTypeIds);
                    }
                }
            }

            con.commit();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ✅ Hàm phụ dùng chung để thêm batch quan hệ
    private void insertRelations(Connection con, String sql, int movieId, String[] ids) throws SQLException {
        if (ids == null) return;
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            for (String id : ids) {
               ps.setInt(1, movieId);
                ps.setInt(2, Integer.parseInt(id));
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }
}
