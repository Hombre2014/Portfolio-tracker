class AddOldSharesToTransactions < ActiveRecord::Migration[7.0]
  def change
    add_column :transactions, :old_shares, :integer
  end
end
