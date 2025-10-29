package model;

import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * Lớp Schedule - đại diện cho lịch chiếu phim tại rạp
 * Áp dụng Java Coding Convention cho class và member.
 */
public class Schedule {

    // Status constants
    public static final String STATUS_ACTIVE = "active";
    public static final String STATUS_CANCELLED = "cancelled";
    public static final String STATUS_INACTIVE = "inactive";

    // Fields (private)
    private int id;
    private String code;
    private String name;
    private Date startAt;
    private Date finishAt;
    private double price;
    private String status;
    private int operatingStatus;
    private int movieId;
    private int roomId;

    // Constructors
    public Schedule() {
    }

    public Schedule(int id, String code, String name, Date startAt, Date finishAt, double price,
                    String status, int operatingStatus, int movieId, int roomId) {
        this.id = id;
        this.code = code;
        this.name = name;
        this.startAt = startAt;
        this.finishAt = finishAt;
        this.price = price;
        this.status = status;
        this.operatingStatus = operatingStatus;
        this.movieId = movieId;
        this.roomId = roomId;
    }

    // Getter & Setter methods
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

    public Date getStartAt() {
        return startAt;
    }

    public void setStartAt(Date startAt) {
        this.startAt = startAt;
    }

    public Date getFinishAt() {
        return finishAt;
    }

    public void setFinishAt(Date finishAt) {
        this.finishAt = finishAt;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getOperatingStatus() {
        return operatingStatus;
    }

    public void setOperatingStatus(int operatingStatus) {
        this.operatingStatus = operatingStatus;
    }

    public int getMovieId() {
        return movieId;
    }

    public void setMovieId(int movieId) {
        this.movieId = movieId;
    }

    public int getRoomId() {
        return roomId;
    }

    public void setRoomId(int roomId) {
        this.roomId = roomId;
    }

    @Override
    public String toString() {
        return "Schedule{" +
                "id=" + id +
                ", code='" + code + '\'' +
                ", name='" + name + '\'' +
                ", startAt=" + startAt +
                ", finishAt=" + finishAt +
                ", price=" + price +
                ", status='" + status + '\'' +
                ", operatingStatus=" + operatingStatus +
                ", movieId=" + movieId +
                ", roomId=" + roomId +
                '}';
    }

    /**
     * Kiểm tra lịch chiếu có thể sửa không.
     * Không cho phép nếu đã kết thúc hoặc đang ở trạng thái huỷ.
     * @return true nếu được sửa, false nếu không
     */
    public boolean canBeEdited() {
        // Không được sửa nếu lịch đã kết thúc
        if (finishAt != null) {
            Date now = new Date();
            if (finishAt.before(now)) {
                return false;
            }
        }
        // Không được sửa nếu trạng thái đã huỷ
        if (status != null) {
            String s = status.trim().toLowerCase();
            if (s.equals("canceled") || s.equals("cancelled") || s.equals("huy")) {
                return false;
            }
        }
        return true;
    }

    /**
     * Kiểm tra lịch chiếu có thể huỷ không.
     * Chỉ kiểm tra trạng thái thời gian và trạng thái mã.
     * @return true nếu có thể huỷ, false nếu không
     */
    public boolean canBeCancelled() {
        // Không thể huỷ nếu đã kết thúc
        if (finishAt != null) {
            Date now = new Date();
            if (finishAt.before(now)) {
                return false;
            }
        }
        // Không thể huỷ nếu trạng thái đã hủy
        if (status != null) {
            String s = status.trim().toLowerCase();
            if (s.equals("canceled") || s.equals("cancelled") || s.equals("huy")) {
                return false;
            }
        }
        // Có thể mở rộng với logic vé đã bán
        return true;
    }

    /**
     * Định dạng thời gian bắt đầu về dạng dd/MM/yyyy HH:mm.
     * @return Chuỗi thời gian đã định dạng, hoặc "" nếu null
     */
    public String getFormattedStartAt() {
        if (startAt == null) {
            return "";
        }
        return new SimpleDateFormat("dd/MM/yyyy HH:mm").format(startAt);
    }

    /**
     * Định dạng thời gian kết thúc về dạng dd/MM/yyyy HH:mm.
     * @return Chuỗi thời gian đã định dạng, hoặc "" nếu null
     */
    public String getFormattedFinishAt() {
        if (finishAt == null) {
            return "";
        }
        return new SimpleDateFormat("dd/MM/yyyy HH:mm").format(finishAt);
    }

    /**
     * Định dạng startAt phục vụ cho input type="datetime-local".
     * @return Chuỗi yyyy-MM-dd HH:mm, hoặc "" nếu null
     */
    public String getStartAtLocal() {
        if (startAt == null) {
            return "";
        }
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
        return sdf.format(startAt);
    }

    /**
     * Lấy tên nhãn trạng thái hoạt động thực tế.
     * @return Chuỗi tiếng Việt trạng thái theo operatingStatus
     */
    public String getOperatingStatusLabel() {
        switch (operatingStatus) {
            case 0:
                return "Chờ chiếu";
            case 1:
                return "Đang chiếu";
            case 2:
                return "Đã chiếu";
            default:
                return "Không xác định";
        }
    }
}