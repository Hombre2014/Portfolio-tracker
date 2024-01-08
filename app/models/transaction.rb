class Transaction < ApplicationRecord
  belongs_to :portfolio
  validates :tr_type, :trade_date, :symbol, :quantity, :price,  presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["closing_price", "commission", "div_per_share", "fee", "new_shares", "new_symbol", "old_shares", "price", "quantity", "symbol", "tr_type", "trade_date"]
  end
end
