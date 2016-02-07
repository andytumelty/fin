Fin::Application.routes.draw do

  root 'transactions#index'

  get 'login' => 'user_sessions#new', :as => :login
  post 'logout' => 'user_sessions#destroy', :as => :logout

  get '/transactions/import' => 'transactions#import', :as => :transactions_import
  post '/transactions/import' => 'transactions#load_import', :as => :transactions_load_import
  get '/transactions/import/errors' => 'transactions#import_errors', :as => :transactions_import_errors
  get '/transactions/filter' => 'transactions#filter', :as => :transactions_filter
  resources :transactions, except: [:new]
  get '/budgets/latest' => 'budgets#show', id: 'latest', :as => :latest_budget

  resources :accounts, except: :show do
    resources :remote_accounts, except: :show
    get 'remote_accounts/:id/sync' => 'remote_accounts#get_credentials', as: :remote_account_get_credentials
    post 'remote_accounts/:id/sync' => 'remote_accounts#sync', as: :remote_account_sync
  end
  resources :categories, except: :show
  resources :users, except: [:index, :show]
  resources :user_sessions
  resources :budgets do
    resources :reservations
  end


  get 'pages/about'
  get 'pages/privacy'
  get 'pages/contact'
  get 'pages/terms'
end
