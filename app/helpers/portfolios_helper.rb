require 'finnhub_ruby'

module PortfoliosHelper
  FinnhubRuby.configure do |config|
    config.api_key['api_key'] = ENV.fetch('API_KEY', nil)
  end

  def create_cash_position
    @portfolio.cash.nil? ? @portfolio.cash = 0 : @portfolio.cash
    @position = Position.create(portfolio_id: @portfolio.id, symbol: 'Cash', quantity: @portfolio.cash, cost_per_share: 1, open_date: @portfolio.opened_date)
    @initial_portfolio_value = @portfolio.cash
    @initial_portfolio_value = @initial_portfolio_value.nil? ? 0 : @portfolio.cash
  end

  def clear_instant_variable
    @total_day_gain = 0
    @total_comm_and_fee = 0
    @total_position_gain = 0
    @position_profit_loss = 0
    @total_portfolio_value = 0
  end
end
