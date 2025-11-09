<%@ page contentType="text/html;charset=UTF-8" %>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<style>
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }

    body {
        font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
        background: #f4f7fa;
        color: #2d3748;
        min-height: 100vh;
    }

    /* ===== Sidebar ===== */
    .sidebar {
        position: fixed;
        top: 0;
        left: 0;
        width: 280px;
        height: 100vh;
        background: #ffffff;
        border-right: 1px solid #e2e8f0;
        display: flex;
        flex-direction: column;
        padding: 30px 0;
        box-shadow: 2px 0 15px rgba(0, 0, 0, 0.05);
        z-index: 1000;
    }

    .sidebar-logo {
        text-align: center;
        margin-bottom: 50px;
        padding: 0 25px;
    }

    .sidebar-logo h2 {
        font-size: 26px;
        font-weight: 700;
        color: #1a202c;
        letter-spacing: 1px;
    }

    .sidebar-logo p {
        font-size: 11px;
        color: #6b7280;
        margin-top: 5px;
        text-transform: uppercase;
        letter-spacing: 2px;
    }

    .sidebar nav {
        flex: 1;
        overflow-y: auto;
    }

    .sidebar a {
        color: #4a5568;
        text-decoration: none;
        padding: 16px 30px;
        display: flex;
        align-items: center;
        gap: 15px;
        font-size: 15px;
        font-weight: 500;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        position: relative;
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
        padding-left: 35px;
    }

    .sidebar a.active::before {
        transform: scaleY(1);
    }

    .sidebar a.logout {
        margin-top: auto;
        background: rgba(239, 68, 68, 0.1);
        color: #ef4444;
        margin: 20px 20px 0;
        border-radius: 12px;
        justify-content: center;
    }

    .sidebar a.logout:hover {
        background: rgba(239, 68, 68, 0.2);
        padding-left: 30px;
    }

    /* ===== Header ===== */
    header {
        margin-left: 280px;
        background: rgba(255, 255, 255, 0.8);
        backdrop-filter: blur(20px);
        border-bottom: 1px solid #e2e8f0;
        padding: 20px 40px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        position: sticky;
        top: 0;
        z-index: 100;
    }

    header h1 {
        font-size: 28px;
        font-weight: 700;
        color: #1a202c;
    }

    .header-right {
        display: flex;
        align-items: center;
        gap: 35px;
    }

    .header-right span {
        font-weight: 500;
        color: #4a5568;
        font-size: 14px;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    /* ===== Content ===== */
    .content {
        margin-left: 280px;
        padding: 40px;
    }

    /* ===== Footer ===== */
    footer {
        background: #ffffff;
        border-top: 1px solid #e2e8f0;
        color: #6b7280;
        text-align: center;
        padding: 25px;
        margin-left: 280px;
        margin-top: 40px;
        font-size: 14px;
    }

    /* ===== Responsive ===== */
    @media (max-width: 768px) {
        .sidebar {
            width: 100%;
            height: auto;
            position: relative;
        }
        header, .content, footer {
            margin-left: 0;
        }
    }
</style>

