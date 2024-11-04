Rails.application.routes.draw do

  devise_for :users, only: [:sessions]

  authenticated :user do
    namespace :admin do
      resources :products
      root to: "products#index", as: :admin_root
    end
  end

  unauthenticated :user do
    get '/admin', to: redirect('/users/sign_in')
  end

  # Public products listing routes
  resources :products, only: [:index, :show]

  root 'products#index'
end

