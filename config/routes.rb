Rails.application.routes.draw do
  resources :users do
    resources :portfolios do
      resources :positions
    end
  end

  root "users#index"
end
