Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }
  root "home#index"

  namespace :admin do
    root to: "dashboard#index"
    resources :users
  end
end
