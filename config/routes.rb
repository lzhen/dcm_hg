Dcm::Application.routes.draw do
  
  

  resources :course_proficiencies
  
  resources :path_instances

  resources :user_courses
  


  get "vp/index"

  match '/add_completed', :to => 'user_courses#add_completed'
  match '/delete_all_completed', :to => 'user_courses#delete_all_completed'
  match '/add_path_instances', :to => 'path_instances#add_path_instances'
  match '/delete_path_instances', :to => 'path_instances#delete_path_instances'
  match '/add_user_path', :to => 'paths#add_user_path'

  match '/index', :to => 'path_instances#index'

  match '/education/degrees', :to => 'front#degrees'
  match '/education/proficiencies', :to => 'front#proficiencies'
  match '/education/courses', :to => 'front#courses'
  match '/education/faculty', :to => 'front#faculty'
  match '/facilities', :to => 'front#facilities'
  match '/contacts', :to => 'front#contacts'
  match '/about', :to => 'front#about'
  match '/issue', :to => 'front#issue'
  match '/submit_issue', :to => 'front#submit_issue'
  match '/forms', :to => 'front#forms'
  match '/openhouse', :to => 'openhouse#index'
  match '/openhouse/speakers', :to => 'openhouse#speakers'
  match '/openhouse/installations', :to => 'openhouse#installations'
  match '/openhouse/performances', :to => 'openhouse#performances'
  
  match '/logout', :to => 'sessions#destroy'
  match '/login', :to => 'sessions#new'
  match '/bye', :to => 'sessions#bye'
  # match '/about', :to => 'sessions#about'
  match '/cn', :to => 'cn#index'
  match '/help', :to => 'help#help'

  match '/compass', :to => 'compass#index'
  match '/instances', :to => 'instances#index'
  match '/user_courses', :to => 'user_courses#index'
  match '/course_proficiencies', :to => 'course_proficiencies#index'
  match '/semesters', :to => 'semesters#index'
  
  match '/front/course_info', :to => 'front#course_info'

  resources :users do
    collection do
      post :add_right
      get :destroy_right
    end
    member do
      get 'completed'
    end
  end
  

  #map.resources :courses, :collection => { :completed => :get }
  resources :courses do
    collection do 
      get :completed
      get :add_completed_course
      get :remove_course_from_completed_courses
      get :delete_class_from_path
      get :destroy_outgoing_proficiency
      get :destroy_incoming_proficiency
      get :destroy_class
      get :remove_history_course_from_path
      get :lower_incoming_proficiency_level
      get :raise_incoming_proficiency_level
      post :add_outgoing_proficiency
      post :add_incoming_proficiency
      post :add_class
    end
  end

  resources :proficiencies
  resources :paths do
    collection do
      get :add_class_to_path
      get :remove_course_from_completed_courses
      get :delete_class_from_path
      get :remove_history_course_from_path
      get :set_as_current_path
    end
  end
  resources :recommendations
  resources :reviews

  #map.resources :events, :collection => { :admin => :get }
  resources :events do
    collection do
      get :admin
    end
  end
  
  

  resource :session

  match '/map', :to => 'map#index'
#  match '/map/
# match '/map', :to => 'map#index'
#   match '/map/goto_page', :to => 'map#goto_page'
#   match '/map/select', :to => 'map#select'
#   match '/map/remove_selected_from_completed_courses', :to => 'map#remove_selected_from_completed_courses'
#   match '/map/remove_class', :to => 'map#remove_class'
#   match '/map/add_class', :to => 'map#add_class'
#   match '/map/add_completed_course', :to => 'map#add_completed_course'
#   match '/map/look_for_proficiency', :to => 'map#look_for_proficiency'
#   match '/map/remove_course_from_completed_courses', :to => 'map#remove_course_from_completed_courses'
#   match '/map/delete_class_from_path', :to => 'map#delete_class_from_path'
#   match '/map/remove_history_course_from_path', :to => 'map#remove_history_course_from_path'
#   match '/map/clear_look_for_proficiency', :to => 'map#clear_look_for_proficiency'
#   match '/map/history_studies', :to => 'map#history_studies'
#   match '/map/add_history_course', :to => 'map#add_history_course'
#   match '/map/send_path_advisor', :to => 'map#send_path_advisor'

  match '/planner', :to => "visual_planner#index"
  
  root :to => "front#index"
  
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