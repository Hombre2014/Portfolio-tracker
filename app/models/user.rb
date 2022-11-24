class User < ApplicationRecord
  before_save { self.email = email.downcase }
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :portfolios, dependent: :destroy

  validates :name, presence: true, length: { minimum: 2, maximum: 20 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
    format: { with: VALID_EMAIL_REGEX }, uniqueness: true

  # def self.from_omniauth(access_token) # From Deanin video
  #   where(provider: access_token.provider, uid: access_token.uid).first_or_create do |user|
  #     user.email = access_token.info.email
  #     user.password = Devise.friendly_token[0,20]
  #     user.full_name = access_token.info.name   # assuming the user model has a name
  #     user.avatar_url = access_token.info.image # assuming the user model has an image
  #     # If you are using confirmable and the provider(s) you use validate emails,
  #     # uncomment the line below to skip the confirmation emails.
  #     # user.skip_confirmation!
  #   end
  # end

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(email: data['email']).first

    # Uncomment the section below if you want users to be created if they don't exist
    unless user
      user = User.create(name: data['name'],
        email: data['email'],
        password: Devise.friendly_token[0,20]
      )
    end
    user.name = data['name']
    user.avatar_url = data['image']
    user.provider = access_token.provider
    user.save
    user
  end
end
