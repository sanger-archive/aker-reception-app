Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'manifests#index'

  health_check_routes

  get '/materials_schema', to: 'manifests#schema'
  get '/hmdmc', to: 'manifests#hmdmc_validate'

  get '/material_receptions/waiting', to: 'material_receptions#pending_receptions'

  resources :material_receptions

  namespace :manifests do
    resources :print, only: [:index, :create]
    resources :dispatch, only: [:index, :create]
    resources :upload, only: [:create]
  end

  resources :manifests do
    resources :build, controller: 'submissions'
    put :biomaterial_data, controller: 'submissions'
  end

  # Redirect to /manifests in case someone still has links to material_submissions bookmarked or in an email
  get '/material_submissions', to: redirect('manifests')
  get '/material_submissions/:id', to: redirect('manifests/%{id}')
  get '/material_submissions/new', to: redirect('manifests/new')

  namespace :material_submissions do
    get '/print', to: redirect('/manifests/print')
    get '/dispatch', to: redirect('/manifests/dispatch')
  end

end
