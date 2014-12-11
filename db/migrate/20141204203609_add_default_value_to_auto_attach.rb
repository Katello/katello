class AddDefaultValueToAutoAttach < ActiveRecord::Migration
  def up
    change_column :katello_activation_keys, :auto_attach, :boolean, :default => true
  end

  def down
    change_column :katello_activation_keys, :auto_attach, :boolean, :default => nil
  end
end
