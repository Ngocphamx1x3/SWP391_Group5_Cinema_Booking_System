package util;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.net.*;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.*;

/**
 * Tạo Payment Request cho PayOS với signature chuẩn:
 * - Chuỗi ký: key=value&key2=value2... (sort key alphabet)
 * - HMAC_SHA256(checksumKey) -> hex lowercase
 */
public class PayOSService {

    // LẤY từ my.payos.vn
    private static final String CLIENT_ID = "";
    private static final String API_KEY   = "";
    private static final String CHECKSUM  = "";

    private static final String CREATE_PAYMENT_URL = "";

    public static class PaymentResult {
        public final String checkoutUrl;
        public final String providerRef;
        public final String qrDataUri; // data:image/png;base64,...
        public final String qrPlain; 

         public PaymentResult(String checkoutUrl, String providerRef, String qrDataUri, String qrPlain) {
            this.checkoutUrl = checkoutUrl;
            this.providerRef = providerRef;
            this.qrDataUri   = qrDataUri;
            this.qrPlain     = qrPlain;
        }
    }

     public PaymentResult createPayment(
            String orderCodeStr, long amount, String description,
            String returnUrl, String cancelUrl
    ) throws Exception {

        long orderCode = Long.parseLong(orderCodeStr.replaceAll("\\D",""));

        Map<String,Object> body = new LinkedHashMap<>();
        body.put("orderCode", orderCode);
        body.put("amount", amount);
        // Lưu ý: mô tả <= 25 ký tự theo PayOS
        if (description != null && description.length() > 25) {
            description = description.substring(0, 25);
        }
        body.put("description", description);
        body.put("returnUrl", returnUrl);
        body.put("cancelUrl", cancelUrl);

        String signature = buildSignature(body, CHECKSUM);
        body.put("signature", signature);

        String json = toJson(body);

        HttpURLConnection conn = (HttpURLConnection) new URL(CREATE_PAYMENT_URL).openConnection();
        conn.setRequestMethod("POST");
        conn.setConnectTimeout(12000);
        conn.setReadTimeout(20000);
        conn.setDoOutput(true);
        conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
        conn.setRequestProperty("x-client-id", CLIENT_ID);
        conn.setRequestProperty("x-api-key",   API_KEY);

        try (OutputStream os = conn.getOutputStream()) {
            os.write(json.getBytes(StandardCharsets.UTF_8));
        }

        int httpCode = conn.getResponseCode();
        InputStream is = (httpCode >= 200 && httpCode < 300) ? conn.getInputStream() : conn.getErrorStream();
        String resp = readAll(is);

        System.out.println("PayOS createPayment HTTP = " + httpCode);
        System.out.println("SIGN source = " + buildQueryForSign(body, false));
        System.out.println("SIGN hex    = " + signature);
        System.out.println("Request     = " + json);
        System.out.println("Response    = " + resp);

        if (httpCode < 200 || httpCode >= 300) {
            throw new IOException("PayOS createPayment failed: HTTP " + httpCode + " - " + resp);
        }

        String checkoutUrl = find(resp, "\"checkoutUrl\":\"", "\"");
        String providerRef = find(resp, "\"providerRef\":\"", "\"");
        if (providerRef == null || providerRef.isBlank()) {
            providerRef = find(resp, "\"paymentLinkId\":\"", "\"");
        }

        // PayOS trả chuỗi EMV ở field "qrCode"
        String qrPlain  = find(resp, "\"qrCode\":\"", "\"");              // <<< LẤY CHUỖI EMV
        String qrBase64 = find(resp, "\"qrCodeBase64\":\"", "\"");        // nếu PayOS có field base64 (hiếm)
        String qrDataUri = (qrBase64 != null && !qrBase64.isBlank())
                ? "data:image/png;base64," + qrBase64
                : null;

        return new PaymentResult(checkoutUrl, providerRef, qrDataUri, qrPlain);
    }

    /* ==================== Signature helpers ==================== */

    /** Tạo signature theo format tài liệu: key=value&key2=value2... (sort key alphabet) */
    private static String buildSignature(Map<String, Object> src, String secret) throws Exception {
        String data = buildQueryForSign(src, true);
        return hmacSHA256(data, secret);
    }

    /** Tạo chuỗi "key=value&..." từ map; sort key; value null -> "" ; object/array -> JSON */
    private static String buildQueryForSign(Map<String, Object> src, boolean sort) {
        List<String> keys = new ArrayList<>(src.keySet());
        if (sort) Collections.sort(keys);

        StringBuilder sb = new StringBuilder();
        boolean first = true;
        for (String k : keys) {
            if ("signature".equals(k)) continue; // không ký chính nó
            Object v = src.get(k);

            String val;
            if (v == null) {
                val = "";
            } else if (v instanceof Map || v instanceof List) {
                val = toJsonValue(v); // stringify
            } else {
                val = String.valueOf(v);
            }

            if (!first) sb.append('&');
            first = false;
            sb.append(k).append('=').append(val);
        }
        return sb.toString();
    }

    private static String toJson(Map<String, Object> map) {
        StringBuilder sb = new StringBuilder("{");
        boolean first = true;
        for (var e : map.entrySet()) {
            if (!first) sb.append(',');
            first = false;
            sb.append('"').append(e.getKey()).append('"').append(':').append(toJsonValue(e.getValue()));
        }
        sb.append('}');
        return sb.toString();
    }

    @SuppressWarnings("unchecked")
    private static String toJsonValue(Object v) {
        if (v == null) return "\"\"";
        if (v instanceof Number || v instanceof Boolean) return String.valueOf(v);
        if (v instanceof Map) {
            Map<String, Object> m = (Map<String, Object>) v;
            StringBuilder sb = new StringBuilder("{");
            boolean first = true;
            for (var e : m.entrySet()) {
                if (!first) sb.append(',');
                first = false;
                sb.append('"').append(escape(e.getKey())).append('"').append(':').append(toJsonValue(e.getValue()));
            }
            sb.append('}');
            return sb.toString();
        }
        if (v instanceof List) {
            List<?> arr = (List<?>) v;
            StringBuilder sb = new StringBuilder("[");
            for (int i = 0; i < arr.size(); i++) {
                if (i > 0) sb.append(',');
                sb.append(toJsonValue(arr.get(i)));
            }
            sb.append(']');
            return sb.toString();
        }
        return "\"" + escape(String.valueOf(v)) + "\"";
    }

    private static String escape(String s) {
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    private static String readAll(InputStream is) throws IOException {
        try (BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
            StringBuilder sb = new StringBuilder();
            String line; while ((line = br.readLine()) != null) sb.append(line);
            return sb.toString();
        }
    }

    /** HMAC SHA-256 -> hex lowercase */
    private static String hmacSHA256(String data, String secret) throws Exception {
        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
        byte[] raw = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
        StringBuilder sb = new StringBuilder();
        for (byte b : raw) sb.append(String.format("%02x", b));
        return sb.toString();
    }

    private static String find(String src, String start, String end) {
        int i = src.indexOf(start); if (i < 0) return null;
        int j = src.indexOf(end, i + start.length()); if (j < 0) return null;
        return src.substring(i + start.length(), j);
    }
}
