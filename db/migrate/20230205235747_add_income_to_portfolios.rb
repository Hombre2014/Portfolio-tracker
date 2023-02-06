class AddIncomeToPortfolios < ActiveRecord::Migration[7.0]
  def change
    add_column :portfolios, :income, :decimal, precision: 10, scale: 2, default: 0
  end
end
