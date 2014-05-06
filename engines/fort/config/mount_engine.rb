Foreman::Application.routes.draw do
  mount Fort::Engine, :at => "/katello", :as => 'fort'
end
