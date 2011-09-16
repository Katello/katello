class CreateTemplates < ActiveRecord::Migration
  def self.up
    create_table :system_templates do |t|
      t.integer :revision
      t.string :name
      t.string :description
      t.string :parameters_json
      t.integer :parent_id
      t.references :environment, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :system_templates
  end
end
