class AddSystemTemplateToSystem < ActiveRecord::Migration
  def self.up
    add_column :systems, :system_template_id, :integer
    add_index :systems, :system_template_id
  end

  def self.down
    remove_index :systems, :system_template_id
    remove_column :systems, :system_template_id
  end
end
