class ChangeQuantityFromIntegerToDecimal < ActiveRecord::Migration[7.0]
  def change
    change_column :transactions, :quantity, :decimal
  end
end
