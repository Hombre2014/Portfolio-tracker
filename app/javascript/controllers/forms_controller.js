import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "toggleableSymbol",
    "toggleableQuantity",
    "toggleableCommission",
    "toggleableFee"
  ]

  initialize() {
    console.log("Initializing Stimulus!")
  }

  connect() {
    console.log("connected to forms controller")
  }

  handleChange() {
    const tr_type = document.getElementById('transaction_product_type')

    if (this.toggleableSymbolTarget.classList.contains('hidden')) {
      this.toggleableSymbolTarget.classList.toggle('hidden')
      this.toggleableQuantityTarget.classList.toggle('hidden')
      this.toggleableCommissionTarget.classList.toggle('hidden')
      this.toggleableFeeTarget.classList.toggle('hidden')
    }

    if (tr_type.value === 'Cash in' || tr_type.value === 'Cash out') {
      this.toggleableSymbolTarget.classList.toggle('hidden')
      this.toggleableQuantityTarget.classList.toggle('hidden')
      this.toggleableCommissionTarget.classList.toggle('hidden')
      this.toggleableFeeTarget.classList.toggle('hidden')
    }
  }
}
