require 'katello/plugin.rb'

Foreman::Plugin.find(:katello).security_block :activation_keys do
  permission :view_activation_keys,
             {
               'katello/activation_keys' => [:all, :index, :auto_complete_search],
               'katello/api/v2/activation_keys' => [:index, :show, :available_host_collections, :available_releases]
             },
             :resource_type => 'Katello::ActivationKey'
  permission :create_activation_keys,
             {
               'katello/api/v2/activation_keys' => [:create],
             },
             :resource_type => 'Katello::ActivationKey'
  permission :edit_activation_keys,
             {
               'katello/api/v2/activation_keys' => [:update, :content_override],
             },
             :resource_type => 'Katello::ActivationKey'
  permission :destroy_activation_keys,
             {
               'katello/api/v2/activation_keys' => [:destroy],
             },
             :resource_type => 'Katello::ActivationKey'
end
