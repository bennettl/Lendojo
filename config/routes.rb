Rails.application.routes.draw do

    # Root
    root 'static_pages#home'

    # Static pages
    match   'how_it_works',             to: 'static_pages#how_it_works',            via: 'get'
    match   'contact',                  to: 'static_pages#contact',                 via: 'get'
    match   'guidelines',               to: 'static_pages#guidelines',              via: 'get'
    match   'privacy',                  to: 'static_pages#privacy',                 via: 'get'
    match   'faqs',                     to: 'static_pages#faqs',                    via: 'get'
    match   'contact_form_submit',      to: 'static_pages#contact_form_submit',     via: 'post'

    # Devise / Omniauth (Social Authentication)
    devise_for :users, controllers: { omniauth_callbacks: 'omniauth_callbacks' } do
        get "/login", :to => "devise/sessions#new", :as => :login
        get "/signup", :to => "devise/registration#new"
        get "/logout", :to => "devise/sessions#destroy", :as => :logout
    end

    # Sessions
    resources :sessions
    devise_scope :user do 
        match '/sessions/user', to: 'devise/sessions#create', via: :post
        match '/sign_up', to: 'devise/registration#create', via: :post
    end

    ################################## RESOURCES ##################################
    
    # Note: :collection, no id require.  :member, needs an id

    # Users
    resources :users do 
        patch   'update_card',          on: :collection
        get     'checklist',            on: :member
        get     'pins',                 on: :member
        get     'feedback',             on: :member
        get     'finish_signup',        on: :member
        get     'referrals',            on: :member, to: 'referrals#user_index'
        post    'rate',                 on: :member, to: 'ratings#create'
        post    'review',               on: :member, to: 'reviews#create'
        get     'report',               on: :member, to: 'reports#new'
        post    'report',               on: :member, to: 'reports#create'
    end
    
    # User Serivces
    resources :user_services, only: [:create, :destroy, :update] do
        post    'create_check',         on: :collection
        post    'create_pin',           on: :collection
        delete  'destroy_check',        on: :member
        delete  'destroy_pin',          on: :member
    end

    # Filters
    resources :filters, only: [:create, :destroy, :update]
   
    # Services
    resources :services do
        post        'check',            on: :member
        delete      'uncheck',          on: :member
        post        'pin',              on: :member
        delete      'unpin',            on: :member
        get         'report',           on: :member, to: 'reports#new'
        post        'report',           on: :member, to: 'reports#create'
    end

    # Products
    resources :products do
        resources   'report',           on: :member
    end

    # Lender Application
    resources :lender_applications
    
    # Ratings
    resources :ratings

    # Reviews
    resources :reviews do
        post        'vote',                 on: :member
        get         'report',           on: :member, to: 'reports#new'
        post        'report',           on: :member, to: 'reports#create'
    end

    # Reports
    resources :reports

    # Referrals
    resources :referrals

    # Tags
    resources :tags

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