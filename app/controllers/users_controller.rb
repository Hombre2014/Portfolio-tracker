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
    @all_positions_closed_by_user = Stock.where(shares_owned: 0).where(portfolio_id: @portfolios.ids)
    @finnhub_client = FinnhubRuby::DefaultApi.new
    @all_closed_stocks_with_income = Stock.where(portfolio_id: @portfolios.ids).where.not(income: 0).where(shares_owned: 0)
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name)
  end
end
