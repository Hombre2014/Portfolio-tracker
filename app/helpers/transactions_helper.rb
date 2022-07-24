module TransactionsHelper
  def add_cost(transaction)
    transaction.commission == nil ? transaction.commission = 0 : transaction.commission
    transaction.fee == nil ? transaction.fee = 0 : transaction.fee
    @add_cost = transaction.commission + transaction.fee
  end

  def is_enough_cash?(transaction)
    @cash_position = Position.where(portfolio_id: params[:portfolio_id], symbol: "Cash").first
    @transaction_cost = transaction.quantity * transaction.price + add_cost(transaction)
    @cash_position.quantity >= @transaction_cost
  end

  def is_symbol_exist?(transaction)
    @position = Position.where(portfolio_id: params[:portfolio_id], symbol: transaction.symbol).first
    @position != nil
  end

  def create_new_position(transaction)
    @portfolio = Portfolio.find(params[:portfolio_id])
    @positions = Position.where(portfolio_id: params[:portfolio_id])
    @position = Position.where(portfolio_id: params[:portfolio_id], symbol: transaction.symbol).first

    case @transaction.tr_type
    when "Buy"
      if is_enough_cash?(@transaction)
        if is_symbol_exist?(@transaction)
          @existing_position = Position.where(portfolio_id: params[:portfolio_id], symbol: @transaction.symbol).first
          current_position_total = @existing_position.quantity * @existing_position.cost_per_share
          @existing_position.update(quantity: @existing_position.quantity + @transaction.quantity)
          @existing_position.update(cost_per_share: (current_position_total + @transaction_cost) / @existing_position.quantity)
          @cash_position.update(quantity: @cash_position.quantity - @transaction_cost)
          @position.update(commission_and_fee: @position.commission_and_fee + @add_cost)
        else
          new_position = Position.create(open_date: @transaction.trade_date, symbol: @transaction.symbol, quantity: @transaction.quantity, cost_per_share: (@transaction_cost / @transaction.quantity), commission_and_fee: @add_cost, portfolio_id: @portfolio.id)
          @cash_position.update(quantity: @cash_position.quantity - @transaction_cost)
          # new_position.commission_and_fee = @add_cost
          # @commission_and_fee += @add_cost
        end
      end
    when "Sell"
      if is_symbol_exist?(@transaction)
        @existing_position = Position.where(portfolio_id: params[:portfolio_id], symbol: @transaction.symbol).first
        current_position_total = @existing_position.quantity * @existing_position.cost_per_share
        if @existing_position.quantity >= @transaction.quantity
          @existing_position.update(quantity: @existing_position.quantity - @transaction.quantity)
          @existing_position.update(cost_per_share: (current_position_total - @transaction_cost) / @existing_position.quantity)
          @cash_position.update(quantity: @cash_position.quantity + @transaction.quantity * @transaction.price - add_cost(@transaction))
          @position.update(commission_and_fee: @position.commission_and_fee + @add_cost)
          if @existing_position.quantity == 0
            @existing_position.destroy
          end
        end
      end
    end
  end
end
