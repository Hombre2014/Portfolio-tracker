module TransactionsHelper
  def add_cost(transaction)
    transaction.commission == nil ? transaction.commission = 0 : transaction.commission
    transaction.fee == nil ? transaction.fee = 0 : transaction.fee
    @add_cost = transaction.commission + transaction.fee
  end

  def enough_cash?(transaction)
    @cash_position = Position.where(portfolio_id: params[:portfolio_id], symbol: "Cash").first
    @transaction_buy_cost = transaction.quantity * transaction.price + add_cost(transaction)
    @cash_position.quantity >= @transaction_buy_cost
  end

  def symbol_exist?(transaction)
    @position = @positions.where(portfolio_id: params[:portfolio_id], symbol: transaction.symbol).first
    @position != nil
  end

  def enough_shares?(transaction)
    if symbol_exist?(transaction)
      @position = @positions.where(portfolio_id: params[:portfolio_id], symbol: transaction.symbol).first
      @position.quantity > 0 ? @position.quantity : 0
      return @position.quantity >= transaction.quantity
    else
      return false
    end
  end

  def create_update_stock(transaction)
    if @stock_symbols.include?(transaction.symbol)
      if transaction.tr_type == 'Buy'
        @stock.shares_owned += transaction.quantity
        @stock.commission_and_fee += add_cost(transaction)
        @stock.save
      elsif transaction.tr_type == 'Sell'
        position = @positions.where(portfolio_id: params[:portfolio_id], symbol: transaction.symbol).first
        @stock.realized_profit_loss += transaction.quantity * transaction.price - add_cost(transaction) - transaction.quantity * position.cost_per_share
        @stock.shares_owned -= transaction.quantity
        @stock.commission_and_fee += add_cost(transaction)
        @stock.save
      end
    else
      new_stock = Stock.create(ticker: transaction.symbol, transaction_id: transaction.id, realized_profit_loss: 0, commission_and_fee: add_cost(transaction), shares_owned: transaction.quantity)
    end
  end

  def create_update_position(transaction)
    @stock = Stock.find_by(ticker: transaction.symbol)
    @stock.commission_and_fee += add_cost(transaction)
    @portfolio = Portfolio.find(params[:portfolio_id])
    @positions = Position.where(portfolio_id: params[:portfolio_id])
    @position = @positions.where(portfolio_id: params[:portfolio_id], symbol: transaction.symbol).first if symbol_exist?(transaction)
    transaction.commission == nil ? transaction.commission = 0 : transaction.commission
    transaction.fee == nil ? transaction.fee = 0 : transaction.fee
    case @transaction.tr_type
    when "Buy"
      if enough_cash?(@transaction)
        if symbol_exist?(@transaction)
          @buy_total += transaction.quantity * transaction.price + add_cost(@transaction)
          @position = @positions.where(portfolio_id: params[:portfolio_id], symbol: @transaction.symbol).first
          current_position_total = @position.quantity * @position.cost_per_share
          @position.update(quantity: @position.quantity + @transaction.quantity)
          @position.update(cost_per_share: (current_position_total + @transaction_buy_cost) / @position.quantity)
          @cash_position.update(quantity: @cash_position.quantity - @transaction_buy_cost)
          @position.update(commission_and_fee: @position.commission_and_fee + add_cost(@transaction))
        else
          new_position = Position.create(open_date: @transaction.trade_date, symbol: @transaction.symbol, quantity: @transaction.quantity, cost_per_share: (@transaction_buy_cost / @transaction.quantity), commission_and_fee: add_cost(@transaction), realized_profit_loss: @stock.realized_profit_loss, portfolio_id: @portfolio.id)
          new_position.commission_and_fee += add_cost(@transaction)
          @cash_position.update(quantity: @cash_position.quantity - @transaction_buy_cost)
        end
      end
    when "Sell"
      if symbol_exist?(@transaction)
        @position.commission_and_fee += add_cost(@transaction)
        @tr_cost += @position.commission_and_fee
        current_position_total = @position.quantity * @position.cost_per_share
        @cash_position = Position.where(portfolio_id: params[:portfolio_id], symbol: "Cash").first
        if @position.quantity >= @transaction.quantity
          @transaction_sell_income = transaction.quantity * transaction.price - add_cost(transaction)
          @position.update(quantity: @position.quantity - @transaction.quantity)
          @position.update(realized_profit_loss: @position.realized_profit_loss + (transaction.quantity * transaction.price - add_cost(transaction)) - transaction.quantity * @position.cost_per_share)
          @cash_position.update(quantity: @cash_position.quantity + @transaction_sell_income)
          if @position.quantity == 0.0
            @position.destroy
          end
          # @realized_profit_loss
        end
      end
    end
  end
end
