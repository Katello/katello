class AddDescriptionToContentViewVersions < ActiveRecord::Migration
  def change
    add_column :katello_content_view_versions, :description, :text
  end
end
