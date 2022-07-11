class Portfolio < ApplicationRecord
  has_many :positions, dependent: :destroy
  belongs_to :user
end
