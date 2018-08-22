class AddSystemPurposeAttrs < ActiveRecord::Migration[5.1]
  def change
    create_table :katello_purpose_addons do |t|
      t.string :name, null: false
    end

    create_table :katello_purpose_roles do |t|
      t.string :name, null: false
    end

    create_table :katello_purpose_usages do |t|
      t.string :name, null: false
    end

    create_table :katello_subscription_facet_purpose_addons do |t|
      t.references :purpose_addon, index: { name: :katello_sub_facet_purpose_addons_paid }
      t.references :subscription_facet, index: { name: :katello_sub_facet_purpose_addons_sfid }
    end

    create_table :katello_subscription_facet_purpose_roles do |t|
      t.references :purpose_role, index: { name: :katello_sub_facet_purpose_roles_prid }
      t.references :subscription_facet, index: { name: :katello_sub_facet_purpose_roles_sfid }
    end

    create_table :katello_subscription_facet_purpose_usages do |t|
      t.references :purpose_usage, index: { name: :katello_sub_facet_purpose_usages_puid }
      t.references :subscription_facet, index: { name: :katello_sub_facet_purpose_usages_sfid }
    end

    add_foreign_key :katello_subscription_facet_purpose_addons, :katello_subscription_facets, column: :subscription_facet_id, name: :katello_sub_facet_purpose_addon_facet_id
    add_foreign_key :katello_subscription_facet_purpose_addons, :katello_purpose_addons, column: :purpose_addon_id, name: :katello_sub_facet_purpose_addon_purpose_addon_id

    add_foreign_key :katello_subscription_facet_purpose_roles, :katello_subscription_facets, column: :subscription_facet_id, name: :katello_sub_facet_purpose_role_facet_id
    add_foreign_key :katello_subscription_facet_purpose_roles, :katello_purpose_roles, column: :purpose_role_id, name: :katello_sub_facet_purpose_role_purpose_role_id

    add_foreign_key :katello_subscription_facet_purpose_usages, :katello_subscription_facets, column: :subscription_facet_id, name: :katello_sub_facet_purpose_usage_facet_id
    add_foreign_key :katello_subscription_facet_purpose_usages, :katello_purpose_usages, column: :purpose_usage_id, name: :katello_sub_facet_purpose_usage_purpose_usage_id
  end
end
