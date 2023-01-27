import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    console.log("Connected to forms controller");
  }

  initialize() {
    this.element.setAttribute("data-action", "change->forms#handleChange")
  }

  getFields() {
    const symbol = document.getElementById('transaction_symbol');
    const price = document.getElementById('transaction_price');
    const commission = document.getElementById('transaction_commission');
    const fee = document.getElementById('transaction_fee');
    return [symbol, price, commission, fee];
  }

  toggleAmount() {
    const amount = document.getElementById('transaction_quantity');
    amount.getAttribute('placeholder') === 'Quantity' ? amount.setAttribute('placeholder', 'Amount') : amount.setAttribute('placeholder', 'Quantity');
  }

  hideFields() {
    this.getFields().forEach((field) => {
      field.removeAttribute('required');
      field.classList.add('hidden');
      if (field === document.getElementById('transaction_symbol')) {
        field.setAttribute('value', 'Cash');
      }
      if (field === document.getElementById('transaction_price')) {
        field.setAttribute('value', '1');
      }
      if (field === document.getElementById('transaction_commission')) {
        field.setAttribute('value', '0');
      }
      if (field === document.getElementById('transaction_fee')) {
        field.setAttribute('value', '0');
      }
    });
    this.toggleAmount();
  }

  showFields() {
    this.getFields().forEach((field) => {
      field.classList.remove('hidden');
      if (field === document.getElementById('transaction_symbol')) {
        field.setAttribute('value', '');
        field.setAttribute('required', 'true');
      }
      if (field === document.getElementById('transaction_price')) {
        field.setAttribute('value', '');
        field.setAttribute('required', 'true');
      }
      if (field === document.getElementById('transaction_commission')) {
        field.setAttribute('value', '');
      }
      if (field === document.getElementById('transaction_fee')) {
        field.setAttribute('value', '');
      }
    });
    this.toggleAmount();
  }

  handleChange(event) {
    event.preventDefault();
    const selectedTransactionType = document.getElementById('transaction_tr_type');
    selectedTransactionType.value === 'Cash In' || selectedTransactionType.value === 'Cash Out' ? this.hideFields() : this.showFields();
  }
}
