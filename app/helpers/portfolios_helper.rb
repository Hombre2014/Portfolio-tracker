require 'finnhub_ruby'

module PortfoliosHelper
  FinnhubRuby.configure do |config|
    config.api_key['api_key'] = ENV['API_KEY']
  end

  def create_cash_position
    @portfolio.cash == nil ? @portfolio.cash = 0 : @portfolio.cash
    @position = Position.create(portfolio_id: @portfolio.id, symbol: "Cash", quantity: @portfolio.cash, cost_per_share: 1, open_date: @portfolio.opened_date)
    @initial_portfolio_value = @portfolio.cash
    @initial_portfolio_value == nil ? @initial_portfolio_value = 0 : @initial_portfolio_value = @portfolio.cash
  end

  def get_tr_cost
    @transactions.each do |transaction|
      portfolio = @portfolios.find { |portfolio| portfolio.id == transaction.portfolio_id }
      stock = @stocks.find { |stock| stock.ticker == transaction.symbol && stock.portfolio_id == transaction.portfolio_id }
      portfolio.transactions_cost += stock.commission_and_fee if transaction.portfolio_id == portfolio.id
    end
  end
end
