// Wait for DOM to load
document.addEventListener("DOMContentLoaded", function () {
  const saveBtn = document.getElementById("save-ip-btn");

  // Check if button exists (it's inside an % if % block)
  if (saveBtn) {
    saveBtn.addEventListener("click", function () {
      const ipAddress = "{{ ip }}";
      const btn = this;

      btn.disabled = true;
      btn.innerHTML = '<i class="bi bi-hourglass-split"></i> Saving...';

      fetch("/save_ip", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ ip: ipAddress }),
      })
        .then((response) => response.json()) // This parses the jsonify() from Python
        .then((data) => {
          if (data.status === "success") {
            btn.className = "btn btn-success btn-sm";
            btn.innerHTML = '<i class="bi bi-check-lg"></i> Saved to DB';
          } else {
            alert("Error: " + data.message);
            btn.disabled = false;
            btn.innerHTML = "Try Again";
          }
        })
        .catch((error) => {
          console.error("Fetch Error:", error);
          btn.disabled = false;
        });
    });
  }
});
