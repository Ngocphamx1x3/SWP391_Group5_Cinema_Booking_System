package dal;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.Movie;
import model.MovieType;
import util.DBContext;

public class MovieDAO extends DBContext {

    public List<Movie> getNowShowingMovies() {
        List<Movie> list = new ArrayList<>();
        String sql = "SELECT * FROM Movie WHERE Status = N'Đang chiếu'";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
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
                m.setMovieTypes(getMovieTypesByMovieId(m.getId()));

                list.add(m);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Movie> getComingSoonMovies() {
        List<Movie> list = new ArrayList<>();
        String sql = "SELECT * FROM Movie WHERE Status = N'Sắp chiếu'";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
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
                m.setMovieTypes(getMovieTypesByMovieId(m.getId()));

                list.add(m);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private List<MovieType> getMovieTypesByMovieId(int movieId) {
        List<MovieType> list = new ArrayList<>();
        String sql = "SELECT mt.Id, mt.Code, mt.Name " +
                     "FROM MovieType mt " +
                     "JOIN Movie_MovieType mmt ON mt.Id = mmt.MovieTypeId " +
                     "WHERE mmt.MovieId = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, movieId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                MovieType mt = new MovieType(
                        rs.getInt("Id"),
                        rs.getString("Code"),
                        rs.getString("Name")
                );
                list.add(mt);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
