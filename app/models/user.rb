class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :portfolios, dependent: :destroy
  # has_many :positions, through: :portfolios
  # has_many :positions, dependent: :destroy
  validates :name, presence: true, length: { minimum: 5, maximum: 20 }
end
