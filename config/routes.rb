Rails.application.routes.draw do
  get 'sessions/new'
  get '/session', to: 'sessions#destroy'
  
  resources :users, only: %i[new create]
  resources :entries
  resource :session, only: %i[new create destroy]

  get 'entries', to: 'entries#index' #route /entries
  get 'tdee', to: 'tdee#index' #route /tdee
  get 'home', to: 'home#index' #route /home

  root to: 'home#index'
end
