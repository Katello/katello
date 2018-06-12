class RemoveContentFieldsFromHost < ActiveRecord::Migration[5.1]
  def change
    # These fields were moved to the content facet
    remove_column :hosts, :content_view_id
    remove_column :hosts, :lifecycle_environment_id
  end
end
