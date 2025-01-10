import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["comment", "card", "form", "input"]

  connect() {
    console.log("comment connected");
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
      headers: { 'Accept': 'text/html' },
      body: new FormData(this.formTarget)
    })
      .then(response => response.text())
      .then((data) => {
        console.log(data);
        this.commentTarget.innerHTML = data;
        this.commentTarget.classList.remove('d-none');
        this.formTarget.classList.add('d-none');
      })
  }
}
