class RenameIndexRepositoryPuppetModule < ActiveRecord::Migration
  def change
    original_name = 'index_katello_repository_puppet_module_on_module_id_and_repo_id'
    shorter_name = 'index_katello_repo_puppet_module_on_module_id_and_repo_id'

    if index_exists?(:katello_repository_puppet_module, [:module_id, :repo_id], :name => original_name)
      rename_index :katello_repository_puppet_modules, original_name, shorter_name
    end
  end
end
