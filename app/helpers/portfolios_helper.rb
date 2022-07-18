require 'finnhub_ruby'

module PortfoliosHelper

  FinnhubRuby.configure do |config|
    config.api_key['api_key'] = ENV['API_KEY']
  end
end
