class RenameIndexRepositoryErrata < ActiveRecord::Migration
  def change
    original_name = 'index_katello_repository_errata_on_erratum_id_and_repository_id'
    shorter_name = 'index_katello_repository_errata_on_erratum_id_and_repo_id'

    if index_exists?(:katello_repository_errata, [:erratum_id, :repository_id], :name => original_name)
      rename_index :katello_repository_errata, original_name, shorter_name
    end
  end
end
