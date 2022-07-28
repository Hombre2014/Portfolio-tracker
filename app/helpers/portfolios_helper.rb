require 'finnhub_ruby'

module PortfoliosHelper
  FinnhubRuby.configure do |config|
    config.api_key['api_key'] = ENV['API_KEY']
  end

  def create_cash_position
    @portfolio.cash == nil ? @portfolio.cash = 0 : @portfolio.cash
    @position = Position.create(portfolio_id: @portfolio.id, symbol: "Cash", quantity: @portfolio.cash, cost_per_share: 1, open_date: @portfolio.opened_date)
  end

  def get_profit_loss
    @transactions.each do |transaction|
      if transaction.tr_type == 'Buy'
        @tr_comm_and_fee = transaction.commission + transaction.fee
        @buy_total += transaction.quantity * transaction.price + @tr_comm_and_fee
        @tr_cost += @tr_comm_and_fee
      end
      if transaction.tr_type == 'Sell'
        @tr_comm_and_fee = transaction.commission + transaction.fee
        @sell_total += transaction.quantity * transaction.price - @tr_comm_and_fee
        @tr_cost += @tr_comm_and_fee
      end
    end
    @pl = @sell_total - @buy_total
  end
end
