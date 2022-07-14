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

  def create_new_position
    @portfolio = Portfolio.find(params[:portfolio_id])
    @positions = Position.where(portfolio_id: params[:portfolio_id])
    case @transaction.tr_type
    when "Buy"
      @positions.each do |position|
        if position.symbol == @transaction.symbol
          position_total = position.quantity * position.cost_per_share
          transaction_total = @transaction.quantity * @transaction.price
          position.update(quantity: position.quantity + @transaction.quantity)
          position.update(cost_per_share: (position_total + transaction_total) / position.quantity)
          @transaction.commission == nil ? @transaction.commission = 0 : @transaction.commission
          @transaction.fee == nil ? @transaction.fee = 0 : @transaction.fee
          @portfolio.cash = @portfolio.cash - (transaction_total + @transaction.commission + @transaction.fee)
        end
      end
      else
    end
    # new_position = Position.new(open_date: @transaction.trade_date, symbol: @transaction.symbol, quantity: @transaction.quantity, cost_per_share: @transaction.price, portfolio_id: @portfolio.id)
    # new_position.save
  end

  # POST /transactions or /transactions.json
  def create
    @transaction = Transaction.new(transaction_params)
    @portfolio = Portfolio.find(params[:portfolio_id])
    create_new_position

    respond_to do |format|
      if @transaction.save
        format.html { redirect_to user_portfolio_transactions_url(@transaction), notice: "Transaction was successfully created." }
        format.json { render :show, status: :created, location: @transaction }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
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
