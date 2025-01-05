import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["searchSection", "searchInput"]

  connect() {
    console.log("show search connected");
  }

  displaySearch() {
    this.searchSectionTarget.classList.toggle('d-none');
    // this.searchInputTarget.classList.toggle('autofocus');
    this.searchInputTarget.focus();

  }
}
