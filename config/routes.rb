Rails.application.routes.draw do
  devise_for :users,
    path: "api/v1/auth",
    path_names: { sign_in: "sign_in", sign_out: "sign_out", registration: "sign_up" },
    controllers: {
      sessions: "api/v1/auth/sessions",
      registrations: "api/v1/auth/registrations"
    }

  namespace :api do
    namespace :v1 do
      resources :categories, only: [:index, :show]
      resources :products, only: [:index, :show]
      resources :orders, only: [:index, :show, :create]

      resource :cart, only: [:show, :destroy] do
        post   "items",             action: :add_item
        patch  "items/:product_id", action: :update_item
        delete "items/:product_id", action: :remove_item
      end

      namespace :admin do
        resources :products
        resources :orders, only: [:index, :show, :update]
        resources :categories
      end
    end
  end

  post "/webhooks/razorpay", to: "webhooks#razorpay"

  get "up" => "rails/health#show", as: :rails_health_check
end
