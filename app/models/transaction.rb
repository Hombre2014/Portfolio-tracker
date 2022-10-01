class Transaction < ApplicationRecord
  belongs_to :portfolio
  validates :tr_type, :trade_date, :symbol, :quantity, :price,  presence: true
end
