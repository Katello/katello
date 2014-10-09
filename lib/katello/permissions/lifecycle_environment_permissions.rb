require 'katello/plugin.rb'

Foreman::Plugin.find(:katello).security_block :lifecycle_environments do
  permission :view_lifecycle_environments,
             {
               'katello/api/v2/environments' => [:index, :show, :paths, :repositories],
               'katello/api/rhsm/candlepin_proxies' => [:rhsm_index],
               'katello/environments' => [:auto_complete_search]
             },
             :resource_type => 'Katello::KTEnvironment'
  permission :create_lifecycle_environments,
             {
               'katello/api/v2/environments' => [:create],
             },
             :resource_type => 'Katello::KTEnvironment'
  permission :edit_lifecycle_environments,
             {
               'katello/api/v2/environments' => [:update],
             },
             :resource_type => 'Katello::KTEnvironment'
  permission :destroy_lifecycle_environments,
             {
               'katello/api/v2/environments' => [:destroy],
             },
             :resource_type => 'Katello::KTEnvironment'

  permission :promote_or_remove_content_views_to_environments,
             {},
             :resource_type => 'Katello::KTEnvironment'
end
