Rails.application.routes.draw do
  devise_for :users
  resources :users do
    resources :portfolios do
      resources :positions
    end
  end

  root "users#index"
end
