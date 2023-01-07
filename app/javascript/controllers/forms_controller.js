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
    if (this.toggleableSymbolTarget.classList.contains('hidden') || transactionTypeCondition()) {
      hideOrShowFields
    }
  }

  transactionTypeCondition() {
    const transaction_type = document.getElementById('transaction_product_type')

    transaction_type.value === 'Cash in' || transaction_type.value === 'Cash out'
  }

  hideOrShowFields() {
    this.toggleableSymbolTarget.classList.toggle('hidden')
    this.toggleableQuantityTarget.classList.toggle('hidden')
    this.toggleableCommissionTarget.classList.toggle('hidden')
    this.toggleableFeeTarget.classList.toggle('hidden')
  }
}
