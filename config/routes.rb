Fin::Application.routes.draw do
  root :to => 'transactions#index'

  resources :users
  resources :user_sessions
  resources :accounts, except: :show
  resources :categories, except: :show
  resources :transactions

  get 'login' => 'user_sessions#new', :as => :login
  post 'logout' => 'user_sessions#destroy', :as => :logout
end
