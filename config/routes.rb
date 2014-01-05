Fin::Application.routes.draw do
  root :to => 'transactions#index'

  resources :users, except: [:index, :show]
  resources :user_sessions
  resources :accounts, except: :show
  resources :categories, except: :show
  resources :transactions, except: [:show, :new]

  get '/transactions/filter' => 'transactions#filter', :as => :transactions_filter
  get '/transactions/import' => 'transactions#import', :as => :transactions_import
  post '/transactions/import' => 'transactions#load_import', :as => :transactions_load_import

  get 'login' => 'user_sessions#new', :as => :login
  post 'logout' => 'user_sessions#destroy', :as => :logout
end
