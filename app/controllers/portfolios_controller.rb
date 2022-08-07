require 'finnhub_ruby'
require_relative "../helpers/portfolios_helper"

class PortfoliosController < ApplicationController
  include PortfoliosHelper

  before_action :set_portfolio, only: %i[ show edit update destroy ]

  # GET /portfolios or /portfolios.json
  def index
    @portfolios = Portfolio.where(user_id: current_user.id)
    # @portfolio = Portfolio.find(params[:id])
    # @portfolio_transactions = Transaction.where(portfolio_id: portfolio.id)
    # @transactions = Transaction.where(portfolio_id: @portfolios.ids)
    @transactions = Transaction.all
    @positions = Position.all
    @stocks = Stock.all
    @finnhub_client = FinnhubRuby::DefaultApi.new
    @tr_cost = 0
    @buy_total = 0
    @sell_total = 0
    @total_day_gain = 0
    @tr_comm_and_fee = 0
    @total_last_close = 0
    @total_comm_and_fee = 0
    @total_position_gain = 0
    @position_profit_loss = 0
    @realized_profit_loss = 0
    @total_portfolio_value = 0
  end

  # GET /portfolios/1 or /portfolios/1.json
  def show
    @portfolios = Portfolio.where(user_id: current_user.id)
    @portfolio = Portfolio.find(params[:id])
    # @transactions = Transaction.where(portfolio_id: @portfolios.ids)
    @stocks = Stock.all
    @positions = Position.all
    @transactions = Transaction.all
    # @portfolio_transactions = Transaction.where(portfolio_id: portfolio.id)
    @finnhub_client = FinnhubRuby::DefaultApi.new
    @realized_profit_loss = 0
    @buy_total = 0
    @sell_total = 0
    @tr_comm_and_fee = 0
    @tr_cost = 0
    @total_day_gain = 0
    @total_last_close = 0
    @total_comm_and_fee = 0
    @total_position_gain = 0
    @position_profit_loss = 0
    @total_portfolio_value = 0
  end

  # GET /portfolios/new
  def new
    @portfolio = Portfolio.new
  end

  # GET /portfolios/1/edit
  def edit
    @portfolio = Portfolio.find(params[:id])
    @cash_position = Position.where(portfolio_id: params[:id], symbol: "Cash").first
    @portfolio.update(cash: @cash_position.quantity.to_f)
  end

  # POST /portfolios or /portfolios.json
  def create
    @portfolio = Portfolio.new(portfolio_params)

    respond_to do |format|
      if @portfolio.save
        format.html { redirect_to "/users/#{current_user.id}/portfolios/#{@portfolio.id}", notice: "Portfolio was successfully created." }
        create_cash_position
        format.json { render :show, status: :created, location: @portfolio }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @portfolio.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /portfolios/1 or /portfolios/1.json
  def update
    respond_to do |format|
      if @portfolio.update(portfolio_params)
        format.html { redirect_to "/users/#{current_user.id}/portfolios/#{@portfolio.id}", notice: "Portfolio was successfully updated." }
        format.json { render :show, status: :ok, location: @portfolio }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @portfolio.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /portfolios/1 or /portfolios/1.json
  def destroy
    @portfolio.destroy

    respond_to do |format|
      format.html { redirect_to user_portfolios_url, notice: "Portfolio was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_portfolio
      @portfolio = Portfolio.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def portfolio_params
      params.require(:portfolio).permit(:name, :acc_number, :cash, :opened_date, :realized_profit_loss, :user_id)
    end
end
