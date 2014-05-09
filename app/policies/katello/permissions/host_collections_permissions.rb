require 'katello/plugin.rb'

Foreman::Plugin.find(:katello).security_block :host_collections do
  permission :view_host_collections,
             {
                 'katello/host_collections' => [:all, :index],
                 'katello/api/v2/host_collections' => [:index, :show]
             },
             :resource_type => 'Katello::HostCollection'
  permission :create_host_collections,
             {
                 'katello/api/v2/host_collections' => [:create],
             },
             :resource_type => 'Katello::HostCollection'
  permission :update_host_collections,
             {
                 'katello/api/v2/host_collections' => [:update, :add_systems, :remove_systems],
             },
             :resource_type => 'Katello::HostCollection'
  permission :destroy_host_collections,
             {
                 'katello/api/v2/host_collections' => [:destroy],
             },
             :resource_type => 'Katello::HostCollection'
end
