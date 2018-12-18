Rails.application.routes.draw do
  devise_for :users, path: '', path_names: { sign_in: 'myapp_login', sign_out: 'myapp_logout' },
             only: [:sessions]

  apipie

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      devise_scope :user do
        post '/auth/sign_in', to: 'sessions#create'
        delete '/auth/sign_out', to: 'sessions#destroy'
        post '/auth/passwords', to: 'passwords#create'
        put '/auth/passwords', to: 'passwords#update'
        post '/auth', to: 'registrations#create'
        put '/auth', to: 'registrations#update'
        delete '/auth', to: 'registrations#destroy'
      end
    end
  end
end
