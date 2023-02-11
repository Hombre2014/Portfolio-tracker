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
    // These are hidden fields for dividend reinvestment transactions and stock splits by default
    const dividendPerShare = document.getElementById('transaction_div_per_share');
    const closingPrice = document.getElementById('transaction_closing_price');
    const newShares = document.getElementById('transaction_new_shares');
    const oldShares = document.getElementById('transaction_old_shares');
    const newSymbol = document.getElementById('transaction_new_symbol');
    if (transactionType === 'Common') return [commission, fee];
    if (transactionType === 'Cash') return [symbol, price, dividendPerShare];
    if (transactionType === 'Dividend') return [quantity, price];
    if (transactionType === 'All') return [symbol, quantity, price, commission, fee];
    if (transactionType === 'Uncommon') return [closingPrice, newShares, oldShares, newSymbol, dividendPerShare];
  }

  hideCommonFields() {
    this.getFields('Common').forEach((field) => {
      field.classList.add('hidden');
      field.setAttribute('value', 0);
    });
  }

  hideUncommonFields() {
    this.getFields('Uncommon').forEach((field) => {
      field.classList.add('hidden');
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
      if (field === document.getElementById('transaction_price')) field.setAttribute('value', '1');
    });
    // const price = document.getElementById('transaction_price');  
    // price.classList.remove('hidden');
    // price.setAttribute('required', 'true');
    // price.setAttribute('value', '');
    // price.setAttribute('placeholder', 'Dividend per share');
  }

  showFieldsForDivTransactions() {
    const dividendPerShare = document.getElementById('transaction_div_per_share');
    dividendPerShare.classList.remove('hidden');
    dividendPerShare.setAttribute('required', 'true');
    dividendPerShare.setAttribute('value', '');
    const symbol = document.getElementById('transaction_symbol');
    symbol.classList.remove('hidden');
    symbol.setAttribute('required', 'true');
    symbol.setAttribute('value', '');
  }

  showFieldsForReinvestDivTransactions() {
    const closingPrice = document.getElementById('transaction_closing_price');
    closingPrice.classList.remove('hidden');
    closingPrice.setAttribute('required', 'true');
    closingPrice.setAttribute('value', '');
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
        this.hideCommonFields();
        this.hideFieldsForDivTransactions();
        this.showFieldsForDivTransactions();
        break;
      case 'Reinvest Div.':
        this.hideCommonFields();
        this.hideFieldsForDivTransactions();
        this.showFieldsForDivTransactions();
        this.showFieldsForReinvestDivTransactions();
        break;
      default:
        this.showAllFields();
        this.hideUncommonFields();
    }
  }
}
