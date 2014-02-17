Foreman::Application.routes.draw do
  mount Fort::Engine, :at => "/fort", :as => 'fort'
end
