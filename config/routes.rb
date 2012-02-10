Worshipschedule::Application.routes.draw do

  resources :teams do
    member do
      get :assign
      put :assign_all, :to => 'teams#assign_all'
      put :remove_all, :to => 'teams#remove_all'
      get :admins
      put :admins, :to => 'teams#update_admins'
      get :slots
    end
    
    resources :availabilities, :only => [:update, :create]
    
    resources :events do
      member do
        put :slots, :to => 'events#slots'
      end
    end
    resources :slots, :only => [:update]
    
    resources :memberships do
      member do
        get :skillships, :to => 'memberships#skillships'
        put :skillships, :to => 'memberships#update_skillships'
      end
    end
    
    resources :skills  do
      member do
        get :skillships, :to => 'skills#skillships'
        put :skillships, :to => 'skills#update_skillships'
      end
    end
  end

  resources :accounts do
    member do
      get :admins
      put :admins, :to => 'accounts#update_admins'
      put :owner
    end
  end
  
  resources :users do
    member do
      put :memberships_for
    end
  end
  
  match "users/:id/send_reset", :to => 'users#send_reset', :as => 'users/send_reset', :only => 'post'
  
  resource :profile, :only => [:edit, :update] do
    get :forgot
    post :send_reset
  end

  match "profile/reset/:token", :to => 'profiles#reset', :as => 'profile/reset'
  match "profile/update_reset/:id", :to => 'profiles#update_reset', :as => 'profile/update_reset', :only => 'post'
  
  resources :sessions, :only => [:new, :create, :destroy]
  get 'sessions/accounts'
  post 'sessions/set_account'
  
  match 'signin' => 'sessions#new'
  match 'signout' => 'sessions#destroy'

  get "pages/home"
  
  root :to => "pages#home"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
