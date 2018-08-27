class RemoveJoinTableForRoleAndUsage < ActiveRecord::Migration[5.1]
  def change
    remove_foreign_key :katello_subscription_facet_purpose_roles, :katello_subscription_facets
    remove_foreign_key :katello_subscription_facet_purpose_roles, :katello_purpose_roles
    remove_foreign_key :katello_subscription_facet_purpose_usages, :katello_subscription_facets
    remove_foreign_key :katello_subscription_facet_purpose_usages, :katello_purpose_usages

    drop_table :katello_subscription_facet_purpose_roles
    drop_table :katello_subscription_facet_purpose_usages
    drop_table :katello_subscription_facet_purpose_addons

    drop_table :katello_purpose_roles
    drop_table :katello_purpose_usages
    drop_table :katello_purpose_addons

    add_column :katello_subscription_facets, :purpose_usage, :text
    add_column :katello_subscription_facets, :purpose_role, :text
    add_column :katello_subscription_facets, :purpose_addons, :text
  end
end
