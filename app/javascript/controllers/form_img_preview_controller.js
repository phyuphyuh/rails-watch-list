import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview"];

  preview() {
    const file = this.inputTarget.files[0];
    if (file) {
      const reader = new FileReader();

      reader.onload = (event) => {
        let image = this.previewTarget.querySelector("img");
        if (!image) {
          image = document.createElement("img");
          image.style.maxWidth = "260px";
          this.previewTarget.appendChild(image);
        }
        // this.previewTarget.setAttribute('src', event.target.result);
        image.src = event.target.result;
      };

      reader.readAsDataURL(file);
    }
  }

}
