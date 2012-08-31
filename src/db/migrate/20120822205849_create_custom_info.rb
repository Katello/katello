class CreateCustomInfo < ActiveRecord::Migration
  def self.up
    create_table :custom_info do |t|
      t.string :keyname
      t.string :value
      t.integer :informable_id
      t.string :informable_type

      t.timestamps
    end

      add_index :custom_info, [:informable_id, :informable_type]
  end

  def self.down
    remove_index :custom_info
    drop_table :custom_info
  end
end
