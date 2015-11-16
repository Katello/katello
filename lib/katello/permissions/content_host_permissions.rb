require 'katello/plugin.rb'

Foreman::Plugin.find(:katello).security_block :content_hosts do
  permission :view_content_hosts,
             {
               'katello/content_hosts'        => [:auto_complete_search],
               'katello/api/v2/systems' => [:index, :show, :errata, :package_profile, :product_content,
                                            :report, :pools, :releases, :available_host_collections, :events],
               'katello/api/v2/system_errata' => [:index, :show],
               'katello/api/v2/systems_bulk_actions' => [:applicable_errata],
               'katello/api/v2/host_collections' => [:systems]
             },
             :resource_type => 'Katello::System'
  permission :create_content_hosts,
             {
               'katello/api/v2/systems' => [:create],
               'katello/api/rhsm/candlepin_proxies' => [:consumer_create, :consumer_show]
             },
             :resource_type => 'Katello::System'
  permission :edit_content_hosts,
             {
               'katello/api/v2/systems' => [:update, :refresh_subscriptions, :content_override],
               'katello/api/v2/host_packages' => [:install, :upgrade, :upgrade_all, :remove],
               'katello/api/v2/system_errata' => [:apply],
               'katello/api/v2/systems_bulk_actions' => [:install_content, :update_content,
                                                         :remove_content, :environment_content_view,
                                                         :bulk_add_host_collections, :bulk_remove_host_collections],
               'katello/api/rhsm/candlepin_proxies' => [:upload_package_profile, :regenerate_identity_certificates,
                                                        :hypervisors_update]
             },
             :resource_type => 'Katello::System'
  permission :destroy_content_hosts,
             {
               'katello/api/v2/systems' => [:destroy],
               'katello/api/v2/systems_bulk_actions' => [:destroy_systems]
             },
             :resource_type => 'Katello::System'
end
