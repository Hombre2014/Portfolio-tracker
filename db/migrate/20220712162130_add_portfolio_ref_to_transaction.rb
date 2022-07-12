class AddPortfolioRefToTransaction < ActiveRecord::Migration[7.0]
  def change
    add_reference :transactions, :portfolio, null: false, foreign_key: true
  end
end
