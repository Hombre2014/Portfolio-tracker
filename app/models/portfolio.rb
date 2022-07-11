class Portfolio < ApplicationRecord
  has_many :positions
  belongs_to :user
end
