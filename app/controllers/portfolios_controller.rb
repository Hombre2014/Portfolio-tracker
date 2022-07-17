require 'finnhub_ruby'
require_relative "../helpers/portfolios_helper"

class PortfoliosController < ApplicationController
  include PortfoliosHelper

  before_action :set_portfolio, only: %i[ show edit update destroy ]

  # GET /portfolios or /portfolios.json
  def index
    @portfolios = Portfolio.where(user_id: current_user.id)
    @positions = Position.all
    @finnhub_client = FinnhubRuby::DefaultApi.new
    @total = 0
  end

  def create_cash_position
    @portfolio.cash == nil ? @portfolio.cash = 0 : @portfolio.cash
    @position = Position.new(portfolio_id: @portfolio.id, symbol: "Cash", quantity: @portfolio.cash, cost_per_share: 1, open_date: @portfolio.opened_date)
    @position.save
  end

  # GET /portfolios/1 or /portfolios/1.json
  def show
    @positions = Position.all
    @total = 0
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
      params.require(:portfolio).permit(:name, :acc_number, :cash, :opened_date, :user_id)
    end
end
