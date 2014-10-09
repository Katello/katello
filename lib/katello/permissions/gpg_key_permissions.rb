require 'katello/plugin.rb'

Foreman::Plugin.find(:katello).security_block :gpg_keys do
  permission :view_gpg_keys,
             {
               'katello/gpg_keys' => [:all, :index, :auto_complete_search],
               'katello/api/v2/gpg_keys' => [:index, :show]
             },
             :resource_type => 'Katello::GpgKey'
  permission :create_gpg_keys,
             {
               'katello/api/v2/gpg_keys' => [:create],
             },
             :resource_type => 'Katello::GpgKey'
  permission :edit_gpg_keys,
             {
               'katello/api/v2/gpg_keys' => [:update, :content],
             },
             :resource_type => 'Katello::GpgKey'
  permission :destroy_gpg_keys,
             {
               'katello/api/v2/gpg_keys' => [:destroy],
             },
             :resource_type => 'Katello::GpgKey'
end
