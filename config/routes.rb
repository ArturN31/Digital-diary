Rails.application.routes.draw do
  get 'tdee/index'
  get 'home/index'
  resources :entries
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  get 'entries', to: 'entries#index' #route /entries
  get 'tdee', to: 'tdee#index' #route /tdee
  root to: "home#index"
  
end
