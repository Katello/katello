class AddAutoAttachToActivationKeys < ActiveRecord::Migration[4.2]
  def change
    add_column :katello_activation_keys, :auto_attach, :boolean
  end
end
