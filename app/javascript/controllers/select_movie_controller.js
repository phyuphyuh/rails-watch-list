import { Controller } from "@hotwired/stimulus"
import debounce from "lodash.debounce";

export default class extends Controller {
  static targets = ["input", "results", "hiddenField", "form"];

  connect() {
    console.log("connected!");
    this.selectedMovies = [];
    this.debouncedSearch = debounce(this.search.bind(this), 300);
    this.inputTarget.addEventListener("input", this.debouncedSearch);
  }

  disconnect() {
    this.inputTarget.removeEventListener("input", this.debouncedSearch);
  }

  search(event) {
    event.preventDefault();

    const query = encodeURIComponent(this.inputTarget.value.trim());
    // const query = this.inputTarget.value.split(' ').join('+')
    if (query === "") {
      this.resultsTarget.innerHTML = "";
      return;
    }

    // const url = `/lists/new?query=${query}`;
    const url =  `${window.location.pathname}?query=${query}`
    console.log(url);

    fetch(url, { headers: { 'Accept': 'text/plain' } })
      .then(response => response.text())
      .then((data) => {
        this.resultsTarget.innerHTML = data;
      })
      .catch(error => console.error("Error fetching search results:", error));
  }

  addMovie(event) {
    event.preventDefault();

    const movieId = event.currentTarget.dataset.movieId;

    if (!this.selectedMovies.includes(movieId)) {
      this.selectedMovies.push(movieId);
      this.updateHiddenField();
      alert("Movie added!");
    }
  }

  updateHiddenField() {
    this.hiddenFieldTarget.value = this.selectedMovies.join(",");
  }

  saveTemporaryMovies(event) {
    event.preventDefault();

    this.updateHiddenField();

    const listId = this.formTarget.dataset.listId;

    if (listId) {
      this.selectedMovies.forEach((movieId) => {
        this.addBookmarkToList(listId, [movieId]);
      });
    } else {
      this.formTarget.submit();
    }

    this.selectedMovies = [];
  }

  addBookmarkToList(listId, movieIds) {
    const url = `lists/${listId}/bookmarks`;

    fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: JSON.stringify({ movie_ids: movieIds })
    })
      .then(response => response.json())
      .then((data) => {
        console.log(data);
        alert("Movie added to the list!");
      })
      .catch(error => console.error("Error adding movie:", error));
  }
}
