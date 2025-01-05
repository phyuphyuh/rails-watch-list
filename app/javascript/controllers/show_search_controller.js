import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["searchSection"]

  connect() {
    console.log("show search connected");
  }

  displaySearch() {
    this.searchSectionTarget.classList.toggle('d-none');
  }
}
