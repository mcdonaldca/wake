Rails.application.routes.draw do

  get   '/login', :to => 'sessions#new', :as => :login
  #match '/auth/:provider/callback', :to => 'sessions#create'
  #match '/auth/failure', :to => 'sessions#failure'

  root 'main#index'
  get 'select' => 'main#select', :as => 'select'
  get 'identity/:name' => 'main#identity', :as => 'identity'
  get 'dashboard' => 'main#dashboard', :as => 'dashboard'
  get 'sleep_watch' => 'main#sleep_watch', :as => 'sleep_watch'
  get 'set_sleep_watch/:mode' => 'main#set_sleep_watch', :as => 'set_sleep_watch'
  get 'set_aural/:mode' => 'main#set_aural', :as => 'set_aural'
  get 'set_pebble_loc/:loc' => 'main#set_pebble_loc', :as => 'set_pebble_loc'

  get 'handle_television' => 'main#handle_television', :as => 'handle_television'
  get 'handle_home' => 'main#handle_home', :as => 'handle_home'
  get 'make_sound' => 'main#make_sound', :as => 'make_sound'
  get 'phone_answered' => 'main#phone_answered', :as => 'phone_answered'

  get 'smartthings_auth' => 'main#smartthings_auth', :as => "smartthings_auth"
  get 'smartthings' => 'main#smartthings', :as => "smartthings"
  post 'fibit_auth' => 'main#fitbit_auth', :as => "fitbit_auth"

  get 'asleep' => 'main#asleep', :as => 'asleep'
  get 'reset' => 'main#reset', :as => 'reset'
  get 'pebble_nod' => 'main#pebble_nod', :as => 'pebble_nod'
  get 'pebble_button' => 'main#pebble_button', :as => 'pebble_button'
  get 'fitbit_sleep' => 'main#fitbit_sleep', :as => 'fitbit_sleep'


end
