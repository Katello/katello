class AddSystemGroupsEnvironment < ActiveRecord::Migration
  def self.up
    create_table :environment_system_groups do |t|
      t.references :environment
      t.references :system_group
    end
  end

  def self.down
    drop_table :environment_system_groups
  end
end
