DivvyBrag::Application.routes.draw do

  root :to => 'pages#home'

  get '/home' => 'pages#home'
  get '/about' => 'pages#about'
  get '/leaderboard' => 'pages#leaderboard'

  resources :posts

  get '/authorize' => 'pages#authorize'
  get '/auth/google/callback' => 'pages#home'

  post '/parse_data' => 'posts#create'

  get '/:username' => 'posts#show'

end
