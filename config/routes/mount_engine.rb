Foreman::Application.routes.draw do
  mount Katello::Engine, :at => "/"
end
