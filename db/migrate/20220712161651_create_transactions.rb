class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.string :tr_type
      t.date :trade_date
      t.string :symbol
      t.decimal :quantity
      t.decimal :price
      t.decimal :commission
      t.decimal :fee

      t.timestamps
    end
  end
end
