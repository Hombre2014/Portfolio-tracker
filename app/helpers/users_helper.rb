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
end
