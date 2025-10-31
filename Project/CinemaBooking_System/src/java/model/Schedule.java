package model;

import java.text.SimpleDateFormat;
import java.util.Date;

public class Schedule {

    // Status constants
    public static final String STATUS_ACTIVE = "Đang hoạt động";
    public static final String STATUS_INACTIVE = "Ngưng hoạt động";

    private int id;
    private String code;
    private String name;
    private Date startAt;
    private Date finishAt;
    private double price;
    private String status;
    private int movieId;
    private int roomId;
    private int staffId;
    private String movieName;
    private String roomName;
    private String cinemaName;
    private String cinemaAddress;
    private String roomDescription;

    // Constructors
    public Schedule() {
        this.status = STATUS_ACTIVE;
    }

    public Schedule(int id, String code, String name, Date startAt, Date finishAt,
            double price, String status, int movieId, int roomId, int staffId) {
        this.id = id;
        this.code = code;
        this.name = name;
        this.startAt = startAt;
        this.finishAt = finishAt;
        this.price = price;
        this.status = status;
        this.movieId = movieId;
        this.roomId = roomId;
        this.staffId = staffId;
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

    public int getStaffId() {
        return staffId;
    }

    public void setStaffId(int staffId) {
        this.staffId = staffId;
    }

    public String getMovieName() {
        return movieName;
    }

    public void setMovieName(String movieName) {
        this.movieName = movieName;
    }

    public String getRoomName() {
        return roomName;
    }

    public void setRoomName(String roomName) {
        this.roomName = roomName;
    }

    public String getCinemaName() {
        return cinemaName;
    }

    public void setCinemaName(String cinemaName) {
        this.cinemaName = cinemaName;
    }

    public String getCinemaAddress() {
        return cinemaAddress;
    }

    public void setCinemaAddress(String cinemaAddress) {
        this.cinemaAddress = cinemaAddress;
    }

    public String getRoomDescription() {
        return roomDescription;
    }

    public void setRoomDescription(String roomDescription) {
        this.roomDescription = roomDescription;
    }

    public boolean isValidStartTime() {
        if (startAt == null) {
            return false;
        }

        Date now = new Date();
        long minTime = now.getTime() + (30 * 60 * 1000);
        return startAt.getTime() >= minTime;
    }

    public boolean isValidEndTime(int movieDuration) {
        if (startAt == null || finishAt == null) {
            return false;
        }

        // Tính thời gian kết thúc dự kiến = startAt + movieDuration
        long expectedEndTime = startAt.getTime() + (movieDuration * 60 * 1000);
        long tolerance = 5 * 60 * 1000; // Dung sai 5 phút

        return Math.abs(finishAt.getTime() - expectedEndTime) <= tolerance;
    }

    public void calculateEndTime(int movieDuration) {
        if (startAt != null) {
            long endTimeMillis = startAt.getTime() + (movieDuration * 60 * 1000);
            this.finishAt = new Date(endTimeMillis);
        }
    }

    public boolean canBeEdited() {
        if (STATUS_INACTIVE.equals(status)) {
            return true;
        }

        if (startAt != null) {
            Date now = new Date();
            return startAt.getTime() - now.getTime() > (30 * 60 * 1000);
        }
        return true;
    }

    public boolean canBeCancelled() {
        if (STATUS_INACTIVE.equals(status)) {
            return true;
        }

        if (startAt != null) {
            Date now = new Date();
            return startAt.getTime() - now.getTime() > (30 * 60 * 1000);
        }
        return true;
    }

    // Format methods
    public String getFormattedStartAt() {
        if (startAt == null) {
            return "";
        }
        return new SimpleDateFormat("dd/MM/yyyy HH:mm").format(startAt);
    }

    public String getFormattedFinishAt() {
        if (finishAt == null) {
            return "";
        }
        return new SimpleDateFormat("dd/MM/yyyy HH:mm").format(finishAt);
    }

    public String getStartAtForInput() {
        if (startAt == null) {
            return "";
        }
        return new SimpleDateFormat("yyyy-MM-dd'T'HH:mm").format(startAt);
    }

    public String getFinishAtForInput() {
        if (finishAt == null) {
            return "";
        }
        return new SimpleDateFormat("yyyy-MM-dd'T'HH:mm").format(finishAt);
    }

    @Override
    public String toString() {
        return "Schedule{"
                + "id=" + id
                + ", name='" + name + '\''
                + ", startAt=" + getFormattedStartAt()
                + ", finishAt=" + getFormattedFinishAt()
                + ", price=" + price
                + ", status='" + status + '\''
                + ", movieId=" + movieId
                + ", roomId=" + roomId
                + ", staffId=" + staffId
                + '}';
    }
}
