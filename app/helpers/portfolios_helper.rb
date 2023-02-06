require 'finnhub_ruby'

module PortfoliosHelper
  FinnhubRuby.configure do |config|
    config.api_key['api_key'] = ENV.fetch('API_KEY', nil)
  end

  def create_cash_position
    @portfolio.cash.nil? ? @portfolio.cash = 0 : @portfolio.cash
    @position = Position.create(portfolio_id: @portfolio.id, symbol: 'Cash', quantity: @portfolio.cash, cost_per_share: 1, open_date: @portfolio.opened_date, income: 0, commission_and_fee: 0, realized_profit_loss: 0, income: 0)
    @initial_portfolio_value = @portfolio.cash
    @initial_portfolio_value = @initial_portfolio_value.nil? ? 0 : @portfolio.cash
  end

  def clear_instant_variable
    @total_day_gain = 0
    @total_comm_and_fee = 0
    @total_position_gain = 0
    @total_income = 0
    @position_profit_loss = 0
    @total_portfolio_value = 0
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
  end
end
