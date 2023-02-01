import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  connect() {
    console.log('Connected to forms controller');
  }

  initialize() {
    this.element.setAttribute('data-action', 'change->forms#handleChange');
  }

  getFields() {
    const symbol = document.getElementById('transaction_symbol');
    const price = document.getElementById('transaction_price');
    const commission = document.getElementById('transaction_commission');
    const fee = document.getElementById('transaction_fee');
    return [symbol, price, commission, fee];
  }

  hideFields() {
    this.getFields().forEach((field) => {
      field.removeAttribute('required');
      field.classList.add('hidden');
      if (field === document.getElementById('transaction_symbol')) field.setAttribute('value', 'Cash');
      if (field === document.getElementById('transaction_price')) field.setAttribute('value', '1');
      if (field === document.getElementById('transaction_commission')) field.setAttribute('value', '0');
      if (field === document.getElementById('transaction_fee')) field.setAttribute('value', '0');
    });
    const amount = document.getElementById('transaction_quantity');
    amount.setAttribute('placeholder', 'Amount');
  }

  showFields() {
    this.getFields().forEach((field) => {
      field.classList.remove('hidden');
      field.setAttribute('value', '');
      if (field === document.getElementById('transaction_symbol')) field.setAttribute('required', 'true');
      if (field === document.getElementById('transaction_price')) field.setAttribute('required', 'true');
    });
    const quantity = document.getElementById('transaction_quantity');
    quantity.setAttribute('placeholder', 'Quantity');
  }

  handleChange(event) {
    event.preventDefault();
    const selectedTransactionType = document.getElementById(
      'transaction_tr_type'
    );
    selectedTransactionType.value === 'Cash In' ||
    selectedTransactionType.value === 'Cash Out' ||
    selectedTransactionType.value === 'Interest Inc.' ||
    selectedTransactionType.value === 'Misc. Exp.'
      ? this.hideFields()
      : this.showFields();
  }
}
