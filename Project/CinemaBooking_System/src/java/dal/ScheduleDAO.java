package dal;

/**
 * ScheduleDAO - Data Access Object for Schedule table.
 *
 * Coding Convention Notes:
 * - Method names: camelCase, descriptive of purpose (e.g., getAllSchedules).
 * - Constant names: UPPERCASE_WITH_UNDERSCORES for status strings.
 * - Indentation: 4 spaces.
 * - Each method separated by one empty line.
 * - All SQL and business rules use English. 
 * - Variables and parameters: meaningful names.
 * - Exception messages are printed to standard error with method context.
 * - Helper and mapping methods placed at the bottom.
 */
import model.Schedule;
import util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ScheduleDAO extends DBContext {
    private static final String TABLE_NAME = "Schedule";

    // Status constants for Schedule table
    public static final String STATUS_ACTIVE = "Active";
    public static final String STATUS_CANCELLED = "Cancelled";
    public static final String STATUS_INACTIVE = "Inactive";

    // ===== SCHEDULE QUERY (GENERIC) =====
    private List<Schedule> querySchedules(String sql, Object... params) {
        List<Schedule> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            for (int i = 0; i < params.length; i++) {
                stmt.setObject(i + 1, params[i]);
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToSchedule(rs));
                }
            }
        } catch (Exception ex) {
            logError("querySchedules", ex);
        }
        return list;
    }

    private void logError(String action, Exception ex) {
        System.err.println("[ScheduleDAO] " + action + " failed: " + ex.getMessage());
    }

    // ===== CRUD OPERATIONS =====

    /**
     * Flexible search with filters for date, movie, room, or status.
     * Empty string or null means no filter for that field.
     */
    public List<Schedule> getAllSchedules(String filterDate, String filterMovie, String filterRoom, String filterStatus) {
        StringBuilder query = new StringBuilder("SELECT * FROM " + TABLE_NAME + " WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (filterDate != null && !filterDate.trim().isEmpty()) {
            query.append(" AND CAST(startAt AS DATE) = ?");
            params.add(filterDate.trim());
        }
        if (filterMovie != null && !filterMovie.trim().isEmpty()) {
            try {
                int movieId = Integer.parseInt(filterMovie.trim());
                query.append(" AND movieId = ?");
                params.add(movieId);
            } catch (NumberFormatException ignored) { /* ignore filter */ }
        }
        if (filterRoom != null && !filterRoom.trim().isEmpty()) {
            try {
                int roomId = Integer.parseInt(filterRoom.trim());
                query.append(" AND roomId = ?");
                params.add(roomId);
            } catch (NumberFormatException ignored) { /* ignore filter */ }
        }
        if (filterStatus != null && !filterStatus.trim().isEmpty()) {
            query.append(" AND status = ?");
            params.add(filterStatus.trim());
        }
        query.append(" ORDER BY startAt DESC");
        return querySchedules(query.toString(), params.toArray());
    }

    /**
     * Get schedule by its id (primary key).
     */
    public Schedule getScheduleById(int id) {
        String sql = "SELECT * FROM " + TABLE_NAME + " WHERE id = ?";
        List<Schedule> list = querySchedules(sql, id);
        return list.isEmpty() ? null : list.get(0);
    }

    /**
     * Get all schedules for a specific cinema by using room-cinema JOIN.
     */
    public List<Schedule> getSchedulesByCinemaId(int cinemaId) {
        String sql = "SELECT s.* FROM " + TABLE_NAME + " s " +
                     "JOIN Room r ON s.roomId = r.id " +
                     "WHERE r.cinemaId = ? " +
                     "ORDER BY s.startAt DESC";
        return querySchedules(sql, cinemaId);
    }

    /**
     * Get all schedules for a specific movie.
     */
    public List<Schedule> getSchedulesByMovieId(int movieId) {
        String sql = "SELECT * FROM " + TABLE_NAME + " WHERE movieId = ? ORDER BY startAt DESC";
        return querySchedules(sql, movieId);
    }

    /**
     * Get all upcoming schedules (status=Active, startAt in future).
     */
    public List<Schedule> getUpcomingSchedules() {
        String sql = "SELECT * FROM " + TABLE_NAME +
                     " WHERE startAt > GETDATE() AND status = ? ORDER BY startAt ASC";
        return querySchedules(sql, STATUS_ACTIVE);
    }

    /**
     * Insert new schedule.
     * @return true if inserted successfully.
     */
    public boolean addSchedule(Schedule schedule) {
        if (schedule.getStartAt() == null || schedule.getFinishAt() == null) {
            logError("addSchedule", new Exception("Start/Finish time cannot be null"));
            return false;
        }

        String code = generateScheduleCode();
        schedule.setCode(code);

        if (schedule.getName() == null || schedule.getName().trim().isEmpty()) {
            schedule.setName("Lịch chiếu " + code);
        }

        String sql = "INSERT INTO " + TABLE_NAME
                   + " (code, name, startAt, finishAt, price, status, operatingStatus, movieId, roomId) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, schedule.getCode());
            stmt.setString(2, schedule.getName());
            stmt.setTimestamp(3, new Timestamp(schedule.getStartAt().getTime()));
            stmt.setTimestamp(4, new Timestamp(schedule.getFinishAt().getTime()));
            stmt.setDouble(5, schedule.getPrice());
            stmt.setString(6, schedule.getStatus());
            stmt.setInt(7, schedule.getOperatingStatus());
            stmt.setInt(8, schedule.getMovieId());
            stmt.setInt(9, schedule.getRoomId());

            int rows = stmt.executeUpdate();
            if (rows > 0) {
                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        schedule.setId(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
        } catch (Exception ex) {
            logError("addSchedule", ex);
        }
        return false;
    }

    /**
     * Update schedule by id.
     */
    public boolean updateSchedule(Schedule schedule) {
        String sql = "UPDATE " + TABLE_NAME
                   + " SET name = ?, roomId = ?, startAt = ?, finishAt = ?, price = ?, status = ?, operatingStatus = ?"
                   + " WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, schedule.getName());
            stmt.setInt(2, schedule.getRoomId());
            stmt.setTimestamp(3, new Timestamp(schedule.getStartAt().getTime()));
            stmt.setTimestamp(4, new Timestamp(schedule.getFinishAt().getTime()));
            stmt.setDouble(5, schedule.getPrice());
            stmt.setString(6, schedule.getStatus());
            stmt.setInt(7, schedule.getOperatingStatus());
            stmt.setInt(8, schedule.getId());

            return stmt.executeUpdate() > 0;
        } catch (Exception ex) {
            logError("updateSchedule", ex);
        }
        return false;
    }

    /**
     * Soft delete: set status to 'Cancelled' (does NOT delete from DB!).
     */
    public boolean deleteSchedule(int id) {
        String sql = "UPDATE " + TABLE_NAME + " SET status = ? WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, STATUS_CANCELLED);
            stmt.setInt(2, id);
            return stmt.executeUpdate() > 0;
        } catch (Exception ex) {
            logError("deleteSchedule", ex);
        }
        return false;
    }

    /**
     * Check if given time overlaps with any existing schedule in this room,
     * excluding optionally a schedule by id. Ignores schedules with status = Cancelled/Inactive.
     */
    public boolean hasTimeOverlap(int roomId, java.util.Date startAt, java.util.Date finishAt, int excludeId) {
        if (roomId <= 0) {
            return false;
        }
        String sql = "SELECT COUNT(*) FROM " + TABLE_NAME
                   + " WHERE roomId = ?"
                   + " AND status NOT IN (?, ?)"
                   + " AND (startAt < ? AND finishAt > ?)";
        if (excludeId > 0) {
            sql += " AND id != ?";
        }
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            int paramIndex = 1;
            stmt.setInt(paramIndex++, roomId);
            stmt.setString(paramIndex++, STATUS_CANCELLED);
            stmt.setString(paramIndex++, STATUS_INACTIVE);
            stmt.setTimestamp(paramIndex++, new Timestamp(finishAt.getTime()));
            stmt.setTimestamp(paramIndex++, new Timestamp(startAt.getTime()));
            if (excludeId > 0) {
                stmt.setInt(paramIndex, excludeId);
            }

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (Exception ex) {
            logError("hasTimeOverlap", ex);
        }
        return false;
    }

    /**
     * Get all room IDs by cinemaId with status=1 (active).
     */
    public List<Integer> getRoomIdsByCinemaId(int cinemaId) {
        List<Integer> roomIds = new ArrayList<>();
        String sql = "SELECT id FROM Room WHERE cinemaId = ? AND status = 1";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, cinemaId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    roomIds.add(rs.getInt("id"));
                }
            }
        } catch (Exception ex) {
            logError("getRoomIdsByCinemaId", ex);
        }
        return roomIds;
    }

    // ===== HELPER METHODS =====

    /**
     * Maps a result set row to a Schedule object.
     */
    private Schedule mapResultSetToSchedule(ResultSet rs) throws SQLException {
        Schedule schedule = new Schedule();
        schedule.setId(rs.getInt("id"));
        schedule.setCode(rs.getString("code"));
        schedule.setName(rs.getString("name"));
        schedule.setStartAt(rs.getTimestamp("startAt"));
        schedule.setFinishAt(rs.getTimestamp("finishAt"));
        schedule.setPrice(rs.getDouble("price"));
        schedule.setStatus(rs.getString("status"));
        schedule.setOperatingStatus(rs.getInt("operatingStatus"));
        schedule.setMovieId(rs.getInt("movieId"));
        schedule.setRoomId(rs.getInt("roomId"));
        return schedule;
    }

    /**
     * Generate a unique schedule code based on time and count that day.
     * For production, use UUID or sequence for better uniqueness.
     */
    private String generateScheduleCode() {
        String sql = "SELECT COUNT(*) FROM " + TABLE_NAME +
                     " WHERE CAST(startAt AS DATE) = CAST(GETDATE() AS DATE)";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                int count = rs.getInt(1) + 1;
                return "SCH"
                        + String.format("%05d", System.currentTimeMillis() % 100000)
                        + String.format("%03d", count);
            }
        } catch (Exception ex) {
            logError("generateScheduleCode", ex);
        }
        return "SCH" + String.format("%05d", System.currentTimeMillis() % 100000);
    }
}
