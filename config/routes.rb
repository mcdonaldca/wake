Rails.application.routes.draw do


  root 'main#index'
  get 'select' => 'main#select', :as => 'select'
  get 'identity/:name' => 'main#identity', :as => 'identity'
  get 'dashboard' => 'main#dashboard', :as => 'dashboard'
  get 'sleep_watch' => 'main#sleep_watch', :as => 'sleep_watch'

  get 'asleep' => 'main#asleep', :as => 'asleep'
  get 'reset' => 'main#reset', :as => 'reset'
  get 'pebble_nod' => 'main#pebble_nod', :as => 'pebble_nod'
  get 'pebble_button' => 'main#pebble_button', :as => 'pebble_button'
  get 'fitbit_sleep' => 'main#fitbit_sleep', :as => 'fitbit_sleep'

end
