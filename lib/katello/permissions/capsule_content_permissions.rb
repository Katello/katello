require 'katello/plugin.rb'

Foreman::Plugin.find(:katello).security_block :capsule_content do
  permission :manage_capsule_content,
             {
               'katello/api/v2/capsule_content' => [:lifecycle_environments, :available_lifecycle_environments, :add_lifecycle_environment, :remove_lifecycle_environment,
                                                    :sync, :sync_status, :cancel_sync],
               'katello/api/v2/capsules'        => [:index, :show]
             },
             :resource_type => 'SmartProxy'

  permission :view_capsule_content,
            {
              'smart_proxies' => [:pulp_storage, :pulp_status, :show_with_content]
            },
            :resource_type => "SmartProxy"
end
