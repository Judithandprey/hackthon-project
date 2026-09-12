Rails.application.routes.draw do
  root "home#index"
  get "/up", to: "health#show"
  get "/sign_up", to: "users#new", as: :sign_up
  post "/sign_up", to: "users#create"
  get "/sign_in", to: "sessions#new", as: :sign_in
  post "/sign_in", to: "sessions#create"
  delete "/sign_out", to: "sessions#destroy", as: :sign_out
  resource :application, controller: "applications", only: [:show, :create, :update]
  namespace :organizer do
    resources :applications, only: [:index, :show] do
      resource :review, only: [:update]
    end
  end
end
