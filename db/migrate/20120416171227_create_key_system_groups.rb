class CreateKeySystemGroups < ActiveRecord::Migration
  def self.up
    create_table :key_system_groups do |t|
      t.references :activation_key
      t.references :system_group
    end
  end

  def self.down
    drop_table :key_system_groups
  end
end
