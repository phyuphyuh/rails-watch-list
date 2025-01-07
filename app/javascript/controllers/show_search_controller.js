import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["searchSection", "searchInput", "addButton"]

  connect() {
    console.log("show search connected");
  }

  expand(event) {
    event.currentTarget.classList.add("expanded");
  }

  shrink(event) {
    event.currentTarget.classList.remove("expanded");
  }

  displaySearch(event) {
    // this.searchSectionTarget.classList.remove('d-none');
    this.searchSectionTarget.classList.add('active');
    this.searchInputTarget.focus();
    event.currentTarget.classList.add('d-none');
  }

  closeSearch() {
    // this.searchSectionTarget.classList.add('d-none');
    this.searchSectionTarget.classList.remove('active');
    this.addButtonTarget.classList.remove('d-none');
  }
}
