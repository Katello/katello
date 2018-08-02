class AddIndexToContentViewVersion < ActiveRecord::Migration[5.1]
  def change
    add_index :katello_content_view_versions, [:content_view_id, :major, :minor], :unique => true, :name => 'version_index'
  end
end
