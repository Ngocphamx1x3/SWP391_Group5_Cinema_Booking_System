<%@ page contentType="text/html;charset=UTF-8" %>
<!-- ====== MOVIE SEARCH BAR ====== -->
<div style="width: 100%; display: flex; justify-content: flex-end; margin: 30px 0;">
  <div style="position: relative; width: 400px;">
    <input id="searchInput" type="text" placeholder="Search for movies..." autocomplete="off" 
           style="width: 100%; height: 45px; border: 1px solid #ccc; border-radius: 30px; padding: 0 20px; font-size: 16px; outline: none;">
    <div id="searchResults" 
         style="position: absolute; top: 48px; left: 0; right: 0; background: white; border: 1px solid #ccc; border-radius: 10px; box-shadow: 0 4px 10px rgba(0, 0, 0, 0.15); display: none; z-index: 1000; max-height: 300px; overflow-y: auto;">
    </div>
  </div>
</div>

<script>
  var searchInput = document.getElementById("searchInput");
  var searchResults = document.getElementById("searchResults");
  var searchTimeout;

  // Hàm tìm kiếm
  function performSearch(query) {
    if (query.trim().length === 0) {
      searchResults.style.display = "none";
      searchResults.innerHTML = "";
      return;
    }

    // Hiển thị loading
    searchResults.innerHTML = "<div style='padding:15px;text-align:center;color:#666;'>Searching...</div>";
    searchResults.style.display = "block";

    // Gọi API
    fetch("searchMovieAjax?query=" + encodeURIComponent(query))
      .then(function(response) {
        return response.json();
      })
      .then(function(movies) {
        console.log("Found movies:", movies);
        if (movies.length === 0) {
          searchResults.innerHTML = "<div style='padding:15px;text-align:center;color:#999;'>No movies found</div>";
          return;
        }

        // Tạo HTML cho kết quả
        var html = "";
        for (var i = 0; i < movies.length; i++) {
          var movie = movies[i];
          var movieId = movie.id;
          var movieName = movie.name || "Unknown";
          var movieImage = movie.image || "";
          
          // Fix đuôi file: .img -> .jpg
          if (movieImage.endsWith(".img")) {
            movieImage = movieImage.replace(".img", ".jpg");
          }
          
          var imagePath = "assets/admin/img/img/" + movieImage;
          
          html += "<div style='display:flex;align-items:center;gap:12px;padding:10px 12px;cursor:pointer;border-bottom:1px solid #eee;' onclick='goToMovie(" + movieId + ")'>";
          html += "  <img src='" + imagePath + "' alt='" + movieName + "' style='width:48px;height:72px;object-fit:cover;border-radius:6px;' onerror=\"this.src='assets/admin/img/img/default.jpg'\">";
          html += "  <div style='display:flex;flex-direction:column;'>";
          html += "    <span style='font-size:14px;font-weight:600;color:black;'>" + movieName + "</span>";
          html += "  </div>";
          html += "</div>";
        }
        searchResults.innerHTML = html;
      })
      .catch(function(error) {
        console.error("Search error:", error);
        searchResults.innerHTML = "<div style='padding:15px;text-align:center;color:red;'>Error loading results</div>";
      });
  }

  // Hàm chuyển trang
  function goToMovie(movieId) {
    window.location.href = "detail?id=" + movieId;
  }

  // Lắng nghe sự kiện input (debounce)
  searchInput.addEventListener("input", function() {
    clearTimeout(searchTimeout);
    var query = this.value;
    searchTimeout = setTimeout(function() {
      performSearch(query);
    }, 300);
  });

  // Đóng khi click bên ngoài
  document.addEventListener("click", function(e) {
    if (!searchInput.contains(e.target) && !searchResults.contains(e.target)) {
      searchResults.style.display = "none";
    }
  });
</script>   