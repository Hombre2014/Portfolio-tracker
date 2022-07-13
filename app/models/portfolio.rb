class Portfolio < ApplicationRecord
  has_many :positions, dependent: :destroy
  has_many :transactions, dependent: :destroy
  belongs_to :user
end
