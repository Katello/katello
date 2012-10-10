class CreateCustomInfo < ActiveRecord::Migration
  def self.up
    create_table :custom_info do |t|
      t.string :keyname
      t.string :value
      t.integer :informable_id
      t.string :informable_type

      t.timestamps
    end

      add_index :custom_info, [:informable_type, :informable_id, :keyname, :value], :unique => true, :name => "index_custom_info_on_inf_type_and_inf_id_and_kn_and_v"
  end

  def self.down
    remove_index :custom_info, :name => "index_custom_info_on_inf_type_and_inf_id_and_kn_and_v"
    drop_table :custom_info
  end
end
