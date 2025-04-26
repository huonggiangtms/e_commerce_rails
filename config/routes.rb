Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }

  root "home#index"

  namespace :admin do
    root to: "dashboard#index"
    resources :users
    resources :crawl_jobs
    resources :crawled_products do
      member do
        patch :approve
      end
      collection do
        get :manual_crawl
        post :crawl_manual
      end
    end
  end
end
