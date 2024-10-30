class AddPurposeAddons < ActiveRecord::Migration[5.2]
  def change
    create_table :katello_purpose_addons do |t|
      t.string :name, null: false
    end

    create_table :katello_subscription_facet_purpose_addons do |t|
      t.references :purpose_addon, index: { name: :katello_sub_facet_purpose_addons_paid }
      t.references :subscription_facet, index: { name: :katello_sub_facet_purpose_addons_sfid }
    end

    add_foreign_key :katello_subscription_facet_purpose_addons, :katello_subscription_facets, column: :subscription_facet_id, name: :katello_sub_facet_purpose_addon_facet_id
    add_foreign_key :katello_subscription_facet_purpose_addons, :katello_purpose_addons, column: :purpose_addon_id, name: :katello_sub_facet_purpose_addon_purpose_addon_id

    remove_column :katello_subscription_facets, :purpose_addons, :text
  end
end
