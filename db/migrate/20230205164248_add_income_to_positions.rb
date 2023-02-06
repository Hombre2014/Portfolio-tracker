class AddIncomeToPositions < ActiveRecord::Migration[7.0]
  def change
    add_column :positions, :income, :decimal, precision: 10, scale: 2
  end
end
