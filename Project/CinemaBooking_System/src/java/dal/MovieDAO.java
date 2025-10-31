package dal;

import model.Movie;
import model.Director;
import model.Language;
import model.MovieType;
import util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.Performer;

public class MovieDAO extends DBContext {

    // ✅ Lấy tất cả phim (trừ phim đã ngưng hoạt động)
    public List<Movie> getAllMovies() {
        List<Movie> list = new ArrayList<>();
        String sql = "SELECT * FROM Movie WHERE Status IS NULL OR Status != N'Ngưng hoạt động'";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

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
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Movie m = new Movie();
                    // Lấy các trường cơ bản từ bảng Movie
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
                    
                    // Lấy các danh sách từ bảng quan hệ
                    int movieId = m.getId();
                    m.setDirectors(getDirectorsByMovieId(movieId)); 
                    m.setPerformers(getPerformersByMovieId(movieId)); 
                    m.setMovieTypes(getMovieTypesByMovieId(movieId)); 
                    m.setLanguages(getLanguagesByMovieId(movieId)); 
                    
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
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
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
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
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
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
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

    // ✅ Lấy phim sắp chiếu (alias for controller compatibility)
    public List<Movie> getUpcomingMovies() {
        return getComingSoonMovies();
    }

    // ✅ Hàm phụ chung để tránh lặp code
    private List<Movie> getMoviesByStatus(String status) {
        List<Movie> list = new ArrayList<>();
        String sql = "SELECT * FROM Movie WHERE Status = N'" + status + "'";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Movie m = new Movie();
                m.setId(rs.getInt("Id"));
                m.setName(rs.getString("Name"));
                m.setMovieDuration(rs.getInt("MovieDuration"));
                m.setPremiereDate(rs.getDate("PremiereDate"));
                m.setStatus(rs.getString("Status"));
                m.setImage(rs.getString("Image"));
                m.setDescription(rs.getString("Description"));
                m.setTrailer(rs.getString("Trailer"));
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
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
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
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
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
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
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
    public List<Director> getDirectorsByMovieId(int movieId) {
        List<Director> list = new ArrayList<>();
        String sql = "SELECT d.* FROM Director d " +
                     "JOIN Movie_Director md ON d.Id = md.DirectorId " +
                     "WHERE md.MovieId = ?";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, movieId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new Director(rs.getInt("Id"), rs.getString("Code"), rs.getString("Name")));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Performer> getPerformersByMovieId(int movieId) {
        List<Performer> list = new ArrayList<>();
        // Giả sử bảng của bạn tên là Performer và Movie_Performer
        String sql = "SELECT p.* FROM Performer p " +
                     "JOIN Movie_Performer mp ON p.Id = mp.PerformerId " +
                     "WHERE mp.MovieId = ?";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, movieId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    // Bạn cần có model Performer.java và constructor tương ứng
                    list.add(new Performer(rs.getInt("Id"), rs.getString("Code"), rs.getString("Name")));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<MovieType> getMovieTypesByMovieId(int movieId) {
        List<MovieType> list = new ArrayList<>();
        String sql = "SELECT mt.* FROM MovieType mt " +
                     "JOIN Movie_MovieType mmt ON mt.Id = mmt.MovieTypeId " +
                     "WHERE mmt.MovieId = ?";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, movieId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new MovieType(rs.getInt("Id"), rs.getString("Code"), rs.getString("Name")));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Language> getLanguagesByMovieId(int movieId) {
        List<Language> list = new ArrayList<>();
        String sql = "SELECT l.* FROM Language l " +
                     "JOIN Movie_Language ml ON l.Id = ml.LanguageId " +
                     "WHERE ml.MovieId = ?";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, movieId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new Language(rs.getInt("Id"), rs.getString("Code"), rs.getString("Name")));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    // ✅ Hàm phụ dùng chung để thêm batch quan hệ
    private void insertRelations(Connection con, String sql, int movieId, String[] ids) throws SQLException {
        if (ids == null) {
            return;
        }
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            for (String id : ids) {
                ps.setInt(1, movieId);
                ps.setInt(2, Integer.parseInt(id));
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    // ✅ Thêm đạo diễn mới
    public int addDirector(Director director) {
        String sql = "INSERT INTO Director (Code, Name) VALUES (?, ?)";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, director.getCode());
            ps.setString(2, director.getName());
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    // ✅ Kiểm tra đạo diễn đã tồn tại
    public boolean isDirectorExists(String name) {
        String sql = "SELECT COUNT(*) FROM Director WHERE Name = ?";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, name);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ✅ Thêm ngôn ngữ mới
    public int addLanguage(Language language) {
        String sql = "INSERT INTO Language (Code, Name) VALUES (?, ?)";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, language.getCode());
            ps.setString(2, language.getName());
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    // ✅ Kiểm tra ngôn ngữ đã tồn tại
    public boolean isLanguageExists(String name) {
        String sql = "SELECT COUNT(*) FROM Language WHERE Name = ?";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, name);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ✅ Tìm kiếm phim theo tên và khoảng thời gian
    public List<Movie> searchMovies(String movieName, String startDate, String endDate) {
        List<Movie> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM Movie WHERE (Status IS NULL OR Status != N'Ngưng hoạt động')");
        List<Object> parameters = new ArrayList<>();

        // Thêm điều kiện tìm kiếm theo tên phim
        if (movieName != null && !movieName.trim().isEmpty()) {
            sql.append(" AND Name LIKE ?");
            parameters.add("%" + movieName.trim() + "%");
        }

        // Thêm điều kiện tìm kiếm theo khoảng thời gian
        if (startDate != null && !startDate.trim().isEmpty()) {
            sql.append(" AND PremiereDate >= ?");
            parameters.add(java.sql.Date.valueOf(startDate));
        }

        if (endDate != null && !endDate.trim().isEmpty()) {
            sql.append(" AND PremiereDate <= ?");
            parameters.add(java.sql.Date.valueOf(endDate));
        }

        sql.append(" ORDER BY PremiereDate DESC");

        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql.toString())) {

            // Set parameters
            for (int i = 0; i < parameters.size(); i++) {
                ps.setObject(i + 1, parameters.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
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
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
