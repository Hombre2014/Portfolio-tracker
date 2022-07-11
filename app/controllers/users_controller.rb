class UsersController < ApplicationController
  def index
    return redirect_to "/users/#{current_user.id}/portfolios" if current_user
  end
end
