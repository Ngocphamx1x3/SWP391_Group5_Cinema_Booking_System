package util;

import javax.activation.DataSource;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

/**
 * Simple DataSource implementation for byte arrays
 * Used to embed images in email
 */
public class ByteArrayDataSource implements DataSource {
    private byte[] data;
    private String contentType;
    private String name;

    public ByteArrayDataSource(byte[] data, String contentType) {
        this.data = data;
        this.contentType = contentType;
        this.name = "attachment";
    }

    public ByteArrayDataSource(byte[] data, String contentType, String name) {
        this.data = data;
        this.contentType = contentType;
        this.name = name;
    }

    @Override
    public InputStream getInputStream() throws IOException {
        return new ByteArrayInputStream(data);
    }

    @Override
    public OutputStream getOutputStream() throws IOException {
        throw new IOException("Read-only data source");
    }

    @Override
    public String getContentType() {
        return contentType;
    }

    @Override
    public String getName() {
        return name;
    }
}

