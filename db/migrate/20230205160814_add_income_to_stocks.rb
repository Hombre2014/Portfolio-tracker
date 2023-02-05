class AddIncomeToStocks < ActiveRecord::Migration[7.0]
  def change
    add_column :stocks, :income, :decimal
  end
end
