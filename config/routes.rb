DivvyBrag::Application.routes.draw do

  root :to => 'pages#home'

  get '/home' => 'pages#home'
  get '/about' => 'pages#about'
  get '/leaderboard' => 'pages#leaderboard'
  # get '/oauth2authorize' => 'pages#authorize' 
  # get '/oauth2callback' => 'pages#callback'

  resources :posts

  get '/:username' => 'posts#show'

end
