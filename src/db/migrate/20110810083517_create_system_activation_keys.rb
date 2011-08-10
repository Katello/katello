class CreateSystemActivationKeys < ActiveRecord::Migration
  def self.up
    create_table :system_activation_keys do |t|
      t.belongs_to :system, :activation_key
    end
    add_index :system_activation_keys, :system_id
    add_index :system_activation_keys, :activation_key_id
  end

  def self.down
    drop_table :system_activation_keys
  end
end
