class RemoveAutoAttachFromActivationKeys < ActiveRecord::Migration[6.1]
  def change
    remove_column :katello_activation_keys, :auto_attach, :boolean
  end
end
