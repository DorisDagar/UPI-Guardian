/**
 * UPI Guardian - Dashboard auth guard
 * Redirects to login.html if nobody is signed in, then greets the
 * user by name and wires up the logout button.
 */
(function () {
  document.addEventListener("DOMContentLoaded", init);

  async function init() {
    if (!window.UPIGuardianAuth) return;

    const user = await window.UPIGuardianAuth.requireAuth();
    if (!user) return; // requireAuth() already redirected to login.html

    const fullName = (user.user_metadata && user.user_metadata.full_name) || "there";
    const firstName = fullName.split(" ")[0];

    const heading = document.getElementById("welcomeHeading");
    const userName = document.getElementById("userName");
    const userInitial = document.getElementById("userInitial");
    if (heading) heading.textContent = `${greeting()}, ${firstName}! 👋`;
    if (userName) userName.textContent = firstName;
    if (userInitial) userInitial.textContent = firstName.charAt(0).toUpperCase();

    const userMenu = document.getElementById("userMenu");
    const userDropdown = document.getElementById("userDropdown");
    const logoutButton = document.getElementById("logoutButton");

    if (userMenu && userDropdown) {
      userMenu.addEventListener("click", (e) => {
        e.stopPropagation();
        userDropdown.hidden = !userDropdown.hidden;
      });
      document.addEventListener("click", () => {
        userDropdown.hidden = true;
      });
    }

    if (logoutButton) {
      logoutButton.addEventListener("click", async (e) => {
        e.stopPropagation();
        await window.UPIGuardianAuth.signOut();
        window.location.href = "login.html";
      });
    }
  }

  function greeting() {
    const hour = new Date().getHours();
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }
})();
