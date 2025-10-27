package model;

import java.time.LocalDateTime;

public class Seat {
    private int id;
    private String code;
    private String description;
    private String line;
    private int number;
    private boolean status;
    private int roomId;
    private int seatTypeId;
    private String rowCode;
    private int columnNumber;
    private String position;
    private boolean isAvailable;
    
    // New fields for flexible design
    private int positionX;
    private int positionY;
    private int widthUnits = 1;
    private int heightUnits = 1;
    private boolean isDraggable = true;
    private String customColor;
    
    // Additional info from join
    private String typeColor;
    private String typeName;
    private double typeSurcharge;
    
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Constructors
    public Seat() {}

    public Seat(int id, String code, String description, String line, int number, 
                boolean status, int roomId, int seatTypeId, String rowCode, 
                int columnNumber, String position, boolean isAvailable,
                int positionX, int positionY, int widthUnits, int heightUnits,
                boolean isDraggable, String customColor) {
        this.id = id;
        this.code = code;
        this.description = description;
        this.line = line;
        this.number = number;
        this.status = status;
        this.roomId = roomId;
        this.seatTypeId = seatTypeId;
        this.rowCode = rowCode;
        this.columnNumber = columnNumber;
        this.position = position;
        this.isAvailable = isAvailable;
        this.positionX = positionX;
        this.positionY = positionY;
        this.widthUnits = widthUnits;
        this.heightUnits = heightUnits;
        this.isDraggable = isDraggable;
        this.customColor = customColor;
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getLine() { return line; }
    public void setLine(String line) { this.line = line; }

    public int getNumber() { return number; }
    public void setNumber(int number) { this.number = number; }

    public boolean isStatus() { return status; }
    public void setStatus(boolean status) { this.status = status; }

    public int getRoomId() { return roomId; }
    public void setRoomId(int roomId) { this.roomId = roomId; }

    public int getSeatTypeId() { return seatTypeId; }
    public void setSeatTypeId(int seatTypeId) { this.seatTypeId = seatTypeId; }

    public String getRowCode() { return rowCode; }
    public void setRowCode(String rowCode) { this.rowCode = rowCode; }

    public int getColumnNumber() { return columnNumber; }
    public void setColumnNumber(int columnNumber) { this.columnNumber = columnNumber; }

    public String getPosition() { return position; }
    public void setPosition(String position) { this.position = position; }

    public boolean isAvailable() { return isAvailable; }
    public void setAvailable(boolean available) { isAvailable = available; }

    public int getPositionX() { return positionX; }
    public void setPositionX(int positionX) { this.positionX = positionX; }

    public int getPositionY() { return positionY; }
    public void setPositionY(int positionY) { this.positionY = positionY; }

    public int getWidthUnits() { return widthUnits; }
    public void setWidthUnits(int widthUnits) { this.widthUnits = widthUnits; }

    public int getHeightUnits() { return heightUnits; }
    public void setHeightUnits(int heightUnits) { this.heightUnits = heightUnits; }

    public boolean isDraggable() { return isDraggable; }
    public void setDraggable(boolean draggable) { isDraggable = draggable; }

    public String getCustomColor() { return customColor; }
    public void setCustomColor(String customColor) { this.customColor = customColor; }

    public String getTypeColor() { return typeColor; }
    public void setTypeColor(String typeColor) { this.typeColor = typeColor; }

    public String getTypeName() { return typeName; }
    public void setTypeName(String typeName) { this.typeName = typeName; }

    public double getTypeSurcharge() { return typeSurcharge; }
    public void setTypeSurcharge(double typeSurcharge) { this.typeSurcharge = typeSurcharge; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}