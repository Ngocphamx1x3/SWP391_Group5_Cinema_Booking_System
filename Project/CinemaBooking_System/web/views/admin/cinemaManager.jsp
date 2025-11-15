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
        body { 
            font-family: 'Inter', sans-serif; 
            background: #f4f7fa; 
            color: #2d3748; 
            min-height:100vh; 
        }

        /* Sidebar và Header giống dashboard */
        .sidebar { 
            position: fixed; 
            top:0; 
            left:0; 
            width:280px; 
            height:100vh; 
            background: #ffffff; 
            border-right:1px solid #e2e8f0; 
            display:flex; 
            flex-direction:column; 
            padding:30px 0; 
            box-shadow: 2px 0 15px rgba(0, 0, 0, 0.05); 
            z-index:1000;
        }
        .sidebar-logo { text-align:center; margin-bottom:50px; padding:0 25px; }
        .sidebar-logo h2 { 
            font-size:26px; 
            font-weight:700; 
            color: #1a202c; 
            background: none; 
            -webkit-background-clip:unset; 
            -webkit-text-fill-color:unset; 
            letter-spacing:1px; 
        }
        .sidebar-logo p { font-size:11px; color:#6b7280; margin-top:5px; text-transform:uppercase; letter-spacing:2px; }
        .sidebar nav { flex:1; overflow-y:auto; }
        .sidebar a { 
            color:#4a5568; 
            text-decoration:none; 
            padding:16px 30px; 
            display:flex; 
            align-items:center; 
            gap:15px; 
            font-size:15px; 
            font-weight:500; 
            transition:all 0.3s cubic-bezier(0.4,0,0.2,1); 
            position:relative; 
        }
         .sidebar a::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            height: 100%;
            width: 4px;
            background: linear-gradient(180deg, #00d4ff 0%, #0099ff 100%);
            transform: scaleY(0);
            transition: transform 0.3s ease;
        }

        .sidebar a:hover {
            background: #e6f7ff; 
            color: #007bff; 
            padding-left: 35px;
        }

        .sidebar a:hover::before {
            transform: scaleY(1);
        }
        
        .sidebar a.active { 
            background: #e6f7ff; 
            color: #007bff; 
            padding-left:35px; 
        }
        
        .sidebar a.active::before {
             transform: scaleY(1);
        }
        
        .sidebar a.logout { 
            margin-top:auto; 
            background: rgba(239,68,68,0.1); 
            color:#ef4444; 
            margin:20px 20px 0; 
            border-radius:12px; 
            justify-content:center; 
        }
         .sidebar a.logout:hover {
            background: rgba(239, 68, 68, 0.2);
        }

        header { 
            margin-left:280px; 
            background: rgba(255, 255, 255, 0.8); 
            backdrop-filter:blur(20px); 
            border-bottom:1px solid #e2e8f0; 
            padding:20px 40px; 
            display:flex; 
            justify-content:space-between; 
            align-items:center; 
            position:sticky; 
            top:0; 
            z-index:100; 
        }
        header h1 { 
            font-size:28px; 
            font-weight:700; 
            color: #1a202c; 
            background: none; 
            -webkit-background-clip:unset; 
            -webkit-text-fill-color:unset; 
        }
        .header-right { display:flex; align-items:center; gap:35px; }
        .header-right span { 
            font-weight:500; 
            color:#4a5568; 
            font-size:14px; 
            display:flex; 
            align-items:center; 
            gap:8px; 
        }

        .content { margin-left:280px; padding:40px; }

        /* Table Styles */
        .table-container { 
            background: #ffffff; 
            border:1px solid #e2e8f0; 
            border-radius:20px; 
            padding:30px; 
            margin-bottom:40px; 
            overflow-x:auto; 
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.05);
        }
        table { width:100%; border-collapse:collapse; }
        th { 
            background: #f8f9fa; 
            color: #4a5568; 
            font-weight:600; 
            text-transform:uppercase; 
            font-size:12px; 
            letter-spacing:1px; 
            padding:15px; 
            text-align:left; 
            border-bottom:2px solid #dee2e6; 
        }
        td { 
            padding:18px 15px; 
            border-bottom:1px solid #e2e8f0; 
            color: #2d3748; 
            font-size:14px; 
        }
        tr:hover td { 
            background: #f8f9fa; 
            color: #1a202c; 
        }

        .btn { 
            padding:8px 15px; 
            border:none; 
            border-radius:6px; 
            cursor:pointer; 
            font-weight:500; 
            font-size:14px; 
            transition:0.3s; 
            text-decoration: none;
        }
        .btn-add { 
            background: linear-gradient(135deg, #00d4ff 0%, #0099ff 100%);
            color:#fff; 
            margin-bottom:15px; 
            border-radius: 12px;
            padding: 12px 28px;
            font-weight: 600;
        }
        .btn-add:hover { 
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(0, 123, 255, 0.3);
        }
        .btn-edit { 
            background: rgba(0, 123, 255, 0.2);
            color: #007bff;
            border: 1px solid rgba(0, 123, 255, 0.3);
        }
        .btn-edit:hover { 
            background: rgba(0, 123, 255, 0.3);
            transform: translateY(-2px);
        }
        .btn-delete { 
            background: rgba(239, 68, 68, 0.2);
            color: #ef4444;
            border: 1px solid rgba(239, 68, 68, 0.3);
        }
        .btn-delete:hover { 
            background: rgba(239, 68, 68, 0.3);
            transform: translateY(-2px);
        }
    </style>
</head>
<body>

    <div class="sidebar">
        <div class="sidebar-logo">
            <h2>CINEMA PRO</h2>
            <p>Admin Panel</p>
        </div>
        <nav>
            <a href="${pageContext.request.contextPath}/admindashboard">Bảng điều khiển</a>
            <a href="${pageContext.request.contextPath}/views/admin/userManager.jsp">Quản lý người dùng</a>
            <a href="${pageContext.request.contextPath}/views/admin/staffManager.jsp">Quản lý nhân viên</a>
            <a href="${pageContext.request.contextPath}/admin/cinemas">Quản lý rạp</a>
            <a href="${pageContext.request.contextPath}/admin/movies">Quản lý phim</a>
            <a href="${pageContext.request.contextPath}/admin/seat-types">Quản lý loại ghế</a>
            <a href="${pageContext.request.contextPath}/views/admin/paymentManager.jsp">Quản lý thanh toán</a>
            <a href="${pageContext.request.contextPath}/admin/vouchers">Quản lý Voucher</a>
        </nav>
        <a href="${pageContext.request.contextPath}/logout" class="logout">Đăng xuất</a>
    </div>

    <header>
        <h1>Quản lý rạp</h1>
        <div class="header-right">
            <span>Admin: Nguyễn Văn A</span>
            <span><%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %></span>
        </div>
    </header>

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
                    </tbody>
            </table>
        </div>
    </div>
    
    <footer style="
        background: #ffffff;
        border-top: 1px solid #e2e8f0;
        color: #6b7280;
        text-align: center;
        padding: 25px;
        margin-left: 280px;
        margin-top: 40px;
        font-size: 14px;
    ">
        © 2025 Cinema Booking System - Admin Panel | Powered by Modern Technology
    </footer>

</body>
</html>