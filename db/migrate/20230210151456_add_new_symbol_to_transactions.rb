class AddNewSymbolToTransactions < ActiveRecord::Migration[7.0]
  def change
    add_column :transactions, :new_symbol, :string
  end
end
