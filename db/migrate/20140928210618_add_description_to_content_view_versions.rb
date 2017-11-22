class AddDescriptionToContentViewVersions < ActiveRecord::Migration[4.2]
  def change
    add_column :katello_content_view_versions, :description, :text
  end
end
