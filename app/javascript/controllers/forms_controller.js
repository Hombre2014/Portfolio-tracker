import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  connect() {
    console.log('Connected to forms controller');
  }

  initialize() {
    this.element.setAttribute('data-action', 'change->forms#handleChange');
  }

  getFields(transactionType) {
    const symbol = document.getElementById('transaction_symbol');
    const quantity = document.getElementById('transaction_quantity');
    const price = document.getElementById('transaction_price');
    const commission = document.getElementById('transaction_commission');
    const fee = document.getElementById('transaction_fee');
    if (transactionType === 'Common') return [commission, fee];
    if (transactionType === 'Cash') return [symbol, price];
    if (transactionType === 'Dividend') return [quantity];
    if (transactionType === 'All') return [symbol, quantity, price, commission, fee];
  }

  hideCommonFields() {
    this.getFields('Common').forEach((field) => {
      field.classList.add('hidden');
      field.setAttribute('value', 0);
    });
  }

  hideFieldsForCashTransactions() {
    this.getFields('Cash').forEach((field) => {
      field.removeAttribute('required');
      field.classList.add('hidden');
      if (field === document.getElementById('transaction_symbol')) field.setAttribute('value', 'Cash');
      if (field === document.getElementById('transaction_price')) field.setAttribute('value', '1');
    });
    const amount = document.getElementById('transaction_quantity');
    amount.classList.remove('hidden');
    amount.setAttribute('placeholder', 'Amount');
    amount.setAttribute('required', 'true');
    amount.setAttribute('value', '');
  }

  hideFieldsForDivTransactions() {
    this.getFields('Dividend').forEach((field) => {
      field.removeAttribute('required');
      field.classList.add('hidden');
      if (field === document.getElementById('transaction_quantity')) field.setAttribute('value', '1');
    });
    const symbol = document.getElementById('transaction_symbol');
    symbol.classList.remove('hidden');
    symbol.setAttribute('required', 'true');
    symbol.setAttribute('value', '');
    const price = document.getElementById('transaction_price');  
    price.classList.remove('hidden');
    price.setAttribute('required', 'true');
    price.setAttribute('value', '');
    price.setAttribute('placeholder', 'Dividend per share');
  }

  showAllFields() {
    this.getFields('All').forEach((field) => {
      field.classList.remove('hidden');
      field.setAttribute('value', '');
      if (field === document.getElementById('transaction_symbol')) field.setAttribute('required', 'true');
      if (field === document.getElementById('transaction_price')) {
        field.setAttribute('required', 'true');
        field.setAttribute('placeholder', 'Price');
      }
      if (field === document.getElementById('transaction_quantity')) {
        field.setAttribute('required', 'true');
        field.setAttribute('placeholder', 'Quantity');
      }
    });
  }

  handleChange(event) {
    event.preventDefault();
    const selectedTransactionType = document.getElementById('transaction_tr_type');
    switch(selectedTransactionType.value) {
      case 'Cash In':
      case 'Cash Out':
      case 'Interest Inc.':
      case 'Misc. Exp.':
        this.hideCommonFields();
        this.hideFieldsForCashTransactions();
        break;
      case 'Dividend':
      case 'Reinvest Div.':
        this.hideCommonFields();
        this.hideFieldsForDivTransactions();
        break;
      default:
        this.showAllFields();
    }
  }
}
