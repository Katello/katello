class CreateSystemTemplatePgCategories < ActiveRecord::Migration
  def self.up
    create_table :system_template_pg_categories do |t|
      t.integer :system_template_id
      t.string :repo_id
      t.string :pg_category_id
    end
    add_index :system_template_pg_categories, :system_template_id
  end

  def self.down
    drop_table :system_template_pg_categories
  end
end
