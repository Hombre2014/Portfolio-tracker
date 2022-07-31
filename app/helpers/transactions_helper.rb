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

  def create_update_position(transaction)
    @portfolio = Portfolio.find(params[:portfolio_id])
    @positions = Position.where(portfolio_id: params[:portfolio_id])
    @position = @positions.where(portfolio_id: params[:portfolio_id], symbol: transaction.symbol).first if symbol_exist?(transaction)

    transaction.commission == nil ? transaction.commission = 0 : transaction.commission
    transaction.fee == nil ? transaction.fee = 0 : transaction.fee
    case @transaction.tr_type
    when "Buy"
      if enough_cash?(@transaction)
        if symbol_exist?(@transaction)
          add_cost(@transaction)
          @add_cost = transaction.commission + transaction.fee
          @buy_total += transaction.quantity * transaction.price + @add_cost
          @position = @positions.where(portfolio_id: params[:portfolio_id], symbol: @transaction.symbol).first
          current_position_total = @position.quantity * @position.cost_per_share
          @position.update(quantity: @position.quantity + @transaction.quantity)
          @position.update(cost_per_share: (current_position_total + @transaction_buy_cost) / @position.quantity)
          @cash_position.update(quantity: @cash_position.quantity - @transaction_buy_cost)
          @position.update(commission_and_fee: @position.commission_and_fee + @add_cost)
        else
          new_position = Position.create(open_date: @transaction.trade_date, symbol: @transaction.symbol, quantity: @transaction.quantity, cost_per_share: (@transaction_buy_cost / @transaction.quantity), commission_and_fee: @add_cost, portfolio_id: @portfolio.id)
          @cash_position.update(quantity: @cash_position.quantity - @transaction_buy_cost)
        end
      end
    when "Sell"
      if symbol_exist?(@transaction)
        add_cost(@transaction)
        @tr_cost += @add_cost
        @position = @positions.where(portfolio_id: params[:portfolio_id], symbol: @transaction.symbol).first
        current_position_total = @position.quantity * @position.cost_per_share
        @cash_position = Position.where(portfolio_id: params[:portfolio_id], symbol: "Cash").first
        if @position.quantity >= @transaction.quantity
          @transaction_sell_income = transaction.quantity * transaction.price - add_cost(transaction)
          @position.update(quantity: @position.quantity - @transaction.quantity)
          @cash_position.update(quantity: @cash_position.quantity + @transaction_sell_income)
          @position.update(commission_and_fee: @position.commission_and_fee + @add_cost)
          @pl = @transaction_sell_income - (transaction.quantity * @position.cost_per_share)
          if @position.quantity == 0.0
            @position.destroy
          end
          @pl  
        end
      end
    end
  end
end
