class CreatePortfolios < ActiveRecord::Migration[7.0]
  def change
    create_table :portfolios do |t|
      t.string :name
      t.string :acc_number
      t.float :cash
      t.date :opened_date

      t.timestamps
    end
  end
end
