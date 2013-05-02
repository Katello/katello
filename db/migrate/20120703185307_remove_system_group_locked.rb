class RemoveSystemGroupLocked < ActiveRecord::Migration
  def self.up
   remove_column :system_groups, :locked
  end

  def self.down
    add_column :system_groups, :locked, :boolean, :default=>false, :null=>false
  end
end
