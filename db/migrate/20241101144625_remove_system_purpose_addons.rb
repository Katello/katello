class RemoveSystemPurposeAddons < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :katello_subscription_facet_purpose_addons, :katello_purpose_addons, column: :purpose_addon_id

    drop_table :katello_activation_key_purpose_addons
    drop_table :katello_purpose_addons
    drop_table :katello_subscription_facet_purpose_addons
  end
end
