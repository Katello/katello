class CreateSystemTemplatePackGroups < ActiveRecord::Migration
  def self.up
    create_table :system_template_pack_groups do |t|
      t.integer :system_template_id
      t.string :name, :null => false
    end
    add_index :system_template_pack_groups, :system_template_id
  end

  def self.down
    drop_table :system_template_pack_groups
  end
end
