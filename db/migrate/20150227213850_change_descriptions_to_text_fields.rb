class ChangeDescriptionsToTextFields < ActiveRecord::Migration
  def change
    change_column :katello_content_view_filters, :description, :text
    change_column :katello_content_views, :description, :text
  end
end
