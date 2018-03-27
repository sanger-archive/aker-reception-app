Rails.application.routes.draw do
  root 'material_submissions#index'

  get '/materials_schema', to: 'material_submissions#schema'
  get '/hmdmc', to: 'material_submissions#hmdmc_validate'

  get '/material_receptions/waiting', to: 'material_receptions#pending_receptions'
    
  resources :material_receptions
  resources :material_submissions do
    resources :build, controller: 'submissions'
    put :biomaterial_data, controller: 'submissions'
  end

  resources :completed_submissions, only: [:index]
  post '/completed_submissions/print', to: 'completed_submissions#print'
  post '/completed_submissions/dispatch', to: 'completed_submissions#dispatch_submission'

end
