import { Controller } from "@hotwired/stimulus"
import debounce from "lodash.debounce";
console.log(debounce);

export default class extends Controller {
  static targets = ["input", "results", "hiddenField", "form", "selectedMovies"];

  connect() {
    console.log("connected!");
    this.selectedMovies = [];
    this.debouncedSearch = debounce(this.search.bind(this), 500);
    this.inputTarget.addEventListener("input", this.debouncedSearch);

    if (this.hiddenFieldTarget.value) {
      this.selectedMovies = this.hiddenFieldTarget.value.split(",");
      this.selectedMovies.forEach((movieId) => {
        this.displaySelectedMovie(movieId, movieTitle);
      });
    }
  }

  disconnect() {
    this.inputTarget.removeEventListener("input", this.debouncedSearch);
  }

  search(event) {
    event.preventDefault();

    const query = encodeURIComponent(this.inputTarget.value.trim());
    // const query = this.inputTarget.value.split(' ').join('+')
    if (query.length === 0) {
      this.resultsTarget.innerHTML = "";
      return;
    }

    // const url = `/lists/new?query=${query}`;
    // const url =  `${window.location.pathname}?query=${query}`
    const currentAction = document.getElementById("current-action").value;
    console.log(currentAction);
    const url = currentAction === "new" ? `/lists/new?query=${query}` : `${window.location.pathname}?query=${query}`;

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
    const movieTitle = event.currentTarget.dataset.movieTitle;
    const currentAction = document.getElementById("current-action").value;

    if (currentAction === "new") {
      // add as tags
      if (!this.selectedMovies.includes(movieId)) {
        this.selectedMovies.push(movieId);
        this.displaySelectedMovie(movieId, movieTitle);
        this.inputTarget.classList.add("m-2");
        this.updateHiddenField();
      }
    } else if (currentAction === "show") {
      // directly as bookmarks
      const listId = event.currentTarget.dataset.listId;
      console.log(listId);
      if (listId && movieId) {
        this.addBookmarkToList(listId, [movieId]);
      }
    }
  }

  updateHiddenField() {
    this.hiddenFieldTarget.value = this.selectedMovies.join(",");
  }

  saveSelectedMovies(event) {
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
    // const url = `lists/${listId}/bookmarks`;
    const url = `${window.location.pathname}/bookmarks`;
    const csrfToken = document.querySelector("meta[name='csrf-token']").content;

    fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": csrfToken,
      },
      body: JSON.stringify({ movie_ids: movieIds })
    })
      .then(response => response.json())
      .then((data) => {
        console.log("Bookmarks received from server:", data.bookmarks);
        this.displayBookmarks(data.bookmarks);
      })
      .catch(error => console.error("Error adding movie:", error));
  }

  displayBookmarks(bookmarks) {
    const bookmarksContainer = document.querySelector(".list-bookmarks");

    bookmarks.forEach((bookmark) => {
      const existingCard = bookmarksContainer.querySelector(`[data-movie-id="${bookmark.movie.api_id}"]`);
      console.log(existingCard);
      if (!existingCard) {
        const poster = bookmark.movie.poster_url || "/assets/images/no_image.jpg";
        const genres = bookmark.movie.genres.join(", ");

        const bookmarkCard = `
          <div class="card-movie"
              data-movie-id="${bookmark.movie.api_id}"
              data-movie-title="${bookmark.movie.title}"
              data-action="click->expand-card#toggle"
              data-controller="edit-comment"
              data-edit-comment-target="card">
            <div class="flip-card">
              <div class="front-poster">
                <img src="${poster}" alt="${bookmark.movie.title}">
              </div>
              <div class="view-details">
                <span></span>
              </div>
            </div>
            <div class="movie-details">
              <div class="d-flex justify-content-between align-items-center">
                <div class="details-left">
                  <img src="${poster}" alt="${bookmark.movie.title}">
                </div>
                <div class="details-right d-flex flex-column mx-3">
                  <div class="d-flex align-items-baseline">
                    <h3>${bookmark.movie.title}</h3>
                    <span class="date ms-2">${bookmark.movie.release_date}</span>
                  </div>
                  <div class="duration-genres d-flex">
                    <p>
                      <span class="duration">${bookmark.movie.runtime/60}h ${bookmark.movie.runtime % 60}m</span> &#8226;
                       ${genres}
                    </p>
                  </div>
                  <div class="overview">
                    <p>${bookmark.movie.overview}</p>
                  </div>
                </div>
              </div>

            </div>
          </div>
        `;

        bookmarksContainer.insertAdjacentHTML("beforeend", bookmarkCard);
      }
    })
  }

  displaySelectedMovie(movieId, movieTitle) {
    const tag = document.createElement("span");
    tag.className = "movie-tag";
    tag.dataset.movieId = movieId;
    tag.innerHTML = `
      ${movieTitle}
      <button type="button" data-movie-id="${movieId}" data-action="click->select-movie#removeMovie">x</button>
    `;
    this.selectedMoviesTarget.appendChild(tag);
  }

  removeMovie(event) {
    const movieId = event.currentTarget.dataset.movieId;

    this.selectedMovies = this.selectedMovies.filter(id => id !== movieId);

    const tag = this.selectedMoviesTarget.querySelector(`[data-movie-id="${movieId}"]`);
    if (tag) tag.remove();

    this.updateHiddenField();

    if (this.selectedMovies.length === 0) {
      this.inputTarget.classList.remove("m-2");
      this.hiddenFieldTarget.value = "";
    }
  }
}
