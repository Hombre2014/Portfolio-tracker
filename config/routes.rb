Rails.application.routes.draw do
  resources :portfolios do
    resources :positions
  end

  root "portfolios#index"
end
