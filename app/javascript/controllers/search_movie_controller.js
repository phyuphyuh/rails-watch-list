import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results"];

  connect() {
    console.log("connected!");
  }

  search(event) {
    event.preventDefault();

     // const query = this.inputTarget.value.trim();
    const query = encodeURIComponent(this.inputTarget.value.trim());
    // const query = this.inputTarget.value.split(' ').join('+')
    if (query === "") return;

    // const url = `/lists/new?query=${query}`;
    const url =  `${window.location.pathname}?query=${query}`
    console.log(url);

    fetch(url, { headers: { 'Accept': 'text/plain' } })
      .then(response => response.text())
      .then((data) => {
        console.log("Received data:", data);
        this.resultsTarget.innerHTML = data;
      })
      .catch(error => console.error("Error fetching search results:", error));
  }

}
