Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  root "rails/health#show"

  get "walking-skeleton" => "walking_skeleton#show"

  namespace :api do
    namespace :v1 do
      post "login" => "sessions#create", as: :login
      post "logout" => "sessions#destroy", as: :logout
      resources :rooms, only: [ :index, :show ] do
        collection do
          delete :all, action: :destroy_all
        end
      end
      resources :games, only: [ :index, :create, :show ] do
        member do
          get :roles
          post :restart
          scope :roles do
            post ":role", action: :assign, as: :assign_role
          end
        end
      end
    end
  end
end
