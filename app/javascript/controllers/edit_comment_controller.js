import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["comment", "card", "form", "input"]

  connect() {
    console.log("comment connected");

    this.element.addEventListener("turbo:frame-load", this.resetFormVisibility.bind(this));
}

  disconnect() {
    // Clean up the event listener when the stimulus controller is disconnected
    this.element.removeEventListener("turbo:frame-load", this.resetFormVisibility.bind(this));
  }

  displayForm(event) {
    event.stopPropagation();
    this.commentTarget.classList.add('d-none');
    this.formTarget.classList.remove('d-none');
    this.inputTarget.focus();
  }

  preventCollapse(event) {
    event.stopPropagation();
  }

  update(event) {
    event.preventDefault();

    const url = this.formTarget.action;

    fetch(url, {
      method: 'PATCH',
      // headers: { 'Accept': 'text/html' },
      headers: { 'Accept': 'text/vnd.turbo-stream.html' },
      body: new FormData(this.formTarget)
    })
    .then(response => response.text())
    .then((html) => {
      console.log(html);
      // this.commentTarget.innerHTML = html;
      // this.commentTarget.classList.remove('d-none');
      // this.formTarget.classList.add('d-none');
    })
  }

  resetFormVisibility() {
    console.log("Resetting form visibility");
    // Ensure the comment is visible, and the form is hidden
    this.commentTarget.classList.remove('d-none');
    this.formTarget.classList.add('d-none');
  }
}
