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
import model.VoucherMovie;

public class MovieDAO extends DBContext {

    // lay phim
    public List<Movie> getAllMovies() {
        List<Movie> list = new ArrayList<>();
        String sql = "SELECT * FROM Movie";
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

    // lay phim theo id
    public Movie getMovieById(int id) {
        String sql = "SELECT * FROM Movie WHERE Id = ?";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
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

    public void addMovie(Movie m) {
        String sql = "INSERT INTO Movie (Code, Name, Description, Image, Trailer, MovieDuration, PremiereDate, EndDate, Status, RatedId) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, m.getCode());
            ps.setString(2, m.getName());
            ps.setString(3, m.getDescription());
            ps.setString(4, m.getImage());
            ps.setString(5, m.getTrailer());
            ps.setInt(6, m.getMovieDuration());
            ps.setDate(7, new java.sql.Date(m.getPremiereDate().getTime()));

            if (m.getEndDate() != null) {
                ps.setDate(8, new java.sql.Date(m.getEndDate().getTime()));
            } else {
                ps.setNull(8, java.sql.Types.DATE);
            }

            ps.setString(9, m.getStatus());
            ps.setInt(10, m.getRatedId());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

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

    public void deleteMovie(int id) {
        String sql = "UPDATE Movie SET Status = N'Ngưng hoạt động' WHERE Id = ?";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<Movie> getNowShowingMovies() {
        return getMoviesByStatus("Đang chiếu");
    }

    public List<Movie> getComingSoonMovies() {
        return getMoviesByStatus("Sắp chiếu");
    }

    public List<Movie> getUpcomingMovies() {
        return getComingSoonMovies();
    }

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
        String sql = "SELECT d.* FROM Director d "
                + "JOIN Movie_Director md ON d.Id = md.DirectorId "
                + "WHERE md.MovieId = ?";
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
        String sql = "SELECT p.* FROM Performer p "
                + "JOIN Movie_Performer mp ON p.Id = mp.PerformerId "
                + "WHERE mp.MovieId = ?";
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
        String sql = "SELECT mt.* FROM MovieType mt "
                + "JOIN Movie_MovieType mmt ON mt.Id = mmt.MovieTypeId "
                + "WHERE mmt.MovieId = ?";
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
        String sql = "SELECT l.* FROM Language l "
                + "JOIN Movie_Language ml ON l.Id = ml.LanguageId "
                + "WHERE ml.MovieId = ?";
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

    public List<Movie> searchMovies(String movieName, String startDate, String endDate) {
        List<Movie> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM Movie WHERE (Status IS NULL OR Status != N'Ngưng hoạt động')");
        List<Object> parameters = new ArrayList<>();

        if (movieName != null && !movieName.trim().isEmpty()) {
            sql.append(" AND Name LIKE ?");
            parameters.add("%" + movieName.trim() + "%");
        }

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

    public boolean hasVoucher(int movieId) {
        String sql = "SELECT COUNT(*) FROM VoucherMovie WHERE MovieId = ?";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, movieId);
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

    public List<VoucherMovie> getVouchersByMovieId(int movieId) {
        List<VoucherMovie> vouchers = new ArrayList<>();
        String sql = "SELECT * FROM VoucherMovie WHERE MovieId = ?";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, movieId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    VoucherMovie voucher = new VoucherMovie();
                    voucher.setId(rs.getInt("Id"));
                    voucher.setVoucherId(rs.getInt("VoucherId"));
                    voucher.setMovieId(rs.getInt("MovieId"));
                    // Thêm các trường khác nếu có
                    vouchers.add(voucher);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return vouchers;
    }
}



