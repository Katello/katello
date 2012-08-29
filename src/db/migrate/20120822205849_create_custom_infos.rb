class CreateCustomInfos < ActiveRecord::Migration
  def self.up
    create_table :custom_infos do |t|
      t.string :keyname
      t.string :value
      t.integer :informable_id
      t.string :informable_type

      t.timestamps
    end
  end

  def self.down
    drop_table :custom_infos
  end
end
