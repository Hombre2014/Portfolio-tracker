class PagesController < ApplicationController
  def home
  end

  def about
  end

  def contact
  end

  def profile
    @user = User.find(params[:id])
  end
end
