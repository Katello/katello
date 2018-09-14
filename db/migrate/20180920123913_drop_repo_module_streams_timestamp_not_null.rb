class DropRepoModuleStreamsTimestampNotNull < ActiveRecord::Migration[5.2]
  def change
    change_column :katello_repository_module_streams, :created_at, :datetime, :null => true
    change_column :katello_repository_module_streams, :updated_at, :datetime, :null => true
    change_column :katello_repository_module_streams, :repository_id, :integer, :null => true
  end
end
