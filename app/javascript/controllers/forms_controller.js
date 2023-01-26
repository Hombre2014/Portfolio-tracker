import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    console.log("Connected to forms controller");
  }

  initialize() {
    this.element.setAttribute("data-action", "change->forms#handleChange")
  }

  cashTransactions() {
    const symbol = document.getElementById('transaction_symbol');
    const price = document.getElementById('transaction_price');
    const commission = document.getElementById('transaction_commission');
    const fee = document.getElementById('transaction_fee');
    const amount = document.getElementById('transaction_quantity');
    symbol.classList.add('hidden');
    price.classList.add('hidden');
    commission.classList.add('hidden');
    fee.classList.add('hidden');
    amount.setAttribute('placeholder', 'Amount');
  }

  handleChange(event) {
    event.preventDefault();
    const selectedTransactionType = document.getElementById('transaction_tr_type');
    
    if (selectedTransactionType.value === 'Cash In' || selectedTransactionType.value === 'Cash Out') {
      this.cashTransactions();
    } else {
      const symbol = document.getElementById('transaction_symbol');
      const price = document.getElementById('transaction_price');
      const commission = document.getElementById('transaction_commission');
      const fee = document.getElementById('transaction_fee');
      const amount = document.getElementById('transaction_quantity');
      symbol.classList.remove('hidden');
      price.classList.remove('hidden');
      commission.classList.remove('hidden');
      fee.classList.remove('hidden');
      amount.setAttribute('placeholder', 'Quantity');
    }
  }
}
