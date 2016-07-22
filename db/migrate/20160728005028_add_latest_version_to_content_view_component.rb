class AddLatestVersionToContentViewComponent < ActiveRecord::Migration
  def change
    rename_column :katello_content_view_components, :content_view_id, :composite_content_view_id
    change_column_null :katello_content_view_components, :content_view_version_id, :integer, true
    add_column :katello_content_view_components, :content_view_id, :integer, :null => true
    add_column :katello_content_view_components, :latest, :boolean, :default => false, :null => false
    add_foreign_key :katello_content_view_components, :katello_content_views, :column => :content_view_id
  end
end
