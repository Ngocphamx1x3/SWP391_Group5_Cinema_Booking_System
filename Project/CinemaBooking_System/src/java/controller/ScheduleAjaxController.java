package controller;

import dal.ScheduleDAO;
import model.Schedule;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "ScheduleAjaxController", urlPatterns = {"/schedule-ajax"})
public class ScheduleAjaxController extends HttpServlet {

    private ScheduleDAO scheduleDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        this.scheduleDAO = new ScheduleDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("=== SCHEDULE AJAX CONTROLLER ===");
        System.out.println("Movie ID: " + request.getParameter("movieId"));
        System.out.println("Date: " + request.getParameter("date"));

        String movieIdStr = request.getParameter("movieId");
        String date = request.getParameter("date");

        if (movieIdStr == null || date == null) {
            System.out.println("ERROR: Missing parameters");
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing parameters");
            return;
        }

        try {
            int movieId = Integer.parseInt(movieIdStr);

            List<Schedule> schedules = scheduleDAO.getSchedulesByMovieAndDate(movieId, date);

            System.out.println("Schedules returned to JSP: " + schedules.size());

            request.setAttribute("schedules", schedules);
            request.setAttribute("selectedDate", date);
            request.getRequestDispatcher("/views/users/schedule-list.jsp").forward(request, response);

        } catch (Exception e) {
            System.out.println("ERROR in ScheduleAjaxController: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
