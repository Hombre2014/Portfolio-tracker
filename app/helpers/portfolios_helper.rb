require 'finnhub_ruby'

module PortfoliosHelper

  FinnhubRuby.configure do |config|
    config.api_key['api_key'] = 'c80h0baad3id4r2t4p50'
  end
end
