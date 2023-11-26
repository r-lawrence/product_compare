import { showHideToggle } from "./helpers"

const ProductContainer = {
  mounted() {

    showHideToggle(this.el, ".toggle-features", ".feature-list", "Show Features", "Hide Features")
  }
}

export default ProductContainer