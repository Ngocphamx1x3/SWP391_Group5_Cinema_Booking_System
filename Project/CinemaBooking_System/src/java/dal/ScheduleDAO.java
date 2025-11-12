package dal;

import model.Schedule;
import util.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ScheduleDAO extends DBContext {

    // ===== CRUD OPERATIONS =====
    // GET ALL SCHEDULES BY STAFF ID (QUAN TRỌNG)
    public List<Schedule> getSchedulesByStaff(int staffId) {
        List<Schedule> list = new ArrayList<>();
        String sql = "SELECT s.*, m.Name as movie_name, r.Name as room_name, "
                + "c.Name as cinema_name "
                + "FROM Schedule s "
                + "INNER JOIN Movie m ON s.MovieId = m.Id "
                + "INNER JOIN Room r ON s.RoomId = r.Id "
                + "INNER JOIN Cinema c ON r.CinemaId = c.Id "
                + "WHERE s.Staff_id = ? "
                + "ORDER BY s.StartAt DESC";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, staffId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Schedule schedule = mapResultSetToSchedule(rs);

                    // Thêm thông tin tên phim và phòng
                    schedule.setMovieName(rs.getString("movie_name"));
                    schedule.setRoomName(rs.getString("room_name"));
                    schedule.setCinemaName(rs.getString("cinema_name"));

                    list.add(schedule);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Lấy tất cả lịch chiếu (Admin)
    public List<Schedule> getAllSchedules() {
        List<Schedule> list = new ArrayList<>();
        String sql = "SELECT s.*, m.Name as movie_name, r.Name as room_name, c.Name as cinema_name "
                + "FROM Schedule s "
                + "INNER JOIN Movie m ON s.MovieId = m.Id "
                + "INNER JOIN Room r ON s.RoomId = r.Id "
                + "INNER JOIN Cinema c ON r.CinemaId = c.Id "
                + "ORDER BY s.StartAt DESC";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Schedule schedule = mapResultSetToSchedule(rs);
                schedule.setMovieName(rs.getString("movie_name"));
                schedule.setRoomName(rs.getString("room_name"));
                schedule.setCinemaName(rs.getString("cinema_name"));
                list.add(schedule);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // GET SCHEDULE BY ID WITH STAFF VALIDATION
    public Schedule getScheduleById(int scheduleId, int staffId) {
        String sql = "SELECT s.*, m.Name as movie_name, m.MovieDuration, r.Name as room_name, "
                + "c.Name as cinema_name "
                + "FROM Schedule s "
                + "INNER JOIN Movie m ON s.MovieId = m.Id "
                + "INNER JOIN Room r ON s.RoomId = r.Id "
                + "INNER JOIN Cinema c ON r.CinemaId = c.Id "
                + "INNER JOIN Cinema_Staff cs ON c.Id = cs.cinema_id "
                + "WHERE s.Id = ? AND s.Staff_id = ? AND cs.staff_id = ? AND cs.status = 1";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, scheduleId);
            ps.setInt(2, staffId);
            ps.setInt(3, staffId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToSchedule(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // GET SCHEDULE BY ID (for checkout validation - no staff validation)
    public Schedule getScheduleById(int scheduleId) {
        String sql = "SELECT s.*, m.Name as movie_name, m.MovieDuration, r.Name as room_name, "
                + "c.Name as cinema_name "
                + "FROM Schedule s "
                + "INNER JOIN Movie m ON s.MovieId = m.Id "
                + "INNER JOIN Room r ON s.RoomId = r.Id "
                + "INNER JOIN Cinema c ON r.CinemaId = c.Id "
                + "WHERE s.Id = ? AND s.Status = N'Đang hoạt động'";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Schedule schedule = mapResultSetToSchedule(rs);
                    schedule.setMovieName(rs.getString("movie_name"));
                    schedule.setRoomName(rs.getString("room_name"));
                    schedule.setCinemaName(rs.getString("cinema_name"));
                    return schedule;
                }
            }
        } catch (Exception e) {
            System.err.println("Error getting schedule by ID: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    // GET ACTIVE MOVIES FOR SCHEDULING (chỉ phim đang chiếu)
    public List<model.Movie> getActiveMoviesForScheduling() {
        List<model.Movie> list = new ArrayList<>();
        String sql = "SELECT * FROM Movie WHERE Status = N'Đang chiếu' "
                + "AND (EndDate IS NULL OR EndDate >= GETDATE()) "
                + "ORDER BY Name";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                model.Movie movie = new model.Movie();
                movie.setId(rs.getInt("Id"));
                movie.setName(rs.getString("Name"));
                movie.setMovieDuration(rs.getInt("MovieDuration"));
                movie.setPremiereDate(rs.getDate("PremiereDate"));
                movie.setEndDate(rs.getDate("EndDate"));
                list.add(movie);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // GET ROOMS BY STAFF ID (chỉ phòng thuộc rạp mà staff quản lý)
    public List<model.Room> getRoomsByStaff(int staffId) {
        List<model.Room> list = new ArrayList<>();
        String sql = "SELECT r.*, c.Name as cinema_name "
                + "FROM Room r "
                + "INNER JOIN Cinema c ON r.CinemaId = c.Id "
                + "INNER JOIN Cinema_Staff cs ON c.Id = cs.cinema_id "
                + "WHERE cs.staff_id = ? AND cs.status = 1 "
                + "AND r.Status = 1 "
                + // Chỉ phòng active
                "ORDER BY c.Name, r.Name";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, staffId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    model.Room room = new model.Room();
                    room.setId(rs.getInt("Id"));
                    room.setName(rs.getString("Name"));
                    room.setCinemaName(rs.getString("cinema_name"));
                    list.add(room);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int getTotalSchedulesByStaff(int staffId) {
        String sql = "SELECT COUNT(*) FROM Schedule WHERE Staff_id = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, staffId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

// GET SCHEDULES BY STAFF WITH PAGING
    public List<Schedule> getSchedulesByStaffWithPaging(int staffId, int page, int pageSize) {
        List<Schedule> list = new ArrayList<>();

        // Tính offset
        int offset = (page - 1) * pageSize;

        String sql = "SELECT s.*, m.Name as movie_name, r.Name as room_name, "
                + "c.Name as cinema_name "
                + "FROM Schedule s "
                + "INNER JOIN Movie m ON s.MovieId = m.Id "
                + "INNER JOIN Room r ON s.RoomId = r.Id "
                + "INNER JOIN Cinema c ON r.CinemaId = c.Id "
                + "WHERE s.Staff_id = ? "
                + "ORDER BY s.StartAt DESC "
                + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, staffId);
            ps.setInt(2, offset);
            ps.setInt(3, pageSize);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Schedule schedule = mapResultSetToSchedule(rs);
                    schedule.setMovieName(rs.getString("movie_name"));
                    schedule.setRoomName(rs.getString("room_name"));
                    schedule.setCinemaName(rs.getString("cinema_name"));
                    list.add(schedule);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // CREATE SCHEDUL
    public boolean addSchedule(Schedule schedule) {
        String sql = "INSERT INTO Schedule (Code, Name, StartAt, FinishAt, Price, Status, MovieId, RoomId, Staff_id) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            // CONVERT sang Timestamp
            java.sql.Timestamp startTimestamp = new java.sql.Timestamp(schedule.getStartAt().getTime());
            java.sql.Timestamp finishTimestamp = new java.sql.Timestamp(schedule.getFinishAt().getTime());

            String code = generateScheduleCode();

            System.out.println("=== DEBUG DAO ADD SCHEDULE ===");

            ps.setString(1, code);
            ps.setString(2, schedule.getName());
            ps.setTimestamp(3, startTimestamp);
            ps.setTimestamp(4, finishTimestamp);
            ps.setDouble(5, schedule.getPrice());
            ps.setString(6, "Đang hoạt động");
            ps.setInt(7, schedule.getMovieId());
            ps.setInt(8, schedule.getRoomId());
            ps.setInt(9, schedule.getStaffId());

            System.out.println("Executing update with setString()...");
            int result = ps.executeUpdate();
            System.out.println("ExecuteUpdate result: " + result);

            return result > 0;

        } catch (SQLException e) {
            System.out.println("SQL ERROR in addSchedule: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.out.println("ERROR in addSchedule: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // UPDATE SCHEDULE
    public boolean updateSchedule(Schedule schedule) {
        String sql = "UPDATE Schedule SET Name = ?, StartAt = ?, FinishAt = ?, Price = ?, "
                + "Status = ?, MovieId = ?, RoomId = ? "
                + "WHERE Id = ? AND Staff_id = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            // Convert Date to Timestamp
            Timestamp startTimestamp = new Timestamp(schedule.getStartAt().getTime());
            Timestamp finishTimestamp = new Timestamp(schedule.getFinishAt().getTime());

            ps.setString(1, schedule.getName());
            ps.setTimestamp(2, startTimestamp);
            ps.setTimestamp(3, finishTimestamp);
            ps.setDouble(4, schedule.getPrice());
            ps.setString(5, schedule.getStatus());
            ps.setInt(6, schedule.getMovieId());
            ps.setInt(7, schedule.getRoomId());
            ps.setInt(8, schedule.getId());
            ps.setInt(9, schedule.getStaffId());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // DELETE SCHEDULE (soft delete - chuyển sang Ngưng hoạt động)
    public boolean deleteSchedule(int scheduleId, int staffId) {
        String sql = "UPDATE Schedule SET Status = ? WHERE Id = ? AND Staff_id = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, Schedule.STATUS_INACTIVE);
            ps.setInt(2, scheduleId);
            ps.setInt(3, staffId);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ===== VALIDATION METHODS =====
    // KIỂM TRA TRÙNG LỊCH CHIẾU TRONG PHÒNG
    public boolean isScheduleConflict(int roomId, java.util.Date startAt, java.util.Date finishAt, int excludeScheduleId) {
        String sql = "SELECT COUNT(*) FROM Schedule "
                + "WHERE RoomId = ? AND Status = ? "
                + "AND Id != ? "
                + "AND NOT (FinishAt <= ? OR StartAt >= ?)";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            // CONVERT java.util.Date to java.sql.Timestamp
            java.sql.Timestamp startTimestamp = new java.sql.Timestamp(startAt.getTime());
            java.sql.Timestamp finishTimestamp = new java.sql.Timestamp(finishAt.getTime());

            ps.setInt(1, roomId);
            ps.setString(2, Schedule.STATUS_ACTIVE);
            ps.setInt(3, excludeScheduleId);
            ps.setTimestamp(4, startTimestamp);   // FinishAt <= startAt
            ps.setTimestamp(5, finishTimestamp);  // StartAt >= finishAt

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

    // KIỂM TRA PHIM CÓ ĐANG CHIẾU KHÔNG
    public boolean isMovieActive(int movieId) {
        String sql = "SELECT COUNT(*) FROM Movie "
                + "WHERE Id = ? AND Status = N'Đang chiếu' "
                + "AND (EndDate IS NULL OR EndDate >= GETDATE())";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

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

    // KIỂM TRA PHÒNG CÓ THUỘC QUYỀN QUẢN LÝ CỦA STAFF KHÔNG
    public boolean isRoomManagedByStaff(int roomId, int staffId) {
        String sql = "SELECT COUNT(*) FROM Room r "
                + "INNER JOIN Cinema c ON r.CinemaId = c.Id "
                + "INNER JOIN Cinema_Staff cs ON c.Id = cs.cinema_id "
                + "WHERE r.Id = ? AND cs.staff_id = ? AND cs.status = 1";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roomId);
            ps.setInt(2, staffId);
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

    // LẤY THỜI LƯỢNG PHIM
    public int getMovieDuration(int movieId) {
        String sql = "SELECT MovieDuration FROM Movie WHERE Id = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, movieId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("MovieDuration");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ===== HELPER METHODS =====
    private Schedule mapResultSetToSchedule(ResultSet rs) throws SQLException {
        Schedule schedule = new Schedule();
        schedule.setId(rs.getInt("Id"));
        schedule.setCode(rs.getString("Code"));
        schedule.setName(rs.getString("Name"));

        // Convert Timestamp to Date
        Timestamp startTimestamp = rs.getTimestamp("StartAt");
        Timestamp finishTimestamp = rs.getTimestamp("FinishAt");
        if (startTimestamp != null) {
            schedule.setStartAt(new Date(startTimestamp.getTime()));
        }
        if (finishTimestamp != null) {
            schedule.setFinishAt(new Date(finishTimestamp.getTime()));
        }

        schedule.setPrice(rs.getDouble("Price"));
        schedule.setStatus(rs.getString("Status"));
        schedule.setMovieId(rs.getInt("MovieId"));
        schedule.setRoomId(rs.getInt("RoomId"));
        schedule.setStaffId(rs.getInt("Staff_id"));

        // Thông tin từ join (nếu có)
        try {
            String movieName = rs.getString("movie_name");
            String roomName = rs.getString("room_name");
            // Có thể set thêm thông tin nếu cần
        } catch (SQLException e) {
            // Các column join có thể không có trong mọi query
        }

        return schedule;
    }

    public List<Schedule> getSchedulesByMovieAndDate(int movieId, String date) {
        List<Schedule> schedules = new ArrayList<>();

        System.out.println("=== SCHEDULE DAO DEBUG ===");
        System.out.println("Searching for Movie ID: " + movieId);
        System.out.println("On Date: " + date);

        // SỬA: BỎ COMMENT VÀ THÊM CÁC TRƯỜNG CẦN THIẾT
        String sql = "SELECT s.*, c.Name as CinemaName, c.Address, r.Name as RoomName, "
                + "r.Description as RoomDescription " // QUAN TRỌNG: BỎ COMMENT DÒNG NÀY
                + "FROM Schedule s "
                + "JOIN Room r ON s.RoomId = r.Id "
                + "JOIN Cinema c ON r.CinemaId = c.Id "
                + "WHERE s.MovieId = ? AND CAST(s.StartAt AS DATE) = ? "
                + "AND s.Status = N'Đang hoạt động' "
                + "ORDER BY c.Name, s.StartAt";

        System.out.println("SQL: " + sql);

        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, movieId);
            ps.setString(2, date);

            System.out.println("Parameters set - MovieId: " + movieId + ", Date: " + date);

            try (ResultSet rs = ps.executeQuery()) {
                int count = 0;
                while (rs.next()) {
                    count++;

                    // Dùng hàm helper để map đối tượng
                    Schedule schedule = mapResultSetToSchedule(rs);

                    // SET CÁC TRƯỜNG JOIN - BỎ COMMENT TẤT CẢ CÁC DÒNG NÀY
                    schedule.setCinemaName(rs.getString("CinemaName"));
                    schedule.setRoomName(rs.getString("RoomName"));
                    schedule.setCinemaAddress(rs.getString("Address"));
                    schedule.setRoomDescription(rs.getString("RoomDescription"));

                    // THÊM VÀO DANH SÁCH
                    schedules.add(schedule);

                    System.out.println("FOUND AND ADDED SCHEDULE: " + schedule.getName()
                            + " | Cinema: " + schedule.getCinemaName()
                            + " | Address: " + schedule.getCinemaAddress());
                }
                System.out.println("TOTAL SCHEDULES FOUND: " + count);
            }

        } catch (Exception e) {
            System.out.println("ERROR in ScheduleDAO: " + e.getMessage());
            e.printStackTrace();
        }

        return schedules;
    }

    public List<Schedule> getRecentSchedules(int limit) {
        List<Schedule> list = new ArrayList<>();
        String sql = "SELECT TOP (?) s.*, m.Name as movie_name, r.Name as room_name, c.Name as cinema_name "
                + "FROM Schedule s "
                + "INNER JOIN Movie m ON s.MovieId = m.Id "
                + "INNER JOIN Room r ON s.RoomId = r.Id "
                + "INNER JOIN Cinema c ON r.CinemaId = c.Id "
                + "ORDER BY s.Id DESC"; // <-- ID lớn nhất = mới nhất

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Schedule schedule = mapResultSetToSchedule(rs);
                    schedule.setMovieName(rs.getString("movie_name"));
                    schedule.setRoomName(rs.getString("room_name"));
                    schedule.setCinemaName(rs.getString("cinema_name"));
                    list.add(schedule);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

// ===== Lấy danh sách schedule chỉ của rạp staff quản lý =====
    public List<Schedule> getSchedulesByStaffWithCinema(int staffId) {
        List<Schedule> list = new ArrayList<>();
        String sql = "SELECT s.*, m.Name as movie_name, r.Name as room_name, c.Name as cinema_name "
                + "FROM Schedule s "
                + "JOIN Room r ON s.RoomId = r.Id "
                + "JOIN Cinema c ON r.CinemaId = c.Id "
                + "JOIN Cinema_Staff cs ON c.Id = cs.cinema_id "
                + "JOIN Movie m ON s.MovieId = m.Id "
                + "WHERE cs.staff_id = ? AND cs.status = 1 "
                + "ORDER BY s.StartAt DESC";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, staffId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Schedule schedule = mapResultSetToSchedule(rs);
                    schedule.setMovieName(rs.getString("movie_name"));
                    schedule.setRoomName(rs.getString("room_name"));
                    schedule.setCinemaName(rs.getString("cinema_name"));
                    list.add(schedule);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ===== Lấy tổng số vé đã bán cho rạp của staff =====
    public int getTotalTicketsByStaff(int staffId) {
        String sql = "SELECT COUNT(*) AS TotalTickets "
                + "FROM Schedule s "
                + "JOIN Room r ON s.RoomId = r.Id "
                + "JOIN Cinema c ON r.CinemaId = c.Id "
                + "JOIN Cinema_Staff cs ON c.Id = cs.cinema_id "
                + "WHERE cs.staff_id = ? AND cs.status = 1 "
                + "AND s.Status = N'Đang hoạt động'";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, staffId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("TotalTickets");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

// ===== Tính tổng doanh thu theo staff =====
    public double getTotalRevenueByStaff(int staffId) {
        String sql = "SELECT SUM(s.Price) AS TotalRevenue "
                + "FROM Schedule s "
                + "JOIN Room r ON s.RoomId = r.Id "
                + "JOIN Cinema c ON r.CinemaId = c.Id "
                + "JOIN Cinema_Staff cs ON c.Id = cs.cinema_id "
                + "WHERE cs.staff_id = ? AND cs.status = 1 "
                + "AND s.Status = N'Đang hoạt động'";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, staffId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("TotalRevenue");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ===== Lấy tổng số suất chiếu hôm nay theo staff =====
    public int getTodaySchedulesByStaff(int staffId) {
        String sql = """
        SELECT COUNT(*) AS TodayCount
        FROM Schedule s
        JOIN Room r ON s.RoomId = r.Id
        JOIN Cinema c ON r.CinemaId = c.Id
        JOIN Cinema_Staff cs ON c.Id = cs.cinema_id
        WHERE cs.staff_id = ? 
          AND cs.status = 1
          AND CAST(s.StartAt AS DATE) = CAST(GETDATE() AS DATE)
    """;

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, staffId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("TodayCount");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    private String generateScheduleCode() {
        return "SCH" + System.currentTimeMillis();
    }
}
