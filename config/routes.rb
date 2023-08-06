Rails.application.routes.draw do
  get 'welcome/index'
  resources :comments
  resources :posts do
    member do
      post 'add_like'
      post 'add_dislike'
    end
    resources :comments, only: [:create]

  end
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root to: "welcome#index"

end
