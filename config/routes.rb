Rails.application.routes.draw do
  resources :user_profiles
  resources :users, only: %i[new create]
  resources :entries
  resource :session, only: %i[new create destroy]

  #custom routes
  get '/entries', to: 'entries#index' #route /entries
  get '/profile', to: 'user_profiles#index' #route /tdee
  get '/archives', to: 'archives#index' #route /archives

  get '/signup', to: 'users#new' #route /signup
  get '/session', to: 'sessions#destroy' #route /session
  get '/login', to: 'sessions#new' #route /login

  get '/change_password', to: 'passwords#edit' #route /change_password
  patch '/change_password', to: 'passwords#update' #route /change_password

  root to: 'home#index'
end
