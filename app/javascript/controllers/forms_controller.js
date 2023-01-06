import { Controller } from "@hotwired/stimulus"

export default class FormsController extends Controller {
  connect() {
    console.log("Hello, Stimulus!", this.element)
  }

  example() {
    const tr_type = document.getElementById('transaction_tr_type');
    tr_type.addEventListener('change', tr_type_change);

    function tr_type_change() {
      console.log(tr_type.value);
      if (tr_type.value == 'Cash in' || tr_type.value == 'Cash out') {
        let trade_symbol = document.querySelector('#trade_symbol');
        trade_symbol.classList.add('hidden');
      }
    }
  }
}
