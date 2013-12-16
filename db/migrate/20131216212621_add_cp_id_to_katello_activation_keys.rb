class AddCpIdToKatelloActivationKeys < ActiveRecord::Migration
  def change
    add_column :katello_activation_keys, :cp_id, :string
    add_index :katello_activation_keys, :cp_id
  end
end
