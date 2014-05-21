require 'katello/plugin.rb'

Foreman::Plugin.find(:katello).security_block :subscriptions do
  permission :view_subscriptions,
             {
              'katello/api/v2/subscriptions' => [:index, :show, :available, :manifest_history],
              'katello/dashboard' => [:subscriptions, :subscriptions_totals]
             },
             :resource_type => 'Organization'
  permission :attach_subscriptions,
             {
              'katello/api/v2/subscriptions' => [:create],
             },
             :resource_type => 'Organization'
  permission :unattach_subscriptions,
             {
              'katello/api/v2/subscriptions' => [:destroy],
             },
             :resource_type => 'Organization'
  permission :import_manifest,
             {
              'katello/products' => [:available_repositories, :toggle_repository],
              'katello/providers' => [:redhat_provider, :redhat_provider_tab],
              'katello/api/v2/subscriptions' => [:upload, :refresh_manifest]
             },
             :resource_type => 'Organization'
  permission :delete_manifest,
             {
              'katello/api/v2/subscriptions' => [:delete_manifest],
             },
             :resource_type => 'Organization'
end
