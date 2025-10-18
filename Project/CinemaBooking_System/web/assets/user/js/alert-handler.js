/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */
// Auto-hide alert messages after 3 seconds

document.addEventListener("DOMContentLoaded", function () {
    const modal = document.getElementById("changePasswordModal");
    const openBtn = document.getElementById("changePasswordBtn");
    const closeBtn = document.getElementById("closeModal");
    const cancelBtn = document.getElementById("cancelBtn");
    const form = document.getElementById("changePasswordForm");
    const messageBox = document.createElement("div");
    form.prepend(messageBox);

    openBtn.onclick = () => modal.style.display = "block";
    closeBtn.onclick = () => modal.style.display = "none";
    cancelBtn.onclick = () => modal.style.display = "none";
    window.onclick = (e) => { if (e.target === modal) modal.style.display = "none"; };

    form.addEventListener("submit", async (e) => {
        e.preventDefault();

        const formData = new FormData(form);
        try {
            const response = await fetch(form.action, {
                method: "POST",
                body: formData
            });

            const result = await response.json();

            if (result.status === "error") {
                messageBox.innerHTML = `<div class="alert alert-danger">${result.message}</div>`;
            } else {
                messageBox.innerHTML = `<div class="alert alert-success">${result.message}</div>`;
                setTimeout(() => {
                    modal.style.display = "none";
                    form.reset();
                    messageBox.innerHTML = "";
                }, 2000);
            }
        } catch (error) {
            console.error("Lỗi khi gửi yêu cầu:", error);
            messageBox.innerHTML = `<div class="alert alert-danger">Lỗi kết nối máy chủ!</div>`;
        }
    });
});



