class AddDescriptionToContentViewFilterRules < ActiveRecord::Migration[4.2]
  def up
    add_column :katello_content_view_filters, :description, :string, :limit => 255
  end

  def down
    remove_column :katello_content_view_filters, :description
  end
end
