class AddReinvestedIncomeToPortfolios < ActiveRecord::Migration[7.0]
  def change
    add_column :portfolios, :reinvested_income, :decimal, precision: 10, scale: 5
  end
end
