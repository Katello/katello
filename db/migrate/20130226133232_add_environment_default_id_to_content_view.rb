class AddEnvironmentDefaultIdToContentView < ActiveRecord::Migration
  def self.up
    add_column :content_views, :environment_default_id, :integer
    remove_column :environments, :default_content_view_id
    add_index :content_views, [:environment_default_id]
  end

  def self.down
    remove_column :content_views, :environment_default_id, :integer
    add_column :environments, :default_content_view_id, :integer
    remove_index :content_views, [:environment_default_id]
  end
end
