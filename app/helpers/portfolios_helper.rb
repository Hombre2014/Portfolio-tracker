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

  def get_profit_loss
    @transactions.each do |transaction|
      portfolio = @portfolios.find { |portfolio| portfolio.id == transaction.portfolio_id }
      position = @positions.find { |position| position.portfolio_id == portfolio.id && position.symbol == transaction.symbol }
      if transaction.portfolio_id == portfolio.id
        @tr_comm_and_fee = transaction.commission + transaction.fee
        if transaction.tr_type == 'Buy'
          @tr_cost += @tr_comm_and_fee
          @realized_profit_loss == nil ? @realized_profit_loss = 0 : @realized_profit_loss
        end
        if transaction.tr_type == 'Sell'
          @sell_total += transaction.quantity * transaction.price - @tr_comm_and_fee
          @tr_cost += @tr_comm_and_fee
          @realized_profit_loss = @sell_total - transaction.quantity * position.cost_per_share
        end
      end
    end
  end
end
