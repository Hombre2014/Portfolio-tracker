class AddDivPerShareToTransactions < ActiveRecord::Migration[7.0]
  def change
    add_column :transactions, :div_per_share, :decimal, precision: 10, scale: 5
  end
end
