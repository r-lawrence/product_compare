import { showHideToggle } from "./helpers"

const ReviewSummaryContainer = {
  mounted() {
    showHideToggle(this.el, ".toggle-user-likes", ".user-likes-dislikes", "Show Summary", "Hide Summary")
  }
}

export default ReviewSummaryContainer
