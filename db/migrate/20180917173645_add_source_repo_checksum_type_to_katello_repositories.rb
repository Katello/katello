class AddSourceRepoChecksumTypeToKatelloRepositories < ActiveRecord::Migration[5.1]
  def change
    add_column :katello_repositories, :source_repo_checksum_type, :string
  end
end
