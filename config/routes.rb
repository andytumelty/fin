Fin::Application.routes.draw do
  resources :categories

	root :to => 'users#index'
	
	resources :users
	resources :user_sessions
	resources :accounts, except: :show
	resources :categories, except: :show

	get 'login' => 'user_sessions#new', :as => :login
	post 'logout' => 'user_sessions#destroy', :as => :logout

end
