DivvyBrag::Application.routes.draw do

  root :to => 'pages#home'

  get '/game' => 'pages#game'
  get '/home' => 'pages#home'
  get '/about' => 'pages#about'
  get '/forum' => 'pages#forum'
  get '/leaderboard' => 'pages#leaderboard'

  get '/auth/twitter/callback' => 'sessions#create'
  get '/signout' => 'sessions#destroy'

  resources :posts
  resources :topics

  get '/authorize' => 'pages#authorize'
  get '/auth/google/callback' => 'pages#home'

  get '/:username' => 'posts#show'

end
