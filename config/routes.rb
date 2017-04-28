Rails.application.routes.draw do

  root 'material_submissions#index'

  post '/submissions/labware_data', to: 'submissions#labware_data'

  resources :material_receptions
  resources :material_submissions do
    resources :build, controller: 'submissions'
  end
  resources :claim_submissions

  post '/find_submissions_by_user', to: 'claim_submissions#find_submissions_by_user'

  get '/get_all_collections', to: 'claim_submissions#get_all_collections'

  resources :completed_submissions
  post '/completed_submissions/print', to: 'completed_submissions#print'
  post '/material_submissions/claim', to: 'submissions#claim'
end
