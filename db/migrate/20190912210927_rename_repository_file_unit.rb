class RenameRepositoryFileUnit < ActiveRecord::Migration[5.2]
  def change
    original_name = 'index_katello_repository_files_on_file_id_and_repository_id'
    shorter_name = 'index_katello_repo_files_file_and_repo'

    if index_exists?(:katello_repository_files, [:file_id, :repository_id], :name => original_name)
      rename_index :katello_repository_files, original_name, shorter_name
    end
    rename_column :katello_repository_files, :file_id, :file_unit_id
    rename_table :katello_repository_files, :katello_repository_file_units
  end
end
