class RemoveSystemGroupsEnvironments < ActiveRecord::Migration
  def self.up
    drop_table :environment_system_groups
  end

  def self.down
    create_table :environment_system_groups do |t|
      t.references :environment
      t.references :system_group
    end
  end
end
