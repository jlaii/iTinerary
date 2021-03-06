Rails.application.routes.draw do
  resources :user_trips
  devise_for :users, controllers: {omniauth_callbacks: "omniauth_callbacks", :passwords => "passwords"}
  get 'users/new'


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  root 'welcome#welcome'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  get 'dashboard' => 'users#show', as: :user_show
  get 'dashboard/trips/:id' => 'trips#show', as: :user_trip_show

  get 'attractions/:id' => 'attractions#show_by_id', as: :attraction_show_by_id

  get 'attractions/' => 'attractions#show', as: :show_attractions
  get 'trips/:id' => 'trips#show', as: :trip_show
  get 'trips/:trip_id/itinerary' => 'trips#show_itinerary', as: :show_itinerary
  post 'dashboard/:id' => 'trips#delete', as: :delete_trip

  post 'attractions/' => 'trips#new', as: :trip_new
  get 'trips/' => 'trips#create_and_save_trip', as: :trip_create_save

  post 'welcome/save' => 'welcome#save', as: :trip_save
  # post 'submitClicked' => 'welcome#submitClicked'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
