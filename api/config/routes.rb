Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post "auth/register", to: "auth#register"
      post "auth/login", to: "auth#login"
      get "me", to: "me#show"

      get "dashboard", to: "dashboard#show"

      resources :products
      resources :customers
      resources :orders, only: [ :index, :show, :create, :update ]
    end
  end
end
