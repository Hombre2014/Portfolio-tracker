class AddUserRefToPortfolio < ActiveRecord::Migration[7.0]
  def change
    add_reference :portfolios, :user, null: false, foreign_key: true
  end
end
