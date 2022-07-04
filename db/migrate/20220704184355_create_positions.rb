class CreatePositions < ActiveRecord::Migration[7.0]
  def change
    create_table :positions do |t|
      t.string :symbol
      t.decimal :quantity
      t.references :portfolio, null: false, foreign_key: true

      t.timestamps
    end
  end
end
