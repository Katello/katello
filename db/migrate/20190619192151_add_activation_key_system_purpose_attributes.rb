class AddActivationKeySystemPurposeAttributes < ActiveRecord::Migration[5.2]
  def change
    create_table :katello_activation_key_purpose_addons do |t|
      t.references :purpose_addon, index: { name: :katello_activation_key_purpose_addons_paid }
      t.references :activation_key, index: { name: :katello_activation_key_purpose_addons_akid }
    end

    add_column :katello_activation_keys, :purpose_role, :string
    add_column :katello_activation_keys, :purpose_usage, :string

    add_foreign_key :katello_activation_key_purpose_addons, :katello_activation_keys, column: :activation_key_id, name: :katello_act_key_purpose_addon_act_key_id
    add_foreign_key :katello_activation_key_purpose_addons, :katello_purpose_addons, column: :purpose_addon_id, name: :katello_act_key_purpose_addon_purpose_addon_id
  end
end
