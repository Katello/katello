class AddSystemInfoKeyToOrganizations < ActiveRecord::Migration
  def self.up
    add_column :organizations, :system_info_keys, :text
  end

  def self.down
    remove_column :organizations, :system_info_keys
  end
end
