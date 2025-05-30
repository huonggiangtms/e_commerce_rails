Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }
  root "home#index"

  resources :products

  resource :cart, only: [ :show ] do
    resources :cart_items, only: [ :create, :update, :destroy ]
  end

  resources :chatbot, only: [ :index, :create ]
  resources :load_mores, only: [ :index ]

  resources :orders, only: [ :new, :create, :show, :index ]

  resources :order_cancellations, only: [ :create ]

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
    resources :categories
    resources :products
    resources :banners
    resources :faqs
    resources :orders
  end
end
