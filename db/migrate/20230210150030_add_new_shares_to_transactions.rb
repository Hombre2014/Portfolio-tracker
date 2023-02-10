class AddNewSharesToTransactions < ActiveRecord::Migration[7.0]
  def change
    add_column :transactions, :new_shares, :integer
  end
end
