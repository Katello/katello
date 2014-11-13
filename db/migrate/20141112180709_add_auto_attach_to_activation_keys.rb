class AddAutoAttachToActivationKeys < ActiveRecord::Migration
  def change
    add_column :katello_activation_keys, :auto_attach, :boolean
  end
end
