Foreman::Application.routes.draw do
  mount Katello::Engine, :at => "/katello", :as => 'katello'
end
