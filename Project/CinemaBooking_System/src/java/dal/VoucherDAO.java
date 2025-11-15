package dal;

import model.Voucher;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import util.DBContext;

public class VoucherDAO {

    // Tạo voucher mới với danh sách phim áp dụng
    public boolean createVoucherWithMovies(Voucher voucher, List<Integer> movieIds) {
        Connection conn = null;
        try {
            conn = new DBContext().getConnection();
            conn.setAutoCommit(false);

            // 1. Tạo voucher
            String voucherSql = "INSERT INTO Voucher (Code, Name, Description, DiscountType, DiscountValue, "
                    + "MinOrderAmount, MaxDiscountAmount, Quantity, StartDate, EndDate, CreatedBy) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            PreparedStatement voucherStmt = conn.prepareStatement(voucherSql, Statement.RETURN_GENERATED_KEYS);
            voucherStmt.setString(1, voucher.getCode());
            voucherStmt.setString(2, voucher.getName());
            voucherStmt.setString(3, voucher.getDescription());
            voucherStmt.setInt(4, voucher.getDiscountType());
            voucherStmt.setDouble(5, voucher.getDiscountValue());
            voucherStmt.setDouble(6, voucher.getMinOrderAmount());
            voucherStmt.setDouble(7, voucher.getMaxDiscountAmount());
            voucherStmt.setInt(8, voucher.getQuantity());
            voucherStmt.setTimestamp(9, voucher.getStartDate());
            voucherStmt.setTimestamp(10, voucher.getEndDate());
            voucherStmt.setInt(11, voucher.getCreatedBy());

            int voucherResult = voucherStmt.executeUpdate();

            if (voucherResult == 0) {
                conn.rollback();
                return false;
            }

            // Lấy ID của voucher vừa tạo
            int voucherId;
            try (ResultSet generatedKeys = voucherStmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    voucherId = generatedKeys.getInt(1);
                } else {
                    conn.rollback();
                    return false;
                }
            }

            // 2. Thêm các phim áp dụng vào bảng VoucherMovie (nếu có)
            if (movieIds != null && !movieIds.isEmpty()) {
                String movieSql = "INSERT INTO VoucherMovie (VoucherId, MovieId) VALUES (?, ?)";
                PreparedStatement movieStmt = conn.prepareStatement(movieSql);

                for (Integer movieId : movieIds) {
                    movieStmt.setInt(1, voucherId);
                    movieStmt.setInt(2, movieId);
                    movieStmt.addBatch();
                }

                int[] movieResults = movieStmt.executeBatch();

                // Kiểm tra xem có insert nào thất bại không
                for (int result : movieResults) {
                    if (result == PreparedStatement.EXECUTE_FAILED) {
                        conn.rollback();
                        return false;
                    }
                }
            }

            conn.commit();
            return true;

        } catch (Exception e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
    }

    // Lấy thông tin phim theo ID (cho voucher detail)
    public MovieItem getMovieById(int movieId) {
        String sql = "SELECT Id, Code, Name FROM Movie WHERE Id = ?";

        try (Connection conn = new DBContext().getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, movieId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                MovieItem movie = new MovieItem();
                movie.setId(rs.getInt("Id"));
                movie.setCode(rs.getString("Code"));
                movie.setName(rs.getString("Name"));
                return movie;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Lấy danh sách tất cả phim (cho dropdown)
    public List<MovieItem> getAllMovies() {
        List<MovieItem> movies = new ArrayList<>();

        // Thử cả 2 cách query để debug
        String sql1 = "SELECT Id, Code, Name FROM Movie WHERE Status = 1 ORDER BY Name";
        String sql2 = "SELECT Id, Code, Name FROM Movie ORDER BY Name";

        System.out.println("=== DEBUG: Getting movies from database ===");

        // Thử query đầu tiên
        try (Connection conn = new DBContext().getConnection(); PreparedStatement stmt = conn.prepareStatement(sql1); ResultSet rs = stmt.executeQuery()) {

            System.out.println("Trying SQL 1: " + sql1);

            while (rs.next()) {
                MovieItem movie = new MovieItem();
                movie.setId(rs.getInt("Id"));
                movie.setCode(rs.getString("Code"));
                movie.setName(rs.getString("Name"));
                movies.add(movie);

                System.out.println("Found movie with SQL 1: ID=" + movie.getId() + ", Code=" + movie.getCode() + ", Name=" + movie.getName());
            }

            System.out.println("Total movies found with SQL 1: " + movies.size());

        } catch (Exception e) {
            System.out.println("ERROR with SQL 1: " + e.getMessage());
            e.printStackTrace();
        }

        // Nếu không tìm thấy phim nào, thử query thứ 2 (không có điều kiện Status)
        if (movies.isEmpty()) {
            try (Connection conn = new DBContext().getConnection(); PreparedStatement stmt = conn.prepareStatement(sql2); ResultSet rs = stmt.executeQuery()) {

                System.out.println("Trying SQL 2: " + sql2);

                while (rs.next()) {
                    MovieItem movie = new MovieItem();
                    movie.setId(rs.getInt("Id"));
                    movie.setCode(rs.getString("Code"));
                    movie.setName(rs.getString("Name"));
                    movies.add(movie);

                    System.out.println("Found movie with SQL 2: ID=" + movie.getId() + ", Code=" + movie.getCode() + ", Name=" + movie.getName());
                }

                System.out.println("Total movies found with SQL 2: " + movies.size());

            } catch (Exception e) {
                System.out.println("ERROR with SQL 2: " + e.getMessage());
                e.printStackTrace();
            }
        }

        // Debug: kiểm tra cấu trúc bảng Movie
        if (movies.isEmpty()) {
            try (Connection conn = new DBContext().getConnection(); PreparedStatement stmt = conn.prepareStatement("SELECT TOP 1 * FROM Movie"); ResultSet rs = stmt.executeQuery()) {

                if (rs.next()) {
                    System.out.println("=== MOVIE TABLE STRUCTURE ===");
                    ResultSetMetaData metaData = rs.getMetaData();
                    int columnCount = metaData.getColumnCount();
                    for (int i = 1; i <= columnCount; i++) {
                        System.out.println("Column " + i + ": " + metaData.getColumnName(i) + " - " + metaData.getColumnTypeName(i));
                    }

                    // In giá trị của record đầu tiên
                    System.out.println("=== SAMPLE MOVIE RECORD ===");
                    for (int i = 1; i <= columnCount; i++) {
                        String columnName = metaData.getColumnName(i);
                        Object value = rs.getObject(i);
                        System.out.println(columnName + ": " + value);
                    }
                }

            } catch (Exception e) {
                System.out.println("ERROR checking table structure: " + e.getMessage());
            }
        }

        return movies;
    }

    // Lấy danh sách phim áp dụng của voucher
    public List<Integer> getMovieIdsByVoucherId(int voucherId) {
        List<Integer> movieIds = new ArrayList<>();
        String sql = "SELECT MovieId FROM VoucherMovie WHERE VoucherId = ?";

        try (Connection conn = new DBContext().getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, voucherId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                movieIds.add(rs.getInt("MovieId"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return movieIds;
    }

   

    // Kiểm tra code đã tồn tại chưa
    public boolean isCodeExists(String code) {
        String sql = "SELECT COUNT(*) FROM Voucher WHERE Code = ?";

        try (Connection conn = new DBContext().getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, code);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Kiểm tra code đã tồn tại (trừ voucher hiện tại)
    public boolean isCodeExists(String code, int excludeVoucherId) {
        String sql = "SELECT COUNT(*) FROM Voucher WHERE Code = ? AND Id != ?";

        try (Connection conn = new DBContext().getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, code);
            stmt.setInt(2, excludeVoucherId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Lấy tất cả voucher
    public List<Voucher> getAllVouchers() {
        List<Voucher> vouchers = new ArrayList<>();
        String sql = "SELECT * FROM Voucher ORDER BY CreatedAt DESC";

        try (Connection conn = new DBContext().getConnection(); PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Voucher voucher = new Voucher();
                voucher.setId(rs.getInt("Id"));
                voucher.setCode(rs.getString("Code"));
                voucher.setName(rs.getString("Name"));
                voucher.setDescription(rs.getString("Description"));
                voucher.setDiscountType(rs.getInt("DiscountType"));
                voucher.setDiscountValue(rs.getDouble("DiscountValue"));
                voucher.setMinOrderAmount(rs.getDouble("MinOrderAmount"));
                voucher.setMaxDiscountAmount(rs.getDouble("MaxDiscountAmount"));
                voucher.setQuantity(rs.getInt("Quantity"));
                voucher.setUsedQuantity(rs.getInt("UsedQuantity"));
                voucher.setStartDate(rs.getTimestamp("StartDate"));
                voucher.setEndDate(rs.getTimestamp("EndDate"));
                voucher.setIsActive(rs.getBoolean("IsActive"));
                voucher.setCreatedAt(rs.getTimestamp("CreatedAt"));
                voucher.setCreatedBy(rs.getInt("CreatedBy"));

                vouchers.add(voucher);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return vouchers;
    }

    // Lấy voucher theo ID
    public Voucher getVoucherById(int id) {
        String sql = "SELECT * FROM Voucher WHERE Id = ?";

        try (Connection conn = new DBContext().getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                Voucher voucher = new Voucher();
                voucher.setId(rs.getInt("Id"));
                voucher.setCode(rs.getString("Code"));
                voucher.setName(rs.getString("Name"));
                voucher.setDescription(rs.getString("Description"));
                voucher.setDiscountType(rs.getInt("DiscountType"));
                voucher.setDiscountValue(rs.getDouble("DiscountValue"));
                voucher.setMinOrderAmount(rs.getDouble("MinOrderAmount"));
                voucher.setMaxDiscountAmount(rs.getDouble("MaxDiscountAmount"));
                voucher.setQuantity(rs.getInt("Quantity"));
                voucher.setUsedQuantity(rs.getInt("UsedQuantity"));
                voucher.setStartDate(rs.getTimestamp("StartDate"));
                voucher.setEndDate(rs.getTimestamp("EndDate"));
                voucher.setIsActive(rs.getBoolean("IsActive"));
                voucher.setCreatedAt(rs.getTimestamp("CreatedAt"));
                voucher.setCreatedBy(rs.getInt("CreatedBy"));
                voucher.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
                voucher.setUpdatedBy(rs.getInt("UpdatedBy"));

                return voucher;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Cập nhật voucher với danh sách phim
    public boolean updateVoucherWithMovies(Voucher voucher, List<Integer> movieIds) {
        Connection conn = null;
        try {
            conn = new DBContext().getConnection();
            conn.setAutoCommit(false);

            // 1. Cập nhật voucher
            String voucherSql = "UPDATE Voucher SET Code = ?, Name = ?, Description = ?, "
                    + "DiscountType = ?, DiscountValue = ?, MinOrderAmount = ?, "
                    + "MaxDiscountAmount = ?, Quantity = ?, StartDate = ?, EndDate = ?, "
                    + "IsActive = ?, UpdatedAt = GETDATE(), UpdatedBy = ? "
                    + "WHERE Id = ?";

            PreparedStatement voucherStmt = conn.prepareStatement(voucherSql);
            voucherStmt.setString(1, voucher.getCode());
            voucherStmt.setString(2, voucher.getName());
            voucherStmt.setString(3, voucher.getDescription());
            voucherStmt.setInt(4, voucher.getDiscountType());
            voucherStmt.setDouble(5, voucher.getDiscountValue());
            voucherStmt.setDouble(6, voucher.getMinOrderAmount());
            voucherStmt.setDouble(7, voucher.getMaxDiscountAmount());
            voucherStmt.setInt(8, voucher.getQuantity());
            voucherStmt.setTimestamp(9, voucher.getStartDate());
            voucherStmt.setTimestamp(10, voucher.getEndDate());
            voucherStmt.setBoolean(11, voucher.getIsActive());
            voucherStmt.setInt(12, voucher.getUpdatedBy());
            voucherStmt.setInt(13, voucher.getId());

            int voucherResult = voucherStmt.executeUpdate();
            if (voucherResult == 0) {
                conn.rollback();
                return false;
            }

            // 2. Xóa các phim cũ
            String deleteSql = "DELETE FROM VoucherMovie WHERE VoucherId = ?";
            PreparedStatement deleteStmt = conn.prepareStatement(deleteSql);
            deleteStmt.setInt(1, voucher.getId());
            deleteStmt.executeUpdate();

            // 3. Thêm các phim mới (nếu có)
            if (movieIds != null && !movieIds.isEmpty()) {
                String insertSql = "INSERT INTO VoucherMovie (VoucherId, MovieId) VALUES (?, ?)";
                PreparedStatement insertStmt = conn.prepareStatement(insertSql);

                for (Integer movieId : movieIds) {
                    insertStmt.setInt(1, voucher.getId());
                    insertStmt.setInt(2, movieId);
                    insertStmt.addBatch();
                }

                insertStmt.executeBatch();
            }

            conn.commit();
            return true;

        } catch (Exception e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    public List<Voucher> getActiveVouchersByMovieId(int movieId) {
        List<Voucher> vouchers = new ArrayList<>();
        String sql = "SELECT DISTINCT v.* "
                + "FROM Voucher v "
                + "LEFT JOIN VoucherMovie vm ON v.Id = vm.VoucherId "
                + "WHERE v.IsActive = 1 "
                + "AND v.StartDate <= GETDATE() "
                + "AND v.EndDate >= GETDATE() "
                + "AND v.UsedQuantity < v.Quantity "
                + "AND (vm.MovieId IS NULL OR vm.MovieId = ?) "
                + "ORDER BY v.DiscountValue DESC";

        System.out.println("🔍 Executing voucher query for movieId: " + movieId);
        System.out.println("📝 SQL: " + sql);

        try (Connection conn = new DBContext().getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, movieId);
            ResultSet rs = stmt.executeQuery();

            int count = 0;
            while (rs.next()) {
                count++;
                Voucher voucher = new Voucher();
                voucher.setId(rs.getInt("Id"));
                voucher.setCode(rs.getString("Code"));
                voucher.setName(rs.getString("Name"));
                voucher.setDescription(rs.getString("Description"));
                voucher.setDiscountType(rs.getInt("DiscountType"));
                voucher.setDiscountValue(rs.getDouble("DiscountValue"));
                voucher.setMinOrderAmount(rs.getDouble("MinOrderAmount"));
                voucher.setMaxDiscountAmount(rs.getDouble("MaxDiscountAmount"));
                voucher.setQuantity(rs.getInt("Quantity"));
                voucher.setUsedQuantity(rs.getInt("UsedQuantity"));
                voucher.setStartDate(rs.getTimestamp("StartDate"));
                voucher.setEndDate(rs.getTimestamp("EndDate"));

                vouchers.add(voucher);
                System.out.println("🎫 Voucher found: " + voucher.getCode() + " - " + voucher.getName());
            }

            System.out.println("✅ Total vouchers found: " + count);

        } catch (Exception e) {
            System.out.println("❌ Error in getActiveVouchersByMovieId: " + e.getMessage());
            e.printStackTrace();
        }
        return vouchers;
    }
    
    // Method để reserve voucher khi tạo order (chưa thanh toán)
    // CHỈ LƯU VÀO VoucherUsage với UsedAt = NULL, CHƯA TRỪ UsedQuantity
    public boolean reserveVoucherForOrder(int voucherId, int orderId, double discountAmount, Connection conn) {
        try {
            // 1. Kiểm tra voucher còn hiệu lực không
            String checkSql = "SELECT Quantity, UsedQuantity FROM Voucher WHERE Id = ? AND IsActive = 1 AND UsedQuantity < Quantity";
            PreparedStatement checkStmt = conn.prepareStatement(checkSql);
            checkStmt.setInt(1, voucherId);
            ResultSet rs = checkStmt.executeQuery();
            
            if (!rs.next()) {
                System.out.println("❌ Voucher not available: " + voucherId);
                return false;
            }

            // 2. Thêm record vào VoucherUsage với UsedAt = NULL (chưa thanh toán)
            String usageSql = "INSERT INTO VoucherUsage (VoucherId, OrderId, DiscountAmount, UsedAt) VALUES (?, ?, ?, NULL)";
            PreparedStatement usageStmt = conn.prepareStatement(usageSql);
            usageStmt.setInt(1, voucherId);
            usageStmt.setInt(2, orderId);
            usageStmt.setDouble(3, discountAmount);
            
            int usageResult = usageStmt.executeUpdate();
            if (usageResult == 0) {
                System.out.println("❌ Failed to insert VoucherUsage record");
                return false;
            }

            System.out.println("✅ Voucher reserved (not yet paid) for order: " + orderId + ", voucher: " + voucherId);
            return true;

        } catch (Exception e) {
            System.err.println("❌ Error in reserveVoucherForOrder: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Method để xác nhận và trừ voucher khi thanh toán thành công
    // Cập nhật UsedAt = GETDATE(), tăng UsedQuantity, và deactivate nếu hết
    public boolean confirmVoucherUsage(int orderId) {
        Connection conn = null;
        try {
            conn = new DBContext().getConnection();
            conn.setAutoCommit(false);
            
            // 1. Lấy thông tin voucher từ VoucherUsage (chỉ lấy những record chưa thanh toán: UsedAt IS NULL)
            String getUsageSql = "SELECT VoucherId, DiscountAmount FROM VoucherUsage WHERE OrderId = ? AND UsedAt IS NULL";
            PreparedStatement getUsageStmt = conn.prepareStatement(getUsageSql);
            getUsageStmt.setInt(1, orderId);
            ResultSet rs = getUsageStmt.executeQuery();
            
            if (!rs.next()) {
                System.out.println("⚠️ No pending voucher usage found for order: " + orderId);
                conn.rollback();
                return false;
            }
            
            int voucherId = rs.getInt("VoucherId");
            double discountAmount = rs.getDouble("DiscountAmount");
            
            // 2. Cập nhật UsedAt = GETDATE() trong VoucherUsage (đánh dấu đã thanh toán)
            String updateUsageSql = "UPDATE VoucherUsage SET UsedAt = GETDATE() WHERE OrderId = ? AND UsedAt IS NULL";
            PreparedStatement updateUsageStmt = conn.prepareStatement(updateUsageSql);
            updateUsageStmt.setInt(1, orderId);
            int updateUsageResult = updateUsageStmt.executeUpdate();
            
            if (updateUsageResult == 0) {
                System.out.println("❌ Failed to update VoucherUsage UsedAt for order: " + orderId);
                conn.rollback();
                return false;
            }
            
            // 3. Tăng UsedQuantity trong Voucher (trừ số lượng voucher)
            String updateVoucherSql = "UPDATE Voucher SET UsedQuantity = UsedQuantity + 1 WHERE Id = ?";
            PreparedStatement updateVoucherStmt = conn.prepareStatement(updateVoucherSql);
            updateVoucherStmt.setInt(1, voucherId);
            int updateVoucherResult = updateVoucherStmt.executeUpdate();
            
            if (updateVoucherResult == 0) {
                System.out.println("❌ Failed to update Voucher UsedQuantity for voucher: " + voucherId);
                conn.rollback();
                return false;
            }
            
            // 4. Tự động deactivate nếu đã hết (UsedQuantity >= Quantity)
            String deactivateSql = "UPDATE Voucher SET IsActive = 0 WHERE Id = ? AND UsedQuantity >= Quantity";
            PreparedStatement deactivateStmt = conn.prepareStatement(deactivateSql);
            deactivateStmt.setInt(1, voucherId);
            deactivateStmt.executeUpdate();
            
            conn.commit();
            System.out.println("✅ Voucher usage confirmed: order=" + orderId + ", voucher=" + voucherId + ", discount=" + discountAmount);
            System.out.println("✅ Voucher quantity deducted and status updated");
            return true;
            
        } catch (Exception e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            System.err.println("❌ Error in confirmVoucherUsage: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    // Method cũ giữ lại để tương thích (tự tạo connection riêng)
    // DEPRECATED: Sử dụng reserveVoucherForOrder() thay thế
    public boolean useVoucherForOrder(int voucherId, int orderId, double discountAmount) {
        Connection conn = null;
        try {
            conn = new DBContext().getConnection();
            conn.setAutoCommit(false);

            boolean result = reserveVoucherForOrder(voucherId, orderId, discountAmount, conn);
            
            if (result) {
                conn.commit();
            } else {
                conn.rollback();
            }
            
            return result;

        } catch (Exception e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    // Overload method nhận Connection từ bên ngoài (dùng trong transaction)
    // DEPRECATED: Sử dụng reserveVoucherForOrder() thay thế
    public boolean useVoucherForOrder(int voucherId, int orderId, double discountAmount, Connection conn) {
        return reserveVoucherForOrder(voucherId, orderId, discountAmount, conn);
    }

    public boolean updateVoucherQuantity(int voucherId) {
    String sql = "UPDATE Voucher SET UsedQuantity = UsedQuantity + 1 WHERE Id = ? AND UsedQuantity < Quantity";
    
    try (Connection conn = new DBContext().getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        
        stmt.setInt(1, voucherId);
        int result = stmt.executeUpdate();
        return result > 0;
        
    } catch (Exception e) {
        e.printStackTrace();
        return false;
    }
}

public boolean deactivateIfExhausted(int voucherId) {
    String sql = "UPDATE Voucher SET IsActive = 0 WHERE Id = ? AND UsedQuantity >= Quantity";
    
    try (Connection conn = new DBContext().getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        
        stmt.setInt(1, voucherId);
        int result = stmt.executeUpdate();
        
        if (result > 0) {
            System.out.println("🔒 Voucher deactivated: " + voucherId);
        }
        return result > 0;
        
    } catch (Exception e) {
        e.printStackTrace();
        return false;
    }
}
    
    // Inner class MovieItem
    public static class MovieItem {

        private int id;
        private String code;
        private String name;

        // Constructors
        public MovieItem() {
        }

        public MovieItem(int id, String code, String name) {
            this.id = id;
            this.code = code;
            this.name = name;
        }

        // Getters and Setters
        public int getId() {
            return id;
        }

        public void setId(int id) {
            this.id = id;
        }

        public String getCode() {
            return code;
        }

        public void setCode(String code) {
            this.code = code;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }
    }
}
