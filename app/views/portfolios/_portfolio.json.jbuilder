json.extract! portfolio, :id, :name, :acc_number, :balance, :created_at, :updated_at
json.url portfolio_url(portfolio, format: :json)
