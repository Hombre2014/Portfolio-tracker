Rails.application.routes.draw do
  resources :portfolios
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "portfolios#index"
end
