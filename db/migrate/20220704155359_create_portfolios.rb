class CreatePortfolios < ActiveRecord::Migration[7.0]
  def change
    create_table :portfolios do |t|
      t.string :name
      t.string :acc_number
      t.decimal :cash
      t.date :opened_date
      t.decimal :realized_profit_loss

      t.timestamps
    end
  end
end
