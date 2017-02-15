Lsrs::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action
	get '/lsrs/client' => 'lsrs#client'
	get '/lsrs/service' => 'lsrs#service'

	get '/lsrsmulticrop/client' => 'lsrsmulticrop#client'
	get '/lsrsmulticrop/service' => 'lsrsmulticrop#service'
	
	get '/lsrsbatch/client' => 'lsrsbatch#client'
	get '/lsrsbatch/service' => 'lsrsbatch#service'

	get '/:service/wadl.xml' => 'wadl#WADL'
	
	get '/batch/results/:tmpdir/output.kml' => 'kml#create'
	
# version 5 (REST)
	get '/lsrs5/debug.html' => 'lsrs5#debug'
	get '/lsrs5/crop/alfalfa/climate/:ppe/:gdd/:gsl/:esm/:efm/:view.:format' => 'crop_alfalfa#climate'
	get '/lsrs5/crop/brome/climate/:ppe/:gdd/:gsl/:esm/:efm/:view.:format' => 'crop_brome#climate'
	get '/lsrs5/crop/canola/climate/:ppe/:egdd/:canhm/:esm/:efm/:view.:format' => 'crop_canola#climate'
	get '/lsrs5/crop/sssgrain/climate/:ppe/:egdd/:esm/:efm/:view.:format' => 'crop_sssgrain#climate'
	get '/lsrs5/crop/corn/climate/:ppe/:chu/:esm/:efm/:view.:format' => 'crop_corn#climate'
	get '/lsrs5/crop/soybean/climate/:ppe/:chu/:esm/:efm/:view.:format' => 'crop_soybean#climate'
	# for SLC, the slope_len will need to be precalculated from locsf

	# for alfalfa, brome, canola,, corn, soybean, sssgrain
	get '/lsrs5/crop/:crop/site/:soil_id/:region/:egdd/:ppe/:slope/:length/:stoniness/:view.:format' => 'crop_fieldcrop#site', :constraints => { :slope => /[^\/]+/ , :stoniness => /[^\/]+/}
	
	
	# new api documentation
	get '/lsrs5/:crop/api.html' => 'api#show'
	# not implemented 
	get '/lsrs5/:service/wadl.xml' => 'wadl#WADL'
	
	# combined service which will be split into climate/soil/landscape
	get '/lsrs5/:soil_id/brome/:ppe/:gdd/:gsl/:region/:slope_p/:slope_len/:stoniness/:management' => 'lsrs5#brome'
	get '/lsrs5/:soil_id/canola/:ppe/:egdd/:region/:slope_p/:slope_len/:stoniness/:management' => 'lsrs5#canola'
	
	get '/lsrs5/:soil_id/potato/:slope/:stoniness/:julymeantemp' => 'lsrs5#potato'
	get '/lsrs5/:soil_id/potato/test' => 'lsrs5#potato'
	

	get '/lsrs5/documentation/:action' => 'documentation5'
	get '/lsrs5/documentation/interface/inputs/:name' => 'documentation5#input'
	get '/lsrs5/documentation/:category/:factor/:crop' => 'documentation5#factorCropSpecificWithChart'
	get '/lsrs5/documentation/:category/:factor' => 'documentation5#canned'


#	get '/contents.html' => 'home#contents'
#	get '/history.html' => 'home#history'
#	get '/tests.html' => 'home#tests

# CIT proxy
	get '/cit/:action', :controller => 'citproxy'
	get '/cit/:action/:id', :controller => 'citproxy'
	post '/cit/create_request', :controller => 'citproxy', :action =>'create_request'
	post '/cit/store_response/:id', :controller => 'citproxy', :action =>'store_response'
	post '/cit/debug', :controller => 'citproxy', :action =>'debug'


# interpNB
	get '/interp/' => 'interp#index'
	get '/interp/sectors' => 'interp#list_sectors'
	get '/interp/:sector' => 'interp#list_interpretations'
	get '/interp/:sector/:interpretation/describe' => 'interp#describe_interpretation'

	resources :soil_managements

	get '/climateindices/documentation/format_lsrs1.html' => 'climateindices#format_lsrs1'
	get '/climateindices/documentation/:name.html' => 'climateindices#describe'
	
#	get '/climateindices/calculate_monthly/polygon/:framework/:polygon/:normals.:format' => 'climateindices#calculate_monthly'
#	get '/climateindices/calculate_monthly/station/:station/:normals.:format' => 'climateindices#calculate_monthly'
	

	#catch-all
	get ':controller/:action'
	post ':controller/:action'

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products
  resources :lsrs_frameworks
  resources :lsrs_cmps
  resources :lsrs_soils
  resources :lsrs_climates
	
	get '/', :controller => 'home', :action => 'index'
	get ':action', :controller => 'home'
	
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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
	#match ':controller/:action'
end
