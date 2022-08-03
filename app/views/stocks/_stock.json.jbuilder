json.extract! stock, :id, :ticker, :transaction_id, :realized_profit_loss, :created_at, :updated_at
json.url stock_url(stock, format: :json)
