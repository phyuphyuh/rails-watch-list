import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card"];
  // static values = { id: Number };

  connect() {
    this.expandedCard = null;
  }

  toggle(event) {
    const clickedCard = event.currentTarget;

    if (this.expandedCard) {
      this.expandedCard.classList.remove("expanded");
    }

    if (this,this.expandedCard !== clickedCard) {
      clickedCard.classList.add("expanded");
      this.expandedCard = clickedCard;
    } else {
      this.expandedCard = null;
    }
  }

}
