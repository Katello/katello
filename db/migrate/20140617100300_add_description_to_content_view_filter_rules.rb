class AddDescriptionToContentViewFilterRules < ActiveRecord::Migration
  def up
    add_column :katello_content_view_filters, :description, :string, :limit => 255
  end

  def down
    remove_column :katello_content_view_filters, :description
  end
end
