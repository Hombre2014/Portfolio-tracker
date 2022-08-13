require_relative '..//helpers/positions_helper'

class PositionsController < ApplicationController
  include PositionsHelper
  before_action :set_position, only: %i[show edit update destroy]

  # GET /positions or /positions.json
  def index
    @portfolio = Portfolio.find(params[:portfolio_id])
    @positions = Position.where(portfolio_id: params[:portfolio_id])
  end

  # GET /positions/1 or /positions/1.json
  def show
    @portfolio = Portfolio.find(params[:portfolio_id])
  end

  # GET /positions/new
  def new
    @position = Position.new
    @portfolio = Portfolio.find(params[:portfolio_id])
  end

  # GET /positions/1/edit
  def edit
    @portfolio = Portfolio.find(params[:portfolio_id])
  end

  # POST /positions or /positions.json
  def create
    @position = Position.new(position_params)
    @finnhub_client = FinnhubRuby::DefaultApi.new
    @stocks = Stock.where(portfolio_id: params[:portfolio_id])
    @stock_symbols = @stocks.all.map(&:ticker)

    respond_to do |format|
      if @position.save
        format.html { redirect_to user_portfolio_positions_path, notice: 'Position was successfully created.' }
        format.json { render :show, status: :created, location: @position }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @position.errors, status: :unprocessable_entity }
      end
    end
    # create_update_position(@position)
    # @stock_data = @finnhub_client.company_profile2({ symbol: @position.symbol })
    # TODO Needs to be handled in a different way. Check it out. Have to consider all the existing positions.
  end

  # PATCH/PUT /positions/1 or /positions/1.json
  def update
    respond_to do |format|
      if @position.update(position_params)
        format.html { redirect_to user_portfolio_position_url, notice: 'Position was successfully updated.' }
        format.json { render :show, status: :ok, location: @position }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @position.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /positions/1 or /positions/1.json
  def destroy
    @position.destroy

    respond_to do |format|
      format.html { redirect_to user_portfolio_positions_url, notice: 'Position was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_position
    @position = Position.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def position_params
    params.require(:position).permit(:open_date, :symbol, :quantity, :cost_per_share, :commission_and_fee,
                                    :realized_profit_loss, :portfolio_id)
  end
end
