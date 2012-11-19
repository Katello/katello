class CreateContentViewDefinitionRepositories < ActiveRecord::Migration
  def self.up
    create_table :content_view_definition_repositories do |t|
      t.references :content_view_definition
      t.references :repository

      t.timestamps
    end
    add_index :content_view_definition_repositories, [:content_view_definition_id,
      :repository_id], :name => :cvd_repo_index
    remove_column :repositories, :content_view_definition_id
  end

  def self.down
    drop_table :content_view_definition_repositories
    add_column :repositories, :content_view_definition_id, :integer
  end
end
