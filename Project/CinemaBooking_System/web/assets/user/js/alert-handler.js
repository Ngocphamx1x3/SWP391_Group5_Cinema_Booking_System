/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */
// Auto-hide alert messages after 3 seconds
document.addEventListener('DOMContentLoaded', function() {
    const alerts = document.querySelectorAll('.alert');
    
    alerts.forEach(function(alert) {
        // Set timeout to fade out after 3 seconds
        setTimeout(function() {
            alert.classList.add('fade-out');
            
            // Remove element from DOM after animation completes
            setTimeout(function() {
                alert.remove();
            }, 500); // Match this with CSS animation duration
            
        }, 2000); // Show for 3 seconds before fading
    });
});

