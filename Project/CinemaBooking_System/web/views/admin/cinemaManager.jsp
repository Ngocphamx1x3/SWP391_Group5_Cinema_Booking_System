<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý rạp | Cinema Booking</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        /* Sử dụng lại CSS từ dashboard */
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family: 'Inter', sans-serif; background: linear-gradient(135deg,#0a0e27 0%,#1a1f3a 100%); color:#e4e9f0; min-height:100vh; }

        /* Sidebar và Header giống dashboard */
        .sidebar { position: fixed; top:0; left:0; width:280px; height:100vh; background: linear-gradient(180deg,#0f1419 0%,#1a1f2e 100%); backdrop-filter: blur(10px); border-right:1px solid rgba(0,255,255,0.1); display:flex; flex-direction:column; padding:30px 0; box-shadow:5px 0 30px rgba(0,0,0,0.5); z-index:1000;}
        .sidebar-logo { text-align:center; margin-bottom:50px; padding:0 25px; }
        .sidebar-logo h2 { font-size:26px; font-weight:700; background: linear-gradient(135deg,#00d4ff 0%,#0099ff 100%); -webkit-background-clip:text; -webkit-text-fill-color:transparent; letter-spacing:1px; }
        .sidebar-logo p { font-size:11px; color:#6b7280; margin-top:5px; text-transform:uppercase; letter-spacing:2px; }
        .sidebar nav { flex:1; overflow-y:auto; }
        .sidebar a { color:#94a3b8; text-decoration:none; padding:16px 30px; display:flex; align-items:center; gap:15px; font-size:15px; font-weight:500; transition:all 0.3s cubic-bezier(0.4,0,0.2,1); position:relative; }
        .sidebar a.active { background: rgba(0,212,255,0.12); color:#00d4ff; padding-left:35px; }
        .sidebar a.logout { margin-top:auto; background: rgba(239,68,68,0.1); color:#ef4444; margin:20px 20px 0; border-radius:12px; justify-content:center; }

        header { margin-left:280px; background: rgba(15,20,25,0.8); backdrop-filter:blur(20px); border-bottom:1px solid rgba(0,255,255,0.1); padding:20px 40px; display:flex; justify-content:space-between; align-items:center; position:sticky; top:0; z-index:100; }
        header h1 { font-size:28px; font-weight:700; background: linear-gradient(135deg,#ffffff 0%,#00d4ff 100%); -webkit-background-clip:text; -webkit-text-fill-color:transparent; }
        .header-right { display:flex; align-items:center; gap:35px; }
        .header-right span { font-weight:500; color:#94a3b8; font-size:14px; display:flex; align-items:center; gap:8px; }

        .content { margin-left:280px; padding:40px; }

        /* Table Styles */
        .table-container { background: linear-gradient(135deg, rgba(15,20,25,0.9) 0%, rgba(26,31,46,0.9) 100%); backdrop-filter:blur(10px); border:1px solid rgba(0,255,255,0.15); border-radius:20px; padding:30px; margin-bottom:40px; overflow-x:auto; }
        table { width:100%; border-collapse:collapse; }
        th { background: rgba(0,212,255,0.08); color:#00d4ff; font-weight:600; text-transform:uppercase; font-size:12px; letter-spacing:1px; padding:15px; text-align:left; border-bottom:2px solid rgba(0,212,255,0.2); }
        td { padding:18px 15px; border-bottom:1px solid rgba(255,255,255,0.05); color:#94a3b8; font-size:14px; }
        tr:hover td { background: rgba(0,212,255,0.05); color:#e4e9f0; }

        .btn { padding:8px 15px; border:none; border-radius:6px; cursor:pointer; font-weight:500; font-size:14px; transition:0.3s; }
        .btn-add { background:#00d4ff; color:#fff; margin-bottom:15px; }
        .btn-add:hover { background:#0099ff; }
        .btn-edit { background:#10b981; color:#fff; }
        .btn-edit:hover { background:#0b7a5c; }
        .btn-delete { background:#ef4444; color:#fff; }
        .btn-delete:hover { background:#b91c1c; }
    </style>
</head>
<body>

    <!-- Sidebar -->
    <div class="sidebar">
        <div class="sidebar-logo">
            <h2>🎬 CINEMA PRO</h2>
            <p>Admin Panel</p>
        </div>
        <nav>
            <a href="${pageContext.request.contextPath}/admindashboard">📊 Bảng điều khiển</a>
            <a href="${pageContext.request.contextPath}/views/admin/userManager.jsp">👥 Quản lý người dùng</a>
            <a href="${pageContext.request.contextPath}/views/admin/staffManager.jsp">🧑‍💼 Quản lý nhân viên</a>
            <a href="${pageContext.request.contextPath}/views/admin/cinemaManager.jsp" class="active">🏢 Quản lý rạp</a>
            <a href="${pageContext.request.contextPath}/views/admin/paymentManager.jsp">💳 Quản lý thanh toán</a>
        </nav>
        <a href="${pageContext.request.contextPath}/logout" class="logout">🚪 Đăng xuất</a>
    </div>

    <!-- Header -->
    <header>
        <h1>Quản lý rạp</h1>
        <div class="header-right">
            <span>👤 Admin: Nguyễn Văn A</span>
            <span>⏰ <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %></span>
        </div>
    </header>

    <!-- Main content -->
    <div class="content">
        <button class="btn btn-add">➕ Thêm rạp mới</button>
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Id</th>
                        <th>Mã Rạp</th>
                        <th>Tên Rạp</th>
                        <th>Địa chỉ</th>
                        <th>Mô tả</th>
                        <th>Sức chứa</th>
                        <th>Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>1</td>
                        <td>C001</td>
                        <td>CGV Times City</td>
                        <td>458 Minh Khai, Hà Nội</td>
                        <td>Rạp hiện đại, đầy đủ phòng chiếu</td>
                        <td>300</td>
                        <td>
                            <button class="btn btn-edit">Sửa</button>
                            <button class="btn btn-delete">Xóa</button>
                        </td>
                    </tr>
                    <tr>
                        <td>2</td>
                        <td>L002</td>
                        <td>Lotte Hà Đông</td>
                        <td>229 Nguyễn Trãi, Hà Nội</td>
                        <td>Rạp tiêu chuẩn, ghế VIP</td>
                        <td>250</td>
                        <td>
                            <button class="btn btn-edit">Sửa</button>
                            <button class="btn btn-delete">Xóa</button>
                        </td>
                    </tr>
                    <!-- Thêm các rạp khác tại đây -->
                </tbody>
            </table>
        </div>
    </div>

</body>
</html>
