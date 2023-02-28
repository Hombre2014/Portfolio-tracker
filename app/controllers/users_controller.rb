require 'finnhub_ruby'
require_relative '../helpers/portfolios_helper'

class UsersController < ApplicationController
  # before_action :set_transaction, only: %i[show edit update destroy]
  before_action :set_user, only: %i[show edit update destroy]

  def index
    return redirect_to "/users/#{current_user.id}/portfolios" if current_user
  end

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
    @portfolios = @user.portfolios.includes([:positions])
    @positions = Position.where(portfolio_id: @portfolios.ids).where.not(symbol: 'Cash')
    
    @finnhub_client = FinnhubRuby::DefaultApi.new
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name)
  end
end
