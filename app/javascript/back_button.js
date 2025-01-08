document.addEventListener("DOMContentLoaded", () => {
  const backLink = document.getElementById("backLink");

  if (backLink) {
    backLink.addEventListener("click", (event) => {
      event.preventDefault();
      console.log("Referrer:", document.referrer);
      if (document.referrer) {
        window.history.back();
      } else {
        window.location.href = "/lists";
      }
    });
  }
});
