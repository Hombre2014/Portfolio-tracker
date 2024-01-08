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

  addHidden(field) {
    field.classList.add('hidden');
    field.removeAttribute('required');
  }

  hideUncommonFields() {
    this.getFields('Uncommon').forEach((field) => {
      this.addHidden(field);
      field.setAttribute('value', '');
    });
  }

  showField(fieldName) {
    const field = document.getElementById(fieldName);
    field.classList.remove('hidden');
    field.setAttribute('required', 'true');
    field.setAttribute('value', '');
  }

  removeHidden(field) {
    field.classList.remove('hidden');
    field.setAttribute('required', 'true');
    field.setAttribute('value', '');
  }

  hideFieldsForCashTransactions() {
    this.getFields('Cash').forEach((field) => {
      this.addHidden(field);
      if (field === document.getElementById('transaction_symbol')) field.setAttribute('value', 'Cash');
      if (field === document.getElementById('transaction_price')) field.setAttribute('value', '1');
    });
    const amount = document.getElementById('transaction_quantity');
    this.removeHidden(amount);
    amount.setAttribute('placeholder', 'Amount');
  }

  setFieldsForNoneCashTransactions(field) {
    if (field === document.getElementById('transaction_quantity')) field.setAttribute('value', '1');
    if (field === document.getElementById('transaction_price')) field.setAttribute('value', '1');
  }

  hideFieldsForDivTransactions() {
    this.getFields('Dividend').forEach((field) => {
      this.addHidden(field);
      this.setFieldsForNoneCashTransactions(field);
    });
    const closingPrice = document.getElementById('transaction_closing_price');
    closingPrice.classList.add('hidden');
  }

  hideFieldsForStockSplit() {
    this.getFields('Stock Split').forEach((field) => {
      this.addHidden(field);
      this.setFieldsForNoneCashTransactions(field);
    });
    this.showField('transaction_symbol');
  }

  hideFieldsForSymbolChange() {
    this.getFields('Symbol Change').forEach((field) => {
      this.addHidden(field);
      this.setFieldsForNoneCashTransactions(field);
    });
    this.showField('transaction_symbol');
    this.showField('transaction_new_symbol');
  }

  showFieldsForDivTransactions() {
    const dividendPerShare = document.getElementById('transaction_div_per_share');
    this.removeHidden(dividendPerShare);
    this.showField('transaction_symbol');
  }

  showFieldsForReinvestDivTransactions() {
    const closingPrice = document.getElementById('transaction_closing_price');
    this.removeHidden(closingPrice);
  }

  showAllFields() {
    this.getFields('All').forEach((field) => {
      field.classList.remove('hidden');
      field.setAttribute('value', '');
      if (field === document.getElementById('transaction_symbol')) field.setAttribute('required', 'true');
      if (field === document.getElementById('transaction_price')) {
        field.setAttribute('required', 'true');
        field.setAttribute('placeholder', 'Price');
        field.setAttribute('min', '0.000001');
      }
      if (field === document.getElementById('transaction_quantity')) {
        field.setAttribute('required', 'true');
        field.setAttribute('placeholder', 'Quantity');
      }
    });
  }

  handleSharesIn() {
    const price = document.getElementById('transaction_price');
    price.setAttribute('placeholder', 'Cost per share');
    price.removeAttribute('min');
  }

  handleSharesOut() {
    const price = document.getElementById('transaction_price');
    price.setAttribute('placeholder', 'Cost per share (see portfolio)');
  }

  handleChange(event) {
    event.preventDefault();
    const selectedTransactionType = document.getElementById('transaction_tr_type');
    switch (selectedTransactionType.value) {
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
        this.showField('transaction_new_shares');
        this.showField('transaction_old_shares');
        break;
      case 'Symbol Change':
        this.hideCommonFields();
        this.hideFieldsForSymbolChange();
        break;
      case 'Shares in':
        this.showAllFields();
        this.hideCommonFields();
        this.hideUncommonFields();
        this.handleSharesIn();
        break;
      case 'Shares out':
        this.showAllFields();
        this.hideCommonFields();
        this.hideUncommonFields();
        this.handleSharesOut();
        break;
      default:
        this.showAllFields();
        this.hideUncommonFields();
    }
  }
}
