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
    const dividendPerShare = document.getElementById('transaction_div_per_share');
    const closingPrice = document.getElementById('transaction_closing_price');
    const newShares = document.getElementById('transaction_new_shares');
    const oldShares = document.getElementById('transaction_old_shares');
    const newSymbol = document.getElementById('transaction_new_symbol');
    if (transactionType === 'Common') return [commission, fee];
    if (transactionType === 'Cash') return [symbol, price, dividendPerShare, closingPrice, newShares, oldShares, newSymbol];
    if (transactionType === 'Dividend') return [quantity, price, newShares, oldShares, newSymbol];
    if (transactionType === 'Stock Split') return [quantity, price, dividendPerShare, closingPrice, newSymbol];
    if (transactionType === 'Symbol Change') return [quantity, price, dividendPerShare, closingPrice, newShares, oldShares];
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
      field.setAttribute('value', '');
      field.removeAttribute('required');
    });
  }

  showSymbolField() {
    const symbol = document.getElementById('transaction_symbol');
    symbol.classList.remove('hidden');
    symbol.setAttribute('required', 'true');
    symbol.setAttribute('value', '');
  }

  showNewSymbolField() {
    const newSymbol = document.getElementById('transaction_new_symbol');
    newSymbol.classList.remove('hidden');
    newSymbol.setAttribute('required', 'true');
    newSymbol.setAttribute('value', '');
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
    const closingPrice = document.getElementById('transaction_closing_price');
    closingPrice.classList.add('hidden');
  }

  hideFieldsForStockSplit() {
    this.getFields('Stock Split').forEach((field) => {
      field.removeAttribute('required');
      field.classList.add('hidden');
      if (field === document.getElementById('transaction_quantity')) field.setAttribute('value', '1');
      if (field === document.getElementById('transaction_price')) field.setAttribute('value', '1');
    });
    this.showSymbolField();
  }

  hideFieldsForSymbolChange() {
    this.getFields('Symbol Change').forEach((field) => {
      field.removeAttribute('required');
      field.classList.add('hidden');
    });
    this.showSymbolField();
    this.showNewSymbolField();
  }

  removeHidden(field) {
    field.classList.remove('hidden');
    field.setAttribute('required', 'true');
    field.setAttribute('value', '');
  }

  showFieldsForDivTransactions() {
    const dividendPerShare = document.getElementById('transaction_div_per_share');
    this.removeHidden(dividendPerShare);
    this.showSymbolField();
  }

  showFieldsForReinvestDivTransactions() {
    const closingPrice = document.getElementById('transaction_closing_price');
    this.removeHidden(closingPrice);
  }

  showFieldsForStockSplit() {
    const newShares = document.getElementById('transaction_new_shares');
    this.removeHidden(newShares);
    const oldShares = document.getElementById('transaction_old_shares');
    this.removeHidden(oldShares);
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
      case 'Stock Split':
        this.hideCommonFields();
        this.hideFieldsForStockSplit();
        this.showFieldsForStockSplit();
        break;
      case 'Symbol Change':
        this.hideCommonFields();
        this.hideFieldsForSymbolChange();
        break;
      default:
        this.showAllFields();
        this.hideUncommonFields();
    }
  }
}
