require 'katello/plugin.rb'

Foreman::Plugin.find(:katello).security_block :host_collections do
  permission :view_host_collections,
             {
               'katello/api/v2/host_collections' => [:index, :show, :auto_complete_search]
             },
             :resource_type => 'Katello::HostCollection'
  permission :create_host_collections,
             {
               'katello/api/v2/host_collections' => [:create, :copy]
             },
             :resource_type => 'Katello::HostCollection'
  permission :edit_host_collections,
             {
               'katello/api/v2/host_collections' => [:update, :add_hosts, :remove_hosts]
             },
             :resource_type => 'Katello::HostCollection'
  permission :destroy_host_collections,
             {
               'katello/api/v2/host_collections' => [:destroy]
             },
             :resource_type => 'Katello::HostCollection'
end
