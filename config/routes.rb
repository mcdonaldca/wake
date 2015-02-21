Rails.application.routes.draw do


  root 'main#index'
  get 'select' => 'main#select', :as => 'select'
  get 'identity/:name' => 'main#identity', :as => 'identity'
  get 'dashboard' => 'main#dashboard', :as => 'dashboard'

  get 'asleep' => 'main#asleep', :as => 'asleep'
  get 'reset' => 'main#reset', :as => 'reset'
  get 'pebble_nod' => 'main#pebble_nod', :as => 'pebble_nod'
  get 'fitbit_sleep' => 'main#fitbit_sleep', :as => 'fitbit_sleep'

end
