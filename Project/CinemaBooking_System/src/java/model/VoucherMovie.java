/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

public class VoucherMovie {
    private int id;
    private int voucherId;
    private int movieId;
    // Thêm các trường khác từ bảng VoucherMovie
    
    // Constructors
    public VoucherMovie() {}
    
    public VoucherMovie(int id, int voucherId, int movieId) {
        this.id = id;
        this.voucherId = voucherId;
        this.movieId = movieId;
    }
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getVoucherId() { return voucherId; }
    public void setVoucherId(int voucherId) { this.voucherId = voucherId; }
    
    public int getMovieId() { return movieId; }
    public void setMovieId(int movieId) { this.movieId = movieId; }
}
