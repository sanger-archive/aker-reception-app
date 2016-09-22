Rails.application.routes.draw do

  root 'material_submissions#index'

  resources :material_submissions do
    resources :build, controller: 'submissions'
  end
end
