class PortfoliosController < ApplicationController
  before_action :set_portfolio, only: %i[ show edit update destroy ]

  # GET /portfolios or /portfolios.json
  def index
    @portfolios = Portfolio.where(user_id: current_user.id)
    @positions = Position.all
    @total = 0
  end

  # GET /portfolios/1 or /portfolios/1.json
  def show
    @positions = Position.all
    @total = 0
  end

  # GET /portfolios/new
  def new
    @portfolio = Portfolio.new
  end

  # GET /portfolios/1/edit
  def edit
  end

  # POST /portfolios or /portfolios.json
  def create
    @portfolio = Portfolio.new(portfolio_params)

    respond_to do |format|
      if @portfolio.save
        format.html { redirect_to user_portfolios_url(@portfolio), notice: "Portfolio was successfully created." }
        format.json { render :show, status: :created, location: @portfolio }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @portfolio.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /portfolios/1 or /portfolios/1.json
  def update
    respond_to do |format|
      if @portfolio.update(portfolio_params)
        format.html { redirect_to "/users/#{current_user.id}/portfolios/#{@portfolio.id}", notice: "Portfolio was successfully updated." }
        format.json { render :show, status: :ok, location: @portfolio }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @portfolio.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /portfolios/1 or /portfolios/1.json
  def destroy
    @portfolio.destroy

    respond_to do |format|
      format.html { redirect_to user_portfolios_url, notice: "Portfolio was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_portfolio
      @portfolio = Portfolio.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def portfolio_params
      params.require(:portfolio).permit(:name, :acc_number, :balance, :user_id)
    end
end
