package model;

import java.util.Date;
import java.util.List;

public class Movie {
    public static final String STATUS_SHOWING = "Đang chiếu";
    public static final String STATUS_COMING_SOON = "Sắp chiếu";
    public static final String STATUS_STOPPED = "Ngưng chiếu";
    private int id;
    private String code;
    private String name;
    private String description;
    private String image;
    private String trailer;
    private int movieDuration;
    private Date premiereDate;
    private Date endDate;
    private String status;
    private int ratedId;
    private List<MovieType> movieTypes;
    private List<Director> directors;
    private List<Performer> performers;
    private List<Language> languages;

    public Movie() {
    }

    public Movie(int id, String code, String name, String description, String image, String trailer, int movieDuration, Date premiereDate, Date endDate, String status, int ratedId, List<MovieType> movieTypes, List<Director> directors, List<Performer> performers, List<Language> languages) {
        this.id = id;
        this.code = code;
        this.name = name;
        this.description = description;
        this.image = image;
        this.trailer = trailer;
        this.movieDuration = movieDuration;
        this.premiereDate = premiereDate;
        this.endDate = endDate;
        this.status = status;
        this.ratedId = ratedId;
        this.movieTypes = movieTypes;
        this.directors = directors;
        this.performers = performers;
        this.languages = languages;
    }



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

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public String getTrailer() {
        return trailer;
    }

    public void setTrailer(String trailer) {
        this.trailer = trailer;
    }

    public int getMovieDuration() {
        return movieDuration;
    }

    public void setMovieDuration(int movieDuration) {
        this.movieDuration = movieDuration;
    }

    public Date getPremiereDate() {
        return premiereDate;
    }

    public void setPremiereDate(Date premiereDate) {
        this.premiereDate = premiereDate;
    }

    public Date getEndDate() {
        return endDate;
    }

    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getRatedId() {
        return ratedId;
    }

    public void setRatedId(int ratedId) {
        this.ratedId = ratedId;
    }

    public List<MovieType> getMovieTypes() {
        return movieTypes;
    }

    public void setMovieTypes(List<MovieType> movieTypes) {
        this.movieTypes = movieTypes;
    }

    public List<Director> getDirectors() {
        return directors;
    }

    public void setDirectors(List<Director> directors) {
        this.directors = directors;
    }

    public List<Performer> getPerformers() {
        return performers;
    }

    public void setPerformers(List<Performer> performers) {
        this.performers = performers;
    }

    public List<Language> getLanguages() {
        return languages;
    }

    public void setLanguages(List<Language> languages) {
        this.languages = languages;
    }

}
