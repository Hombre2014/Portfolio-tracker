require 'finnhub_ruby'

module UsersHelper
  def gravatar_for(user)
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id} || https://www.gravatar.com/avatar/00000000000000000000000000000000?d=https://img.icons8.com/external-flaticons-flat-flat-icons/256/external-investor-home-based-business-flaticons-flat-flat-icons.png"
    image_tag(gravatar_url, alt: user.name, class: "gravatar avatar")
  end

  def stock_data_for_closed_position(ticker)
    @user = User.find(params[:id])
    @portfolios = @user.portfolios.includes([:positions])
    @positions = Position.where(portfolio_id: @portfolios.ids).where.not(symbol: 'Cash')
    @position_closed_by_user = Stock.where(shares_owned: 0).where(portfolio_id: @portfolios.ids).where(ticker: ticker)
    @finnhub_client = FinnhubRuby::DefaultApi.new
    @stock_data = @finnhub_client.company_profile2({ symbol: ticker })
  end

  def positions_stats(positions)
    @winners_amount = {}
    @winners_percent = {}
    @portfolio_name = {}
    @portfolio_id = {}
    @losers_amount = {}
    @losers_percent = {}
    @stock_rpl_winners = {}
    @stock_rpl_losers = {}
    @dividend_income = {}
    @dividend_loss = {}
    @stats = {}
    positions.each do |position|
      portfolio_id = @portfolios.where(id: position.portfolio_id).pluck(:id)[0]
      @stats.store('portfolio_id', portfolio_id)
      @portfolio_id.store(position.symbol, @stats['portfolio_id'])
      stock_rpl = Stock.find_by(ticker: position.symbol, portfolio_id: @stats['portfolio_id']).realized_profit_loss
      @stats.store('realized_profit_loss', stock_rpl)
      price = @finnhub_client.quote(position.symbol)
      position_cost = position.quantity * position.cost_per_share - position.reinvested_income
      position_value = (position.quantity * price.c).round(2)
      profit_loss = position_value - position_cost
      @stats.store('amount', profit_loss)
      portfolio_name = @portfolios.where(id: position.portfolio_id).pluck(:name)[0]
      @stats.store('portfolio_name', portfolio_name)
      @portfolio_name.store(position.symbol, @stats['portfolio_name'])
      position.quantity < 0 ? 
        @stats.store('percent', profit_loss / position_cost.to_f * -100) : 
        @stats.store('percent', profit_loss / position_cost.to_f * 100)
      @stats.store('percent', @stats['percent'].round(2))
      if profit_loss > 0
        @winners_amount.store(position.symbol, @stats['amount'])
        @winners_percent.store(position.symbol, @stats['percent'])
      elsif profit_loss < 0
        @losers_amount.store(position.symbol, @stats['amount'])
        @losers_percent.store(position.symbol, @stats['percent'])
      end
      if @stats['realized_profit_loss'] > 0
        @stock_rpl_winners.store(position.symbol, @stats['realized_profit_loss'])
      elsif @stats['realized_profit_loss'] < 0
        @stock_rpl_losers.store(position.symbol, @stats['realized_profit_loss'])
      end
      if position.income > 0
        @stats.store('income', position.income)
        @dividend_income.store(position.symbol, @stats['income'])
      elsif position.income < 0
        @stats.store('income', position.income)
        @dividend_loss.store(position.symbol, @stats['income'])
      end
    end
    position_cost = 0
    position_value = 0
  end
end
