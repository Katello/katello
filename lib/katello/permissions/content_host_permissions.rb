require 'katello/plugin.rb'

Foreman::Plugin.find(:katello).security_block :content_hosts do
  permission :view_content_hosts,
             {
               'katello/api/v2/systems' => [:index, :show, :errata, :package_profile,
                                            :report, :pools, :releases, :tasks,
                                            :available_host_collections],
               'katello/api/v2/system_errata' => [:show],
               'katello/api/v2/systems_bulk_actions' => [:applicable_errata],
               'katello/api/v2/host_collections' => [:systems]
             },
             :resource_type => 'Katello::System'

  permission :create_content_hosts,
             {
               'katello/api/v2/systems' => [:create],
               'katello/api/v1/candlepin_proxies' => [:consumer_create],
             },
             :resource_type => 'Katello::System'

  permission :edit_content_hosts,
             {
               'katello/api/v2/systems' => [:update, :refresh_subscriptions],
               'katello/api/v2/system_packages' => [:install, :upgrade, :upgrade_all, :remove],
               'katello/api/v2/system_errata' => [:apply],
               'katello/api/v2/systems_bulk_actions' => [:install_content, :update_content,
                                                         :remove_content, :environment_content_view,
                                                         :bulk_add_host_collections, :bulk_remove_host_collections],
             },
             :resource_type => 'Katello::System'

  permission :destroy_content_hosts,
             {
               'katello/api/v2/systems' => [:destroy],
               'katello/api/v2/systems_bulk_actions' => [:destroy_systems]
             },
             :resource_type => 'Katello::System'
end
