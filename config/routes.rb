Rails.application.routes.draw do
  root "pages#home"
  get 'pages/about'
  get 'pages/contact'
  resources :stocks
  devise_for :users, controllers: {
    # registrations: 'users/registrations',
    # sessions: 'users/sessions',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }
  resources :users, only: [:index, :show] do
    resources :portfolios do
      resources :positions
      resources :transactions
    end
  end
end
