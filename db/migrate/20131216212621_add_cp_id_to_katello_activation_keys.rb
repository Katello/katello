class AddCpIdToKatelloActivationKeys < ActiveRecord::Migration
  def change
    add_column :katello_activation_keys, :cp_id, :string
    add_column :katello_activation_keys, :label, :string
    add_index :katello_activation_keys, :cp_id
    add_index :katello_activation_keys, :label, :name => "index_activation_keys_on_label", :unique => true
  end
end
