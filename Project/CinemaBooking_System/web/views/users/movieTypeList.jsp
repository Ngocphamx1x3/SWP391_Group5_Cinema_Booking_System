<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.MovieType" %>
<%@ page import="dal.MovieDAO" %>
<%
    MovieDAO dao = new MovieDAO();
    List<MovieType> movieTypes = dao.getAllMovieTypes();
%>
<div style="width: 100%; text-align: center; margin: 30px 0;">
    <h3>Chọn thể loại phim</h3>
    <select id="movieTypeDropdown" name="movieType" 
            style="padding: 10px; border-radius: 8px; font-size: 16px; min-width: 200px; cursor: pointer;">
        <option value="">-- Tất cả thể loại --</option>
        <% for (MovieType type : movieTypes) { %>
            <option value="<%= type.getId() %>"><%= type.getName() %></option>
        <% } %>
    </select>
</div>

<script>
$(document).ready(function() {
    $('#movieTypeDropdown').change(function() {
        var typeId = $(this).val();
        var currentTab = $('input.radio:checked').attr('id'); // 'one' hoặc 'two'
        
        $.ajax({
            url: '${pageContext.request.contextPath}/filterMovieByType',
            type: 'GET',
            data: { 
                typeId: typeId,
                status: currentTab === 'one' ? 'Đang chiếu' : 'Sắp chiếu'
            },
            success: function(response) {
                // Update movie list based on current tab
                if (currentTab === 'one') {
                    $('#one-panel .khoi').html(response);
                } else {
                    $('#two-panel .khoi').html(response);
                }
            },
            error: function() {
                alert('Có lỗi xảy ra khi lọc phim!');
            }
        });
    });
    
    // Reset filter when switching tabs
    $('input.radio').change(function() {
        $('#movieTypeDropdown').val('').trigger('change');
    });
});
</script>