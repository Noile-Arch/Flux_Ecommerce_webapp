Rails.application.routes.draw do
  # Authentication routes
  post 'auth/register', to: 'auth#register'
  post 'auth/login', to: 'auth#login'

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Resources for products
  resources :products do
    collection do
      get 'by_category/:category', to: 'products#by_category'
      get 'search', to: 'products#search'
    end
  end

  # Resources for carts
  resources :carts, only: [:index] do
    post 'add_to_cart', on: :collection
    delete 'remove_from_cart/:cart_item_id', on: :collection, to: 'carts#remove_from_cart'
  end

  # Resources for orders
  resources :orders, only: [:create, :index] do
    member do
      patch 'update_status'
    end
  end

  namespace :admin do
    get 'stats', to: 'admin#stats'
    resources :products, only: [:index, :create, :update, :destroy], param: :uuid
    resources :users, only: [:index]
    resources :orders, only: [:index, :update, :destroy]
  end
end
