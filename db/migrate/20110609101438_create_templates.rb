class CreateTemplates < ActiveRecord::Migration
  def self.up
    create_table :system_templates do |t|
      t.integer :revision
      t.string :name
      t.string :description
      t.string :products_json
      t.string :packages_json
      t.string :errata_json
      t.string :host_group_name
      t.string :group_parameters_json
      t.references :environment, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :system_templates
  end
end
