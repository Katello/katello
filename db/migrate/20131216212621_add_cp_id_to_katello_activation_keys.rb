class AddCpIdToKatelloActivationKeys < ActiveRecord::Migration
  def change
    add_column :katello_activation_keys, :cp_id, :string, :limit => 255
    add_column :katello_activation_keys, :label, :string, :limit => 255
    add_index :katello_activation_keys, :cp_id
    add_index :katello_activation_keys, :label, :name => "index_activation_keys_on_label", :unique => true
  end
end
