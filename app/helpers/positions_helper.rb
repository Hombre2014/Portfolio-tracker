module PositionsHelper
  def create_update_position(position)
    @portfolio = Portfolio.find(params[:portfolio_id])
    if @stock_symbols.include?(position.symbol)
      stock = @stocks.find_by(ticker: position.symbol)
      stock.shares_owned += position.quantity
      stock.commission_and_fee += position.commission_and_fee
      stock.realized_profit_loss += position.realized_profit_loss
      stock.save
    else
      new_stock = Stock.create(ticker: position.symbol, transaction_id: nil,
                              realized_profit_loss: position.realized_profit_loss, commission_and_fee: position.commission_and_fee, shares_owned: position.quantity, portfolio_id: @portfolio.id)
      new_stock.save
      @portfolio.transactions_cost += position.commission_and_fee
      @portfolio.save
    end
  end
end
