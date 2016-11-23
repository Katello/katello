require 'katello/plugin.rb'

Foreman::Plugin.find(:katello).security_block :subscriptions do
  permission :view_subscriptions,
             {
               'katello/api/v2/subscriptions' => [:index, :show, :available, :manifest_history, :auto_complete_search],
               'katello/api/v2/repository_sets' => [:index, :show, :available_repositories]
             },
             :resource_type => 'Katello::Subscription'
  permission :attach_subscriptions,
             {
               'katello/api/v2/subscriptions' => [:create]
             },
             :resource_type => 'Katello::Subscription'
  permission :unattach_subscriptions,
             {
               'katello/api/v2/subscriptions' => [:destroy]
             },
             :resource_type => 'Katello::Subscription'
  permission :import_manifest,
             {
               'katello/products' => [:available_repositories, :toggle_repository],
               'katello/providers' => [:redhat_provider, :redhat_provider_tab],
               'katello/api/v2/subscriptions' => [:upload, :refresh_manifest],
               'katello/api/v2/repository_sets' => [:enable, :disable]
             },
             :resource_type => 'Katello::Subscription'
  permission :delete_manifest,
             {
               'katello/api/v2/subscriptions' => [:delete_manifest]
             },
             :resource_type => 'Katello::Subscription'
end
