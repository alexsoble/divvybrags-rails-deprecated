DivvyBrag::Application.routes.draw do

  root :to => 'pages#home'

  get '/home' => 'pages#home'
  get '/about' => 'pages#about'
  get '/leaderboard' => 'pages#leaderboard'

  resources :posts

  get '/:username' => 'posts#show'

end
