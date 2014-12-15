class ContentViewVersionAddMinor < ActiveRecord::Migration
  def up
    add_column :katello_content_view_versions, :minor, :integer, :null => false, :default => 0
    rename_column :katello_content_view_versions, :version, :major
  end

  def down
    rename_column :katello_content_view_versions, :major, :version
    remove_column :katello_content_view_versions, :minor
  end
end
