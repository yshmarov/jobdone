Rails.application.routes.draw do
  #get 'comments/index'
  #get 'comments/new'
  devise_for :users, controllers: { invitations: 'invitations'}
  #devise_for :users, controllers: { registrations: "registrations", invitations: 'invitations'}
  #devise_for :users

  resources :employees do 
    resources :skills, only: [:new, :create, :destroy]
  	member do
  		patch :invite_user
    end
  end

  resources :clients do
    resources :comments
  end

  resources :services
  resources :service_categories, except: [:show]

  resources :locations do
    resources :workplaces
  end
  resources :workplaces, only: :index

  resources :jobs do
    resources :comments
  end
  get 'stats', to: 'static_pages#stats'
  get 'calendar', to: 'static_pages#calendar'
  root to: 'static_pages#landing_page'
end
