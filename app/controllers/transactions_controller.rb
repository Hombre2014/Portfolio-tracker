require_relative "../helpers/transactions_helper"

class TransactionsController < ApplicationController
  include TransactionsHelper
  before_action :set_transaction, only: %i[ show edit update destroy ]

  # GET /transactions or /transactions.json
  def index
    @total_fees = 0
    @income_spent = 0
    @total_commissions = 0
    @portfolio = Portfolio.find(params[:portfolio_id])
    @positions = Position.where(portfolio_id: params[:portfolio_id])
    @transactions = Transaction.where(portfolio_id: params[:portfolio_id])
  end

  # GET /transactions/1 or /transactions/1.json
  def show
    @total_fees = 0
    @income_spent = 0
    @total_commissions = 0
    @portfolio = Portfolio.find(params[:portfolio_id])
    @positions = Position.where(portfolio_id: params[:portfolio_id])
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

  # POST /transactions or /transactions.json
  def create
    @transaction = Transaction.new(transaction_params)
    @portfolio = Portfolio.find(params[:portfolio_id])
    @positions = Position.where(portfolio_id: params[:portfolio_id])
    @finnhub_client = FinnhubRuby::DefaultApi.new
    @stocks = Stock.where(portfolio_id: params[:portfolio_id])
    @stock_symbols = @stocks.all.map { |stock| stock.ticker }
    @stock = @stocks.find_by(ticker: @transaction.symbol)

    # @tr_cost = 0
    # @buy_total = 0
    # @realized_profit_loss = 0

    respond_to do |format|
      case @transaction.tr_type
      when "Buy"
        if enough_cash?(@transaction)
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
      when "Sell"
        if enough_shares?(@transaction)
          if @transaction.save
            format.html { redirect_to "/users/#{current_user.id}/portfolios/#{params[:portfolio_id]}/transactions/#{params[:id]}", notice: "Transaction was successfully created." }
            format.json { render :show, status: :created, location: @transaction }
          else
            format.html { render :new, status: :unprocessable_entity }
            format.json { render json: @transaction.errors, status: :unprocessable_entity }
          end
        else
          format.html { redirect_to "/users/#{current_user.id}/portfolios/#{params[:id]}/transactions/#{params[:id]}", alert: "Not enough shares to complete transaction." }
        end
      end
    end
    create_update_stock(@transaction)
    create_update_position(@transaction)
  end

  # PATCH/PUT /transactions/1 or /transactions/1.json
  def update
    respond_to do |format|
      if enough_cash?(@transaction)
        if @transaction.update(transaction_params)
          format.html { redirect_to user_portfolio_transaction_url(@transaction), notice: "Transaction was successfully updated." }
          format.json { render :show, status: :ok, location: @transaction }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @transaction.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to "/users/#{current_user.id}/portfolios/#{params[:id]}/transactions/#{params[:id]}", alert: "Not enough cash to complete transaction." }
      end
    end
    # update_new_position
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
