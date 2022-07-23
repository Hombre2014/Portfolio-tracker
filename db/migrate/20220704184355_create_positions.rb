class CreatePositions < ActiveRecord::Migration[7.0]
  def change
    create_table :positions do |t|
      t.date :open_date
      t.string :symbol
      t.decimal :quantity
      t.float :cost_per_share
      t.float :commission_and_fee
      t.references :portfolio, null: false, foreign_key: true

      t.timestamps
    end
  end
end
