require_relative '../helpers/transactions_helper'

class TransactionsController < ApplicationController
include Pagy::Backend

  before_action :authenticate_user!
  before_action :set_transaction, only: %i[show edit update destroy]

  include TransactionsHelper

  # GET /transactions or /transactions.json
  def index
    reset_instance_variable
    @q = Transaction.ransack(params[:q])
    # @transactions = @q.result(distinct: true).where(portfolio_id: params[:portfolio_id]).order('trade_date DESC')
    @pagy, @transactions = pagy(@q.result(distinct: true).where(portfolio_id: params[:portfolio_id]).order('trade_date DESC'), items: 10)
  end

  # GET /transactions/1 or /transactions/1.json
  def show
    reset_instance_variable
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
    initial_setup
    @portfolio = Portfolio.find(params[:portfolio_id])
    current_transaction = "/users/#{current_user.id}/portfolios/#{params[:id]}/transactions/#{params[:id]}"

    respond_to do |format|
      if ticker_exist?(@transaction)
        if date_valid?(@transaction)
          case @transaction.tr_type
          when ''
            format.html do
              redirect_to current_transaction, alert: 'Please, select one of the transaction types.'
            end
          when 'Buy'
            if enough_cash?(@transaction)
              if short_position_exist?(@transaction)
                format.html do
                  redirect_to current_transaction, alert: 'You have a short position in this security. You cannot buy shares, before you cover the short position.'
                end
              else
                transaction_save(@transaction, format)
              end
            else
              format.html do
                redirect_to current_transaction, alert: 'Not enough cash to complete the transaction.'
              end
            end
          when 'Sell'
            unless short_position_exist?(@transaction)
              if enough_shares?(@transaction)
                if closing_date_earlier_than_opening_date?(@transaction)
                  format.html do
                    redirect_to current_transaction, alert: 'Trying to record a sell transaction before the buy transaction. Check your transaction date!'
                  end
                else
                  transaction_save(@transaction, format)
                end
              else
                format.html do
                  redirect_to current_transaction, alert: 'Not enough shares to complete the transaction.'
                end
              end
            else
              format.html do
                redirect_to current_transaction, alert: 'You have a short position in this security. If you want to sell more shares use Sell short transaction.'
              end
            end
          when 'Sell short'
            unless long_position_exist?(@transaction)
              transaction_save(@transaction, format)
            else
              format.html do
                redirect_to current_transaction, alert: 'You have a long position in this security.'
              end
            end
          when 'Buy to cover'
            unless long_position_exist?(@transaction)
              if short_position_exist?(@transaction)
                if enough_cash?(@transaction)
                  if enough_shares?(@transaction)
                    if closing_date_earlier_than_opening_date?(@transaction)
                      format.html do
                        redirect_to current_transaction, alert: 'Trying to record a buy to cover transaction before the sell short transaction. Check your transaction date!'
                      end
                    else
                      transaction_save(@transaction, format)
                    end
                  else
                    format.html do
                      redirect_to current_transaction, alert: 'Not enough short shares to complete the transaction.'
                    end
                  end
                else
                  format.html do
                    redirect_to current_transaction, alert: 'Not enough cash to complete the transaction.'
                  end
                end
              else
                format.html do
                  redirect_to current_transaction, alert: 'You do not have a short position in this security.'
                end
              end
            else
              format.html do
                redirect_to current_transaction, alert: 'You have a long position in this security.'
              end
            end
          when 'Cash In', 'Interest Inc.'
            if closing_date_earlier_than_opening_date?(@transaction)
              format.html do
                redirect_to current_transaction, alert: 'Trying to record a cash in transaction before the portfolio open date. Check your transaction date!'
              end
            else
              transaction_save(@transaction, format)
            end
          when 'Cash Out', 'Misc. Exp.'
            if enough_cash?(@transaction)
              if closing_date_earlier_than_opening_date?(@transaction)
                format.html do
                  redirect_to current_transaction, alert: 'Trying to record a cash out or expense transaction before Cash In transaction or at this time there was not enough money to withdraw. Check your transaction date!'
                end
              else
                transaction_save(@transaction, format)
              end
            else
              format.html do
                redirect_to current_transaction, alert: 'Not enough cash to complete the transaction.'
              end
            end
          when 'Dividend'
            if long_position_exist?(@transaction)
              if closing_date_earlier_than_opening_date?(@transaction)
                format.html do
                  redirect_to current_transaction, alert: 'Trying to record a dividend transaction before the buy transaction. Check your transaction date!'
                end
              else
                transaction_save(@transaction, format)
              end
            elsif short_position_exist?(@transaction)
              if enough_cash?(@transaction)
                if closing_date_earlier_than_opening_date?(@transaction)
                  format.html do
                    redirect_to current_transaction, alert: 'Trying to record a dividend transaction before the sell short transaction. Check your transaction date!'
                  end
                else
                  transaction_save(@transaction, format)
                end
              else
                format.html do
                  redirect_to current_transaction, alert: 'Not enough cash to complete the transaction. Raise more cash before recording a dividend transaction for short position.'
                end
              end
            else
              format.html do
                redirect_to current_transaction, alert: 'You do not have a position in this security.'
              end
            end
          when 'Reinvest Div.'
            if long_position_exist?(@transaction)
              if closing_date_earlier_than_opening_date?(@transaction)
                format.html do
                  redirect_to current_transaction, alert: 'Trying to record a reinvest dividend transaction before the buy transaction. Check your transaction date!'
                end
              else
                transaction_save(@transaction, format)
              end
            else
              format.html do
                redirect_to current_transaction, alert: 'You do not have a long position in this security.'
              end
            end
          when 'Stock Split'
            if closing_date_earlier_than_opening_date?(@transaction)
              format.html do
                redirect_to current_transaction, alert: 'Trying to record a stock split transaction before the buy or sell short transaction. Check your transaction date!'
              end
            else
              transaction_save(@transaction, format)
            end
          when 'Symbol Change'
            if @stock_symbols.include?(@transaction.symbol)
              if closing_date_earlier_than_opening_date?(@transaction)
                format.html do
                  redirect_to current_transaction, alert: 'Trying to record a symbol change transaction before the buy or sell short transaction. Check your transaction date!'
                end
              else
                transaction_save(@transaction, format)
              end
            else
              format.html do
                redirect_to current_transaction, alert: 'You have not used this stock before. There is no need to record a symbol change.'
              end
            end
          when 'Shares in'
            if short_position_exist?(@transaction)
              format.html do
                redirect_to current_transaction, alert: 'You have a short position in this security. You cannot record a Shares in transaction. First you need to cover the short position.'
              end
            else
              transaction_save(@transaction, format)
            end
          when 'Shares out'
            if long_position_exist?(@transaction)
              if enough_shares?(@transaction)
                if closing_date_earlier_than_opening_date?(@transaction)
                  format.html do
                    redirect_to current_transaction, alert: 'Trying to record a shares out transaction before the Buy or Shares in transactions. Check your transaction date!'
                  end
                else
                  transaction_save(@transaction, format)
                end
              else
                format.html do
                  redirect_to current_transaction, alert: 'Not enough shares to complete the transaction.'
                end
              end
            else
              format.html do
                redirect_to current_transaction, alert: 'You do not have a long position in this security.'
              end
            end
          end
        else
          format.html do
            redirect_to current_transaction, alert: 'Transaction date is before the portfolio open date.'
          end
        end
      else
        format.html do
          redirect_to current_transaction , alert: 'Unsupported or wrong stock ticker.'
        end
      end
    end
    create_update_stock(@transaction) unless @transaction.tr_type == 'Cash In' || @transaction.tr_type == 'Cash Out'  || @transaction.tr_type == 'Interest Inc.' || @transaction.tr_type == 'Misc. Exp.'
    create_update_position(@transaction)
  end

  # PATCH/PUT /transactions/1 or /transactions/1.json
  def update
    respond_to do |format|
      if enough_cash?(@transaction)
        if @transaction.update(transaction_params)
          format.html do
            redirect_to user_portfolio_transaction_url(@transaction), notice: 'Transaction was successfully updated.'
          end
          format.json { render :show, status: :ok, location: @transaction }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @transaction.errors, status: :unprocessable_entity }
        end
      else
        format.html do
          redirect_to current_transaction, alert: 'Not enough cash to complete transaction.'
        end
      end
    end
  end

  # DELETE /transactions/1 or /transactions/1.json
  def destroy
    @transaction.destroy

    respond_to do |format|
      format.html { redirect_to user_portfolio_transactions_url, notice: 'Transaction was successfully destroyed.' }
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
    params.require(:transaction).permit(:tr_type, :trade_date, :symbol, :quantity, :price, :commission, :fee, :portfolio_id, :div_per_share,
                                        :closing_price, :new_shares, :old_shares, :new_symbol)
  end
end
