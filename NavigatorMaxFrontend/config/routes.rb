NavigatorMaxFrontend::Application.routes.draw do

  match '/' => 'main#index'

  match '*anything' => 'Main#catchall', :as => :catchall
end
