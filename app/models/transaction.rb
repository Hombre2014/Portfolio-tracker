class Transaction < ApplicationRecord
  belongs_to :portfolio
  validates :tr_type, presence: true
end
