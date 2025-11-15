package util;

import javax.activation.DataHandler;
import javax.mail.*;
import javax.mail.internet.*;
import java.util.Base64;
import java.util.Properties;

public class EmailUtil {
    
    // Cấu hình email - THAY ĐỔI THÔNG TIN NÀY
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";
    private static final String USERNAME = "ngocphamquang30@gmail.com";
    private static final String PASSWORD = "hiwc vvpm nivq spjg";
    
    public static boolean sendHtmlEmail(String toEmail, String subject, String htmlContent) {
        try {
            // Cấu hình properties
            Properties props = new Properties();
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.host", SMTP_HOST);
            props.put("mail.smtp.port", SMTP_PORT);
            props.put("mail.smtp.ssl.trust", SMTP_HOST);
            // Thêm timeout để tránh treo ứng dụng
            props.put("mail.smtp.timeout", "10000");
            props.put("mail.smtp.connectiontimeout", "10000");
            
            // Tạo session với authenticator
            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(USERNAME, PASSWORD);
                }
            });
            
            // Tạo message
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(USERNAME, "CinemaBooking System"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject(subject);
            message.setSentDate(new java.util.Date());
            
            // Gmail và nhiều email client chặn data URI images vì lý do bảo mật
            // Phải dùng inline attachments (CID) để QR code hiển thị được
            MimeMultipart multipart = new MimeMultipart("related");
            
            // Tạo một list để lưu các image parts, sau đó thêm vào multipart theo thứ tự đúng
            java.util.List<MimeBodyPart> imageParts = new java.util.ArrayList<>();
            
            // Phần HTML - xử lý data URI images thành inline attachments
            String processedHtml = processDataUriImages(htmlContent, multipart, imageParts);
            
            // Đảm bảo HTML part được thêm vào multipart TRƯỚC các image parts
            // (một số email client yêu cầu thứ tự này)
            MimeBodyPart htmlPart = new MimeBodyPart();
            htmlPart.setContent(processedHtml, "text/html; charset=utf-8");
            multipart.addBodyPart(htmlPart);
            
            // Sau đó thêm các image parts
            for (MimeBodyPart imagePart : imageParts) {
                multipart.addBodyPart(imagePart);
            }
            
            message.setContent(multipart);
            System.out.println("📧 EmailUtil: Using inline attachments (CID) for images");
            
            // Gửi email
            Transport.send(message);
            System.out.println("✅ Email sent successfully to: " + toEmail);
            return true;
            
        } catch (Exception e) {
            System.err.println("❌ Failed to send email to: " + toEmail);
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Xử lý data URI images trong HTML và chuyển thành inline attachments
     * Điều này giúp QR code hiển thị được trên nhiều email client hơn
     */
    private static String processDataUriImages(String html, MimeMultipart multipart, java.util.List<MimeBodyPart> imageParts) {
        try {
            System.out.println("📧 EmailUtil: Processing data URI images...");
            String result = html;
            int imageIndex = 0;
            
            // Tìm tất cả data URI images (data:image/png;base64,...)
            int startIndex = 0;
            while (true) {
                int dataUriStart = result.indexOf("data:image/", startIndex);
                if (dataUriStart == -1) {
                    System.out.println("📧 EmailUtil: No more data URI images found");
                    break;
                }
                
                // Tìm kết thúc của data URI
                // Data URI thường kết thúc bằng dấu nháy kép (") trong HTML src attribute
                // Tìm từ vị trí sau "data:image/" để tránh match với chính nó
                int searchStart = dataUriStart + 12; // "data:image/" = 12 chars
                int dataUriEnd = result.indexOf("\"", searchStart);
                
                // Nếu không tìm thấy dấu nháy kép, thử tìm dấu nháy đơn
                if (dataUriEnd == -1) {
                    dataUriEnd = result.indexOf("'", searchStart);
                }
                
                // Nếu vẫn không tìm thấy, thử tìm dấu > (kết thúc tag)
                if (dataUriEnd == -1) {
                    dataUriEnd = result.indexOf(">", searchStart);
                }
                
                if (dataUriEnd == -1 || dataUriEnd <= dataUriStart) {
                    System.out.println("⚠️ EmailUtil: Could not find end of data URI");
                    System.out.println("   Data URI start: " + dataUriStart);
                    System.out.println("   Context: " + result.substring(Math.max(0, dataUriStart - 50), Math.min(result.length(), dataUriStart + 200)));
                    break;
                }
                
                String dataUri = result.substring(dataUriStart, dataUriEnd);
                System.out.println("📧 EmailUtil: Found data URI (length: " + dataUri.length() + ")");
                
                // Parse data URI
                if (dataUri.startsWith("data:image/") && dataUri.contains(";base64,")) {
                    String[] parts = dataUri.split(";base64,", 2);
                    if (parts.length == 2) {
                        String mimeType = parts[0].substring(11); // "data:image/" = 11 chars
                        String base64Data = parts[1];
                        
                        System.out.println("📧 EmailUtil: Parsing QR code image");
                        System.out.println("   - MIME type: image/" + mimeType);
                        System.out.println("   - Base64 data length: " + base64Data.length());
                        
                        // Decode base64
                        byte[] imageBytes = Base64.getDecoder().decode(base64Data);
                        System.out.println("   - Decoded image size: " + imageBytes.length + " bytes");
                        
                        // Tạo inline attachment với DataSource
                        MimeBodyPart imagePart = new MimeBodyPart();
                        String contentId = "qrcode_" + imageIndex;
                        String fullMimeType = "image/" + mimeType;
                        
                        // Tạo DataSource từ byte array
                        ByteArrayDataSource dataSource = new ByteArrayDataSource(imageBytes, fullMimeType, "qrcode.png");
                        
                        // Tạo DataHandler từ DataSource
                        DataHandler dataHandler = new DataHandler(dataSource);
                        
                        // Set DataHandler cho image part
                        imagePart.setDataHandler(dataHandler);
                        // Content-ID phải có dấu ngoặc nhọn
                        imagePart.setContentID("<" + contentId + ">");
                        imagePart.setDisposition(MimeBodyPart.INLINE);
                        // Content-Type với name để email client nhận diện tốt hơn
                        imagePart.setHeader("Content-Type", fullMimeType + "; name=\"qrcode.png\"");
                        
                        // Thêm vào list thay vì thêm trực tiếp vào multipart
                        // Sẽ thêm vào multipart sau HTML part
                        imageParts.add(imagePart);
                        System.out.println("✅ EmailUtil: Prepared inline attachment with CID: " + contentId);
                        
                        // Thay thế data URI bằng CID reference
                        // Format: cid:contentId (không có dấu ngoặc nhọn trong src attribute)
                        String cidReference = "cid:" + contentId;
                        
                        // Log để debug
                        System.out.println("📧 EmailUtil: Replacing data URI with CID");
                        System.out.println("   - Data URI: " + dataUri.substring(0, Math.min(50, dataUri.length())) + "...");
                        System.out.println("   - CID reference: " + cidReference);
                        
                        // Thay thế data URI bằng CID - đảm bảo giữ nguyên cấu trúc HTML
                        String before = result.substring(0, dataUriStart);
                        String after = result.substring(dataUriEnd);
                        
                        // Kiểm tra xem có dấu nháy kép sau CID không (để đảm bảo HTML hợp lệ)
                        result = before + cidReference + after;
                        
                        System.out.println("   - Replacement successful");
                        
                        imageIndex++;
                        // Tìm vị trí tiếp theo sau CID reference
                        startIndex = dataUriStart + cidReference.length();
                    } else {
                        System.out.println("⚠️ EmailUtil: Invalid data URI format");
                        startIndex = dataUriEnd;
                    }
                } else {
                    System.out.println("⚠️ EmailUtil: Data URI does not match expected format");
                    startIndex = dataUriEnd;
                }
            }
            
            if (imageIndex > 0) {
                System.out.println("✅ EmailUtil: Processed " + imageIndex + " image(s)");
                // Log một phần HTML để kiểm tra
                int previewStart = Math.max(0, result.indexOf("<img") - 50);
                int previewEnd = Math.min(result.length(), result.indexOf("<img") + 200);
                if (previewStart < previewEnd) {
                    System.out.println("📧 EmailUtil: HTML preview around img tag:");
                    System.out.println("   " + result.substring(previewStart, previewEnd));
                }
            } else {
                System.out.println("⚠️ EmailUtil: No images were processed");
            }
            
            return result;
        } catch (Exception e) {
            System.err.println("❌ EmailUtil: Failed to process data URI images");
            System.err.println("   Error: " + e.getMessage());
            e.printStackTrace();
            return html; // Trả về HTML gốc nếu có lỗi
        }
    }
}