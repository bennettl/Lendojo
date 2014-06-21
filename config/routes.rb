    Rails.application.routes.draw do

    # Root
    root 'static_pages#home'

    # Static pages
    match   'about',    to: 'static_pages#about',       via: 'get'
    match   'contact',  to: 'static_pages#contact',     via: 'get'
    match   'contact_form_submit', to: 'static_pages#contact_form_submit', via: 'post'

    # Sessions
    match   'signin',   to: 'sessions#new',             via: 'get'
    match   'signout',  to: 'sessions#destroy',         via: 'delete'

    ################################## RESOURCES ##################################
    
    # Users
    resources :users do 
        get     'checklist',            on: :collection
        get     'pins',                 on: :collection
        get     'new_rating',           on: :member
        patch   'update_card',          on: :collection
        resources 'reports',            only: [:new, :create]
    end
    
    # User Serivces
    resources :user_services, only: [:create, :destroy, :update] do
        # :collection, no id require
        post    'create_check',         on: :collection
        post    'create_pin',           on: :collection
        # :member, needs an id
        delete  'destroy_check',        on: :member
        delete  'destroy_pin',          on: :member
    end

    # Filters
    resources :filters, only: [:create, :destroy, :update]
   
    # Services
    resources :services do
        resources 'reports',        only: [:new, :create]
    end

    # Products
    resources :products do
        resources 'reports',        only: [:new, :create]
    end

    # Lender Application
    resources :lender_applications
    
    # Ratings
    resources :ratings,             only: [:create]

    # Reviews
    resources :reviews, only: [:create, :destroy, :update] do
        post    'vote',                 on: :member
    end

    # Reports
    resources :reports, only: [:index, :edit, :update]

    # Sessions
    resources :sessions, only: [:new, :create, :destroy]

    # The priority is based upon order of creation: first created -> highest priority.
    # See how all your routes lay out with "rake routes".

    # You can have the root of your site routed with "root"
    # root 'welcome#index'

    # Example of regular route:
    #   get 'products/:id' => 'catalog#view'

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