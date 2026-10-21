class ChangeManageSubscriptionAllocationsPermissionResourceType < ActiveRecord::Migration[7.0]
  PERMISSION_NAME = 'manage_subscription_allocations'.freeze

  def up
    Permission.where(name: PERMISSION_NAME, resource_type: 'Katello::Subscription').update_all(resource_type: 'Organization')
  end

  def down
    Permission.where(name: PERMISSION_NAME, resource_type: 'Organization').update_all(resource_type: 'Katello::Subscription')
  end
end
