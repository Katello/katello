Foreman::Application.routes.draw do
  mount Katello::Engine, :at => '/', :as => 'katello'
end
