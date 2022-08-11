json.extract! transaction, :id, :tr_type, :trade_date, :symbol, :quantity, :price, :commission, :fee, :portfolio_id,
              :created_at, :updated_at
json.url transaction_url(transaction, format: :json)
