class AddHypervisorToSubscriptionFacets < ActiveRecord::Migration
  def change
    add_column :katello_subscription_facets, :hypervisor, :boolean, :default => false
    add_column :katello_subscription_facets, :hypervisor_host_id, :integer
  end
end
