class TransactionsController < ApplicationController
  before_action :set_transaction, only: %i[ show edit update destroy ]

  # GET /transactions or /transactions.json
  def index
    @transactions = Transaction.where(portfolio_id: params[:portfolio_id])
    @portfolio = Portfolio.find(params[:portfolio_id])
  end

  # GET /transactions/1 or /transactions/1.json
  def show
    @portfolio = Portfolio.find(params[:portfolio_id])
  end

  # GET /transactions/new
  def new
    @transaction = Transaction.new
    @portfolio = Portfolio.find(params[:portfolio_id])
  end

  # GET /transactions/1/edit
  def edit
    @portfolio = Portfolio.find(params[:portfolio_id])
  end

  def is_enough_cash?(transaction)
    @cash_position = Position.where(portfolio_id: params[:portfolio_id], symbol: "Cash").first
    transaction.commission == nil ? transaction.commission = 0 : transaction.commission
    transaction.fee == nil ? transaction.fee = 0 : transaction.fee
    @transaction_cost = transaction.quantity * transaction.price + transaction.commission + transaction.fee
    @cash_position.quantity >= @transaction_cost
  end

  def create_new_position
    @portfolio = Portfolio.find(params[:portfolio_id])
    @positions = Position.where(portfolio_id: params[:portfolio_id])
    # @cash_position = Position.where(portfolio_id: params[:portfolio_id], symbol: "Cash").first

    case @transaction.tr_type
    when "Buy"
      if is_enough_cash?(@transaction)
        @positions.each do |position|
          position_total = position.quantity * position.cost_per_share

          if position.symbol == @transaction.symbol
            position.update(quantity: position.quantity + @transaction.quantity)
            position.update(cost_per_share: (position_total + @transaction_cost) / position.quantity)
            @cash_position.update(quantity: @cash_position.quantity - (@transaction.quantity * @transaction.price + @transaction.commission + @transaction.fee))
            break
          else
            # new_position = Position.new(open_date: @transaction.trade_date, symbol: @transaction.symbol, quantity: @transaction.quantity, cost_per_share: @transaction.price, portfolio_id: @portfolio.id)
            # new_position.save
            # break
          end
        end
      end
    end
  end

  # POST /transactions or /transactions.json
  def create
    @transaction = Transaction.new(transaction_params)
    @portfolio = Portfolio.find(params[:portfolio_id])

    create_new_position
    respond_to do |format|
      if is_enough_cash?(@transaction)
        if @transaction.save
          format.html { redirect_to "/users/#{current_user.id}/portfolios/#{params[:portfolio_id]}/transactions/#{params[:id]}", notice: "Transaction was successfully created." }
          format.json { render :show, status: :created, location: @transaction }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @transaction.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to "/users/#{current_user.id}/portfolios/#{params[:id]}/transactions/#{params[:id]}", alert: "Not enough cash to complete transaction." }
      end
    end
  end

  # PATCH/PUT /transactions/1 or /transactions/1.json
  def update
    respond_to do |format|
      if @transaction.update(transaction_params)
        format.html { redirect_to user_portfolio_transaction_url(@transaction), notice: "Transaction was successfully updated." }
        format.json { render :show, status: :ok, location: @transaction }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transactions/1 or /transactions/1.json
  def destroy
    @transaction.destroy

    respond_to do |format|
      format.html { redirect_to user_portfolio_transactions_url, notice: "Transaction was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transaction
      @transaction = Transaction.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def transaction_params
      params.require(:transaction).permit(:tr_type, :trade_date, :symbol, :quantity, :price, :commission, :fee, :portfolio_id)
    end
end
