Rails.application.routes.draw do
  root 'material_submissions#index'

  get '/materials_schema', to: 'material_submissions#schema'

  resources :material_receptions
  resources :material_submissions do
    resources :build, controller: 'submissions'
    put :biomaterial_data, controller: 'submissions'
  end
  resources :claim_submissions

  post '/find_submissions_by_user', to: 'claim_submissions#find_submissions_by_user'

  resources :completed_submissions
  post '/completed_submissions/print', to: 'completed_submissions#print'

end
