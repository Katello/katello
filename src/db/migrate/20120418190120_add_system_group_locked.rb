class AddSystemGroupLocked < ActiveRecord::Migration
  def self.up
    add_column :system_groups, :locked, :boolean, :default=>false, :null=>false
  end

  def self.down
   remove_column :system_groups, :locked
  end
end
