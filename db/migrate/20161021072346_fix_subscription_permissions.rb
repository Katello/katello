class FixSubscriptionPermissions < ActiveRecord::Migration
  def up
    permission_names = [:view_subscriptions, :attach_subscriptions, :unattach_subscriptions, :import_manifest, :delete_manifest]
    Permission.where(:resource_type => 'Organization', :name => permission_names).update_all(resource_type: 'Katello::Subscription')
  end

  def down
    permission_names = [:view_subscriptions, :attach_subscriptions, :unattach_subscriptions, :import_manifest, :delete_manifest]
    Permission.where(:resource_type => 'Katello::Subscription', :name => permission_names).update_all(resource_type: 'Organization')
  end
end
