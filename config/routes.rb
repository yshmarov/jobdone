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
    get :planned_in_past, on: :collection
  	member do
  		patch :mark_planned
  		patch :mark_confirmed
  		patch :mark_confirmed_by_client
  		patch :mark_not_attended
  		patch :mark_rejected_by_us
  		patch :mark_cancelled_by_client
    end

  end

  get 'job_stats', to: 'static_pages#job_stats'
  get 'other_stats', to: 'static_pages#other_stats'
  get 'calendar', to: 'static_pages#calendar'
  root to: 'static_pages#landing_page'
end
