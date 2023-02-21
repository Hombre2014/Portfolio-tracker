class AddReinvestedIncomeToStocks < ActiveRecord::Migration[7.0]
  def change
    add_column :stocks, :reinvested_income, :decimal, precision: 10, scale: 5
  end
end
