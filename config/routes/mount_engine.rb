Foreman::Application.routes.draw do
  mount Katello::Engine, :at => '/', :as => 'katello'

  post 'hosts/kt_environment_selected', :to => "hosts#kt_environment_selected", :as => :kt_environment_selected_hosts
  post 'hosts/content_view_selected', :to => "hosts#content_view_selected", :as => :content_view_selected_hosts

end
