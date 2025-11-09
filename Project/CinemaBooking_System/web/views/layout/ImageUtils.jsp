<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%!
    // Utility method to check if image filename is valid
    public boolean isValidImageFile(String imageName) {
        if (imageName == null || imageName.trim().isEmpty()) {
            return false;
        }
        String lower = imageName.toLowerCase();
        return lower.endsWith(".jpg") || lower.endsWith(".jpeg") || 
               lower.endsWith(".png") || lower.endsWith(".gif") || 
               lower.endsWith(".webp") || lower.endsWith(".svg");
    }
%>

