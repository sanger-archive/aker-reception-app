Rails.application.routes.draw do

  root 'material_submissions#index'

  get '/materials_schema', to: 'material_submissions#schema'

  resources :material_receptions
  resources :material_submissions do
    resources :build, controller: 'submissions'
  end
  resources :claim_submissions

  post '/find_submissions_by_user', to: 'claim_submissions#find_submissions_by_user'

  get '/get_all_collections', to: 'claim_submissions#get_all_collections'
end
