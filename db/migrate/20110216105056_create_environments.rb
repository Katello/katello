class CreateEnvironments < ActiveRecord::Migration
  def self.up
    create_table :environments do |t|
      t.string :name, :null => false
      t.string :description
      t.boolean :locker, :null => false, :default => false
      t.integer :organization_id, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :environments
  end
end
