class SystemTemplatePackages < ActiveRecord::Migration
  def self.up
    create_table :system_template_packages do |t|
      t.integer :system_template_id, :null => false
      t.string :package_name, :null => false
      t.string :version, :null => true
      t.string :release, :null => true
      t.string :epoch, :null => true
      t.string :arch, :null => true
    end
    add_index :system_template_packages, :system_template_id
  end

  def self.down
    drop_table :system_template_packages
  end
end
