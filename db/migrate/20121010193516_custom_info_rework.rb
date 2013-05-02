class CustomInfoRework < ActiveRecord::Migration
  def self.up
    remove_index :custom_info, :name => "index_custom_info_on_inf_type_and_inf_id_and_kn_and_v"
    add_index :custom_info, [:informable_type, :informable_id, :keyname], :name => "index_custom_info_on_type_id_keyname"
  end

  def self.down
    remove_index :custom_info, :name => "index_custom_info_on_type_id_keyname"
    add_index :custom_info, [:informable_type, :informable_id, :keyname, :value], :unique => true, :name => "index_custom_info_on_inf_type_and_inf_id_and_kn_and_v"
  end
end
