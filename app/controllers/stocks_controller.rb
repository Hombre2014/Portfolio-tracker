require 'date'
require 'time'

class StocksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stock, only: %i[show edit update destroy]

  # GET /stocks or /stocks.json
  def index
    @stocks = Stock.all
  end

  # GET /stocks/1 or /stocks/1.json
  def show
    @stock_symbols = Stock.all.map(&:ticker)
    @finnhub_client = FinnhubRuby::DefaultApi.new
    @transaction = Transaction.find_by(symbol: @stock.ticker)
    @position = Position.find_by(symbol: @stock.ticker)
    @position ? @stock_data = @finnhub_client.company_profile2({ symbol: @position.symbol }) :
                @stock_data = @finnhub_client.company_profile2({ symbol: @stock.ticker })
    @position ? @company_news = @finnhub_client.company_news(@position.symbol, Date.today - 14, Date.today) :
                @company_news = @finnhub_client.company_news(@stock.ticker, Date.today - 14, Date.today)
    @position ? @insider = @finnhub_client.insider_transactions(@position.symbol) :
                @insider = @finnhub_client.insider_transactions(@stock.ticker)
    @position ? @earnings = @finnhub_client.company_earnings(@position.symbol, { limit: 5}) :
                @earnings = @finnhub_client.company_earnings(@stock.ticker, { limit: 5})
  end

  def get_stock_id(ticker)
    @stock = Stock.find_by(ticker:)
    @stock.id
  end

  # GET /stocks/new
  def new
    @stock = Stock.new(income: 0)
  end

  # POST /stocks or /stocks.json
  def create
    @stock = Stock.new(stock_params)

    respond_to do |format|
      if @stock.save
        format.html { redirect_to stock_url(@stock), notice: 'Stock was successfully created.' }
        format.json { render :show, status: :created, location: @stock }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stocks/1 or /stocks/1.json
  def update
    respond_to do |format|
      if @stock.update(stock_params)
        format.html { redirect_to stock_url(@stock), notice: 'Stock was successfully updated.' }
        format.json { render :show, status: :ok, location: @stock }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stocks/1 or /stocks/1.json
  def destroy
    @stock.destroy

    respond_to do |format|
      format.html { redirect_to stocks_url, notice: 'Stock was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_stock
    @stock = Stock.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def stock_params
    params.require(:stock).permit(:ticker, :transaction_id, :realized_profit_loss, :commission_and_fee, :shares_owned, :income,
                                  :portfolio_id, :reinvested_income)
  end
end
