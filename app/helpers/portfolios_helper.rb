require 'finnhub_ruby'

module PortfoliosHelper
  FinnhubRuby.configure do |config|
    config.api_key['api_key'] = ENV.fetch('API_KEY', nil)
  end

  def clear_instant_variable
    @total_day_gain = 0
    @total_comm_and_fee = 0
    @total_position_gain = 0
    @total_income = 0
    @position_profit_loss = 0
    @total_portfolio_value = 0
    @closed_stock_rpl = 0
    @closed_stock_income = 0
    @closed_stock_comm_and_fee = 0
    @portfolio_closed_rpl = 0
    @portfolio_closed_income = 0
    @portfolio_closed_comm_and_fee = 0
    @closed_stock_gain = 0
    @total_closed_stock_gain = 0
    @total_reinvested_income = 0
    @portfolio_closed_reinvested_income = 0
  end

  def initial_setup
    @portfolios = Portfolio.where(user_id: current_user.id).order(:created_at)
    @stock_symbols = Stock.all.map(&:ticker)
    @transactions = Transaction.all
    @positions = Position.all
    @stocks = Stock.all
    @finnhub_client = FinnhubRuby::DefaultApi.new
    @net_worth = 0
    @net_worth_profit = 0
    @net_worth_income = 0
    @net_worth_return = 0
    @net_worth_return_percent = 0
    @net_worth_reinvested_income = 0
  end

  def create_cash_position
    @portfolio.cash.nil? ? @portfolio.cash = 0 : @portfolio.cash
    @position = Position.create(portfolio_id: @portfolio.id, symbol: 'Cash', quantity: @portfolio.cash, cost_per_share: 1, open_date: @portfolio.opened_date, commission_and_fee: 0, realized_profit_loss: 0, income: 0)
    @initial_portfolio_value = @portfolio.cash
    @initial_portfolio_value = @initial_portfolio_value.nil? ? 0 : @portfolio.cash
  end

  def closed_positions(portfolio)
    @closed_stocks = Stock.where(portfolio_id: portfolio.id).where(shares_owned: 0)
    @closed_stocks.each do |stock|
      @closed_stock_rpl = stock.realized_profit_loss
      @portfolio_closed_rpl += @closed_stock_rpl

      @closed_stock_income = stock.income
      @portfolio_closed_income += @closed_stock_income

      @closed_stock_comm_and_fee = stock.commission_and_fee
      @portfolio_closed_comm_and_fee += @closed_stock_comm_and_fee

      # @closed_stock_gain = @closed_stock_rpl + @closed_stock_income - @closed_stock_comm_and_fee
      # @total_closed_stock_gain += @closed_stock_gain
    end
  end
end
