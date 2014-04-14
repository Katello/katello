class UpdateContentViewDescriptionType < ActiveRecord::Migration
  def up
    change_column :katello_content_views, :description, :string, :limit => 255
  end

  def down
    change_column :katello_content_views, :description, :text
  end
end
