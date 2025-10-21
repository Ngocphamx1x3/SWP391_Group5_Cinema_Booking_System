package dal;

import model.Movie;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import util.DBContext;

public class MovieDAO extends DBContext {

    // Lấy tất cả phim
    public List<Movie> getAllMovies() {
        List<Movie> list = new ArrayList<>();
        String sql = "SELECT * FROM Movie";
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

    // Lấy phim theo ID
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

    // Thêm phim mới
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

    // Cập nhật phim
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

    // Xóa phim
    public void deleteMovie(int id) {
        String sql = "DELETE FROM Movie WHERE Id=?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    // Lấy danh sách phim đang chiếu
public List<Movie> getNowShowingMovies() {
    List<Movie> list = new ArrayList<>();
    String sql = "SELECT * FROM Movie WHERE Status = N'Đang chiếu'";
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

// Lấy danh sách phim sắp chiếu
public List<Movie> getComingSoonMovies() {
    List<Movie> list = new ArrayList<>();
    String sql = "SELECT * FROM Movie WHERE Status = N'Sắp chiếu'";
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

    
}
