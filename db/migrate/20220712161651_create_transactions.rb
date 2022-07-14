class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.string :tr_type
      t.date :trade_date
      t.string :symbol
      t.integer :quantity
      t.float :price
      t.float :commission
      t.float :fee

      t.timestamps
    end
  end
end
