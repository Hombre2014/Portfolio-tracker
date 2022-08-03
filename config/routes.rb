Rails.application.routes.draw do
  resources :stocks
  devise_for :users
  resources :users, only: [:index, :show] do
    resources :portfolios do
      resources :positions
      resources :transactions
    end
  end

  root "users#index"
end
