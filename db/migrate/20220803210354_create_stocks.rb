class CreateStocks < ActiveRecord::Migration[7.0]
  def change
    create_table :stocks do |t|
      t.string :ticker
      t.integer :transaction_id
      t.decimal :realized_profit_loss
      t.decimal :shares_owned

      t.timestamps
    end
  end
end
