Rails.application.routes.draw do
  resources :users, only: %i[new create]
  resources :entries
  resource :session, only: %i[new create destroy]

  #custom routes
  get '/entries', to: 'entries#index' #route /entries
  get '/tdee', to: 'tdee#index' #route /tdee

  get '/signup', to: 'users#new' #route /signup
  get '/session', to: 'sessions#destroy' #route /session
  get '/login', to: 'sessions#new' #route /login

  root to: 'home#index'
end
