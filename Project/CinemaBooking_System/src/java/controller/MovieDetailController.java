package controller;

import dal.MovieDAO;
import model.Movie;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Date;

@WebServlet(name = "MovieDetailController", urlPatterns = {"/detail"})
public class MovieDetailController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing movie id");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            MovieDAO dao = new MovieDAO();
            Movie movie = dao.getMovieById(id);

            if (movie == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Movie not found");
                return;
            }

            // Tạo danh sách ngày từ hôm nay đến ngày kết thúc của phim
            List<DateOption> dateOptions = generateDateOptions(movie);

            request.setAttribute("movie", movie);
            request.setAttribute("dateOptions", dateOptions);
            request.getRequestDispatcher("/views/users/detail.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid movie id");
        }
    }

    private List<DateOption> generateDateOptions(Movie movie) {
        List<DateOption> dates = new ArrayList<>();
        LocalDate today = LocalDate.now();

        // SỬA: Dùng java.util.Date
        LocalDate endDate = convertUtilDateToLocalDate(movie.getEndDate());

        DateTimeFormatter dayFormatter = DateTimeFormatter.ofPattern("dd");
        DateTimeFormatter monthFormatter = DateTimeFormatter.ofPattern("MM");

        LocalDate currentDate = today;
        int count = 0;

        // Tạo danh sách 14 ngày hoặc đến ngày kết thúc
        while (!currentDate.isAfter(endDate) && count < 14) {
            DateOption dateOption = new DateOption();
            dateOption.setDate(currentDate);
            dateOption.setDay(currentDate.format(dayFormatter));
            dateOption.setMonth(currentDate.format(monthFormatter));
            dateOption.setDayOfWeek(formatVietnameseDay(currentDate.getDayOfWeek().toString()));
            dateOption.setFullDate(currentDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy")));
            dateOption.setDatabaseDate(currentDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd")));
            dateOption.setToday(currentDate.equals(today));

            dates.add(dateOption);
            currentDate = currentDate.plusDays(1);
            count++;
        }

        return dates;
    }

    // PHƯƠNG THỨC MỚI: Convert java.util.Date to LocalDate
    private LocalDate convertUtilDateToLocalDate(Date utilDate) {
        if (utilDate == null) {
            // Nếu endDate null, mặc định 30 ngày từ hôm nay
            return LocalDate.now().plusDays(30);
        }

        // KIỂM TRA KIỂU DỮ LIỆU
        if (utilDate instanceof java.sql.Date) {
            // Nếu là java.sql.Date, dùng toLocalDate()
            return ((java.sql.Date) utilDate).toLocalDate();
        } else {
            // Nếu là java.util.Date (thông thường), dùng toInstant()
            return utilDate.toInstant()
                    .atZone(java.time.ZoneId.systemDefault())
                    .toLocalDate();
        }
    }

    private String formatVietnameseDay(String day) {
        switch (day.toLowerCase()) {
            case "monday":
                return "Thứ 2";
            case "tuesday":
                return "Thứ 3";
            case "wednesday":
                return "Thứ 4";
            case "thursday":
                return "Thứ 5";
            case "friday":
                return "Thứ 6";
            case "saturday":
                return "Thứ 7";
            case "sunday":
                return "Chủ nhật";
            default:
                return day;
        }
    }

    // Inner class để lưu thông tin ngày
    public static class DateOption {

        private LocalDate date;
        private String day;
        private String month;
        private String dayOfWeek;
        private String fullDate;
        private String databaseDate;
        private boolean today;

        // GETTERS
        public LocalDate getDate() {
            return date;
        }

        public String getDay() {
            return day;
        }

        public String getMonth() {
            return month;
        }

        public String getDayOfWeek() {
            return dayOfWeek;
        }

        public String getFullDate() {
            return fullDate;
        }

        public String getDatabaseDate() {
            return databaseDate;
        }

        public boolean getToday() {
            return today;
        }

        // SETTERS
        public void setDate(LocalDate date) {
            this.date = date;
        }

        public void setDay(String day) {
            this.day = day;
        }

        public void setMonth(String month) {
            this.month = month;
        }

        public void setDayOfWeek(String dayOfWeek) {
            this.dayOfWeek = dayOfWeek;
        }

        public void setFullDate(String fullDate) {
            this.fullDate = fullDate;
        }

        public void setDatabaseDate(String databaseDate) {
            this.databaseDate = databaseDate;
        }

        public void setToday(boolean today) {
            this.today = today;
        }
    }
}
