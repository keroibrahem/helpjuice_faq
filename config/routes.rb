Rails.application.routes.draw do
  root 'search#index'
  
  post '/track_query', to: 'search_queries#create'
  get '/analytics', to: 'search_queries#analytics'

  resources :articles
  resources :categories

  mount Sidekiq::Web => '/sidekiq' if Rails.env.development?
end