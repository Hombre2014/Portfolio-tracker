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

  # def get_profit_loss
  #   @transactions.each do |transaction|
  #     transaction.commission == nil ? transaction.commission = 0 : transaction.commission
  #     transaction.fee == nil ? transaction.fee = 0 : transaction.fee
  #     @tr_comm_and_fee = transaction.commission + transaction.fee
  #     if transaction.tr_type == 'Buy'
  #       @buy_total += transaction.quantity * transaction.price + @tr_comm_and_fee
  #       @tr_cost += @tr_comm_and_fee
  #       @pl == nil ? @pl = 0 : @pl
  #     end
  #     if transaction.tr_type == 'Sell'
  #       position = @positions.where(symbol: transaction.symbol).first
  #       @sell_total += transaction.quantity * transaction.price - @tr_comm_and_fee
  #       # position.quantity == nil ? position.quantity = 0 : position.quantity
  #       if transaction.quantity < position.quantity
  #         @tr_cost += @tr_comm_and_fee
  #         @pl = @sell_total - (transaction.quantity * position.cost_per_share)
  #       else
  #         @tr_cost += @tr_comm_and_fee
  #         @pl = @sell_total - @buy_total
  #         if position.quantity == 0
  #           position.destroy
  #           transaction.tr_type = nil
  #         end
  #         @pl
  #       end
  #     end
  #   end
  # end
end
