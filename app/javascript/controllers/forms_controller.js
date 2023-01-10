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

  transactionTypeCondition(event) {
    const transaction_type = document.getElementById('transaction_product_type');
    transaction_type.addEventListener('change', this.handleChange);


    console.log('Transaction type: ', transaction_type.event.target.value);
    transaction_type.event.target.value === 'Cash in' || transaction_type.event.target.value === 'Cash out'
  }

  handleChange() {
    if (this.toggleableSymbolTarget.classList.contains('hidden') || transactionTypeCondition(event)) {
      hideOrShowFields;
    }
  }

  hideOrShowFields() {
    this.toggleableSymbolTarget.classList.toggle('hidden')
    this.toggleableQuantityTarget.classList.toggle('hidden')
    this.toggleableCommissionTarget.classList.toggle('hidden')
    this.toggleableFeeTarget.classList.toggle('hidden')
  }
}
