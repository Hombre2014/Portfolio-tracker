class UsersController < ApplicationController
  before_action :set_transaction, only: %i[show edit update destroy]
  before_action :set_user, only: %i[show edit update destroy]

  def index
    return redirect_to "/users/#{current_user.id}/portfolios" if current_user
  end

  def new
    @user = User.new
  end

  def User.from_omniauth(access_token)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.full_name = auth.info.name   # assuming the user model has a name
      user.avatar_url = auth.info.image # assuming the user model has an image
      # If you are using confirmable and the provider(s) you use validate emails,
      # uncomment the line below to skip the confirmation emails.
      # user.skip_confirmation!
    end
  end

  def google_oauth2
    user = User.from_omniauth(auth)

    if user.present?
      sign_out_all_scopes
      flash[:notice] = t 'devise.omniauth_callbacks.success', kind: 'Google'
      sign_in_and_redirect user, event: :authentication
    else
      flash[:alert] = 
      t 'devise.omniauth_callbacks.failure', kind: 'Google', reason: "#{auth.info.email} is not authorized."
      redirect_to new_user_session_path
    end
  end

  private

  def auth
    @auth ||= request.env['omniauth.auth']
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name)
  end
end
