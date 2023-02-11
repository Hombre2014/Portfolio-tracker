class AddReinvestedIncomeToPositions < ActiveRecord::Migration[7.0]
  def change
    add_column :positions, :reinvested_income, :decimal, precision: 10, scale: 5
  end
end
