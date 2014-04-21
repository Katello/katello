Foreman::Application.routes.draw do
  mount Bastion::Engine, :at => '/'
end
