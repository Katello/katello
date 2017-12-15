class AddAutoPublishToContentViews < ActiveRecord::Migration[5.1]
  def change
    add_column :katello_content_views, :auto_publish, :boolean, :null => false, :default => false
  end
end
