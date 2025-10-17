package model;

public class Language {
    private int id;
    private String code;
    private String name;

    public Language() {
    }

    public Language(int id, String code, String name) {
        this.id = id;
        this.code = code;
        this.name = name;
    }

    // Getter & Setter
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
