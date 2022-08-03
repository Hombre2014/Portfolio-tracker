class CreateStocks < ActiveRecord::Migration[7.0]
  def change
    create_table :stocks do |t|
      t.string :ticker
      t.integer :transaction_id
      t.float :realized_profit_loss

      t.timestamps
    end
  end
end
