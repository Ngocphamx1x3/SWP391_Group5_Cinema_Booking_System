package util;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.WriterException;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.Base64;
import java.util.Hashtable;

/**
 * Utility class để tạo QR code từ text và trả về dưới dạng base64 string
 * để có thể embed vào HTML email
 */
public class QRCodeUtil {
    
    private static final int QR_CODE_SIZE = 300; // Kích thước QR code (pixels)
    private static final String IMAGE_FORMAT = "PNG";
    
    /**
     * Tạo QR code từ text và trả về dưới dạng data URI (base64)
     * Có thể embed trực tiếp vào HTML: <img src="data:image/png;base64,...">
     * 
     * @param text Nội dung cần mã hóa vào QR code
     * @return Data URI string (data:image/png;base64,...) hoặc null nếu lỗi
     */
    public static String generateQRCodeBase64(String text) {
        if (text == null || text.trim().isEmpty()) {
            System.err.println("❌ QRCodeUtil: Text is null or empty");
            return null;
        }
        
        try {
            // Cấu hình QR code
            Hashtable<EncodeHintType, Object> hints = new Hashtable<>();
            hints.put(EncodeHintType.ERROR_CORRECTION, ErrorCorrectionLevel.M);
            hints.put(EncodeHintType.CHARACTER_SET, "UTF-8");
            hints.put(EncodeHintType.MARGIN, 1); // Margin xung quanh QR code
            
            // Tạo QR code
            QRCodeWriter qrCodeWriter = new QRCodeWriter();
            BitMatrix bitMatrix = qrCodeWriter.encode(text, BarcodeFormat.QR_CODE, QR_CODE_SIZE, QR_CODE_SIZE, hints);
            
            // Chuyển BitMatrix thành BufferedImage
            BufferedImage qrImage = new BufferedImage(QR_CODE_SIZE, QR_CODE_SIZE, BufferedImage.TYPE_INT_RGB);
            qrImage.createGraphics();
            
            Graphics2D graphics = (Graphics2D) qrImage.getGraphics();
            graphics.setColor(Color.WHITE);
            graphics.fillRect(0, 0, QR_CODE_SIZE, QR_CODE_SIZE);
            graphics.setColor(Color.BLACK);
            
            // Vẽ QR code
            for (int x = 0; x < QR_CODE_SIZE; x++) {
                for (int y = 0; y < QR_CODE_SIZE; y++) {
                    if (bitMatrix.get(x, y)) {
                        graphics.fillRect(x, y, 1, 1);
                    }
                }
            }
            
            // Chuyển BufferedImage thành byte array
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            ImageIO.write(qrImage, IMAGE_FORMAT, baos);
            byte[] imageBytes = baos.toByteArray();
            
            // Encode thành base64
            String base64Image = Base64.getEncoder().encodeToString(imageBytes);
            
            // Trả về data URI
            String dataUri = "data:image/" + IMAGE_FORMAT.toLowerCase() + ";base64," + base64Image;
            
            System.out.println("✅ QRCodeUtil: Generated QR code successfully");
            System.out.println("   - Text: " + text);
            System.out.println("   - Image size: " + imageBytes.length + " bytes");
            System.out.println("   - Base64 length: " + base64Image.length() + " chars");
            System.out.println("   - Data URI length: " + dataUri.length() + " chars");
            return dataUri;
            
        } catch (WriterException e) {
            System.err.println("❌ QRCodeUtil: WriterException - " + e.getMessage());
            e.printStackTrace();
            return null;
        } catch (IOException e) {
            System.err.println("❌ QRCodeUtil: IOException - " + e.getMessage());
            e.printStackTrace();
            return null;
        } catch (Exception e) {
            System.err.println("❌ QRCodeUtil: Unexpected error - " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Tạo chuỗi định danh vé từ danh sách ghế và mã đơn hàng
     * Format: "A5,A6ORD1763143904349" hoặc "A5ORD1763143904349" nếu chỉ có 1 ghế
     * 
     * @param seatCodes Danh sách mã ghế (ví dụ: "A5,A6" hoặc "A5")
     * @param orderCode Mã đơn hàng (ví dụ: "ORD1763143904349")
     * @return Chuỗi định danh vé
     */
    public static String createTicketIdentifier(String seatCodes, String orderCode) {
        if (seatCodes == null || seatCodes.trim().isEmpty()) {
            seatCodes = "";
        }
        if (orderCode == null || orderCode.trim().isEmpty()) {
            orderCode = "";
        }
        
        // Loại bỏ khoảng trắng và ghép lại
        String seats = seatCodes.replaceAll("\\s+", "").replace(",", "+");
        return seats + orderCode;
    }
}

