import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]

  connect() {
    console.log("sticky nav connected");
  }

  changeOpacity() {
    const bgOpacity = window.scrollY > 0 ? "rgba(243, 255, 122, 0.5)" : "rgba(243, 255, 122, 1)";
    this.buttonTargets.forEach((button) => {
      button.style.backgroundColor = bgOpacity;
    });
  }

  hover(event) {
    if (event.type === "mouseenter") {
      event.currentTarget.style.backgroundColor = "transparent";
    } else if (event.type === "mouseleave")
      event.currentTarget.style.backgroundColor = "revert-layer";
  }
}
