class Portfolio < ApplicationRecord
  has_many :positions, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :stocks, dependent: :destroy

  belongs_to :user

  validates :name, presence: true, length: { maximum: 50 }, uniqueness: { scope: :user_id }, on: :create, on: :update
  validates :cash, presence: false, numericality: { greater_than: 0 }, on: :create
  validates :user_id, presence: true, on: :create
end
