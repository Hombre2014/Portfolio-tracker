module PositionsHelper
  def create_update_stock(position)
    @portfolio = Portfolio.find(params[:portfolio_id])
    if @stock_symbols.include?(position.symbol)
      stock = @stocks.find_by(ticker: position.symbol)
      stock.shares_owned += position.quantity
      stock.commission_and_fee += position.commission_and_fee
      stock.realized_profit_loss += position.realized_profit_loss
      stock.save
      # if position.tr_type == 'Buy'
        # @stock.shares_owned += transaction.quantity
        # @stock.commission_and_fee += add_cost(transaction)
        # @stock.save
        # @portfolio.transactions_cost += add_cost(transaction)
        # @portfolio.save
      # elsif transaction.tr_type == 'Sell'
        # position = @positions.where(portfolio_id: params[:portfolio_id], symbol: transaction.symbol).first
        # @stock.realized_profit_loss += transaction.quantity * transaction.price - add_cost(transaction) - transaction.quantity * position.cost_per_share
        # @stock.shares_owned -= transaction.quantity
        # @stock.commission_and_fee += add_cost(transaction)
        # @stock.save
        # @portfolio.realized_profit_loss += transaction.quantity * transaction.price - add_cost(transaction) - transaction.quantity * position.cost_per_share
        # @portfolio.transactions_cost += add_cost(transaction)
        # @portfolio.save
      # end
    else
      new_stock = Stock.create(ticker: position.symbol, transaction_id: nil, realized_profit_loss: position.realized_profit_loss, commission_and_fee: position.commission_and_fee, shares_owned: position.quantity, portfolio_id: @portfolio.id)
      new_stock.save
      @portfolio.transactions_cost += position.commission_and_fee
      @portfolio.save
    end
  end
end
