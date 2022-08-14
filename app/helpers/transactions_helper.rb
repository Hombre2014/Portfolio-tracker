module TransactionsHelper
  def reset_instance_variable
    @total_fees = 0
    @income_spent = 0
    @total_commissions = 0
  end

  def initial_setup
    @transaction = Transaction.new(transaction_params)
    @portfolio = Portfolio.find(params[:portfolio_id])
    @positions = Position.where(portfolio_id: params[:portfolio_id])
    @finnhub_client = FinnhubRuby::DefaultApi.new
    @stocks = Stock.where(portfolio_id: params[:portfolio_id])
    @stock_symbols = @stocks.all.map(&:ticker)
    @stock = @stocks.find_by(ticker: @transaction.symbol)
  end

  def transaction_amount(transaction)
    transaction.quantity * transaction.price
  end

  def add_cost(transaction)
    transaction.commission.nil? ? transaction.commission = 0 : transaction.commission
    transaction.fee.nil? ? transaction.fee = 0 : transaction.fee
    @add_cost = transaction.commission + transaction.fee
  end

  def enough_cash?(transaction)
    @cash_position = Position.where(portfolio_id: params[:portfolio_id], symbol: 'Cash').first
    if transaction.tr_type == 'Buy' || transaction.tr_type == 'Buy to cover'
      @transaction_buy_cost = transaction_amount(transaction) + add_cost(transaction)
    else
      @transaction_buy_cost = transaction_amount(transaction) - add_cost(transaction)
    end
    @cash_position.quantity >= @transaction_buy_cost
  end

  def symbol_exist?(transaction) # in position table
    @position = @positions.where(portfolio_id: params[:portfolio_id], symbol: transaction.symbol).first
    @position != nil
  end

  def enough_shares?(transaction)
    if symbol_exist?(transaction) # in position table
      @position = @positions.where(portfolio_id: params[:portfolio_id], symbol: transaction.symbol).first
      @position.quantity ? @position.quantity : 0
      @position.quantity.abs >= transaction.quantity.abs
    else
      false
    end
  end

  def long_position_exist?(transaction)
    @position = @positions.find_by(portfolio_id: params[:portfolio_id], symbol: transaction.symbol)
    @position == nil ? false : @position.quantity.positive? ? true : false
  end

  def short_position_exist?(transaction)
    @position = @positions.find_by(portfolio_id: params[:portfolio_id], symbol: transaction.symbol)
    @position == nil ? false : @position.quantity.negative? ? true : false
  end

  def transaction_save(transaction, format)
    if transaction.save
      format.html do
        redirect_to "/users/#{current_user.id}/portfolios/#{params[:portfolio_id]}/transactions/#{params[:id]}", notice: 'Transaction was successfully created.'
      end
      format.json { render :show, status: :created, location: transaction }
    else
      format.html { render :new, status: :unprocessable_entity }
      format.json { render json: transaction.errors, status: :unprocessable_entity }
    end
  end

  def create_update_stock(transaction)
    @portfolio = Portfolio.find(params[:portfolio_id])
    case transaction.tr_type
    when 'Buy'
      if @stock_symbols.include?(transaction.symbol)
        if enough_cash?(transaction)
          unless short_position_exist?(transaction)
            @stock.shares_owned += transaction.quantity
            @stock.commission_and_fee += add_cost(transaction)
            @stock.save
            @portfolio.transactions_cost += add_cost(transaction)
            @portfolio.save
          end
        end
      else
        new_stock = Stock.create(ticker: transaction.symbol, transaction_id: transaction.id, realized_profit_loss: 0,
          commission_and_fee: add_cost(transaction), shares_owned: transaction.quantity, portfolio_id: @portfolio.id)
        new_stock.save
        @portfolio.transactions_cost += add_cost(transaction)
        @portfolio.save
      end
    when 'Sell'
      unless short_position_exist?(transaction)
        if enough_shares?(transaction)
          position = @positions.where(portfolio_id: params[:portfolio_id], symbol: transaction.symbol).first
          @stock.realized_profit_loss += transaction_amount(transaction) - add_cost(transaction) - (transaction.quantity * position.cost_per_share)
          @stock.shares_owned -= transaction.quantity
          @stock.commission_and_fee += add_cost(transaction)
          @stock.save
          @portfolio.realized_profit_loss += transaction_amount(transaction) - add_cost(transaction) - (transaction.quantity * position.cost_per_share)
          @portfolio.transactions_cost += add_cost(transaction)
          @portfolio.save
        end
      end
    when 'Sell short'
      if @stock_symbols.include?(transaction.symbol)
        unless long_position_exist?(transaction)
          @stock.shares_owned -= transaction.quantity
          @stock.commission_and_fee += add_cost(transaction)
          @stock.save
          @portfolio.transactions_cost += add_cost(transaction)
          @portfolio.save
        end
      else
          new_stock = Stock.create(ticker: transaction.symbol, transaction_id: transaction.id, realized_profit_loss: 0,
            commission_and_fee: add_cost(transaction), shares_owned: -1 * transaction.quantity, portfolio_id: @portfolio.id)
          new_stock.save
          @portfolio.transactions_cost += add_cost(transaction)
          @portfolio.save
      end
    when 'Buy to cover'
      unless long_position_exist?(transaction)
        if short_position_exist?(transaction)
          if enough_cash?(transaction)
            if enough_shares?(transaction)
              position = @positions.where(portfolio_id: params[:portfolio_id], symbol: transaction.symbol).first
              @stock.shares_owned += transaction.quantity
              @stock.commission_and_fee += add_cost(transaction)
              @stock.realized_profit_loss -= transaction_amount(transaction) + add_cost(transaction) - (transaction.quantity * position.cost_per_share)
              @stock.save
              @portfolio.realized_profit_loss -= transaction_amount(transaction) + add_cost(transaction) - (transaction.quantity * position.cost_per_share)
              @portfolio.transactions_cost += add_cost(transaction)
              @portfolio.save
            end
          end
        end
      end
    end
  end

  def create_update_position(transaction)
    @stock = @stocks.find_by(ticker: transaction.symbol)
    @portfolio = Portfolio.find(params[:portfolio_id])
    @position = @positions.where(portfolio_id: params[:portfolio_id], symbol: transaction.symbol).first if symbol_exist?(transaction)
    @cash_position = Position.where(portfolio_id: params[:portfolio_id], symbol: 'Cash').first
    transaction.commission.nil? ? transaction.commission = 0 : transaction.commission
    transaction.fee.nil? ? transaction.fee = 0 : transaction.fee
    case transaction.tr_type
    when 'Buy'
      if enough_cash?(transaction)
        if symbol_exist?(transaction)
          unless short_position_exist?(transaction)
            current_position_total = @position.quantity * @position.cost_per_share
            @position.update(quantity: @position.quantity + transaction.quantity)
            @position.update(cost_per_share: (current_position_total + @transaction_buy_cost) / @position.quantity)
            @position.update(commission_and_fee: @position.commission_and_fee + add_cost(transaction))
          end
        else
          new_position = Position.create(open_date: transaction.trade_date, symbol: transaction.symbol,
          quantity: transaction.quantity, cost_per_share: (@transaction_buy_cost / transaction.quantity).round(6), commission_and_fee: add_cost(transaction), realized_profit_loss: @stock.realized_profit_loss, portfolio_id: @portfolio.id)
          new_position.commission_and_fee += add_cost(transaction)
        end
        @cash_position.update(quantity: @cash_position.quantity - @transaction_buy_cost)
      end
    when 'Sell'
      unless short_position_exist?(transaction)
        if enough_shares?(transaction)
          transaction_sell_income = transaction_amount(transaction) - add_cost(transaction)
          @position.update(quantity: @position.quantity - transaction.quantity)
          @position.commission_and_fee += add_cost(transaction)
          @position.update(realized_profit_loss: @stock.realized_profit_loss)
          @position.save
          @cash_position.update(quantity: @cash_position.quantity + transaction_sell_income)
          @position.destroy if @position.quantity == 0
        end
      end
    when 'Sell short'
      transaction_sell_income = transaction_amount(transaction) - add_cost(transaction)
      unless long_position_exist?(transaction)
        if symbol_exist?(transaction)
            @position.update(quantity: @position.quantity - transaction.quantity)
            current_position_total = (@position.quantity * @position.cost_per_share).abs
            @position.update(cost_per_share: (current_position_total + transaction_sell_income.abs) / (transaction.quantity.abs + @position.quantity.abs).round(6))
            @position.update(commission_and_fee: @position.commission_and_fee + add_cost(transaction))
            @position.save
            @cash_position.update(quantity: @cash_position.quantity + transaction_sell_income)
        else
          new_position = Position.create(open_date: transaction.trade_date, symbol: transaction.symbol, quantity: (-1 * transaction.quantity), cost_per_share: (transaction_sell_income / transaction.quantity).round(6), commission_and_fee: add_cost(transaction), realized_profit_loss: 0, portfolio_id: @portfolio.id)
          @cash_position.update(quantity: @cash_position.quantity + transaction_sell_income)
        end
      end
    when 'Buy to cover'
      unless long_position_exist?(transaction)
        if short_position_exist?(transaction)
          if enough_cash?(transaction)
            if enough_shares?(transaction)
              @position.update(quantity: @position.quantity + transaction.quantity)
              @position.commission_and_fee += add_cost(transaction)
              @position.update(realized_profit_loss: @stock.realized_profit_loss)
              @position.save
              @cash_position.update(quantity: @cash_position.quantity - @transaction_buy_cost)
              @position.destroy if @position.quantity == 0
            end
          end
        end
      end
    end
  end
end
