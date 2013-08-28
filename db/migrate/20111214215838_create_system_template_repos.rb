class CreateSystemTemplateRepos < ActiveRecord::Migration
  def self.up
    create_table :system_template_repositories do |t|
      t.integer :system_template_id
      t.integer :repository_id
    end
  end

  def self.down
    drop_table :system_template_repositories
  end
end
