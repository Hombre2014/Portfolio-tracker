Rails.application.routes.draw do
  # get 'pages/home'
  resources :stocks
  devise_for :users
  resources :users, only: [:index, :show] do
    resources :portfolios do
      resources :positions
      resources :transactions
    end
  end

  root "pages#home"
end
