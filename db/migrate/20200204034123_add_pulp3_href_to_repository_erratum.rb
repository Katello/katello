class AddPulp3HrefToRepositoryErratum < ActiveRecord::Migration[5.2]
  def change
    add_column :katello_repository_errata, :erratum_pulp3_href, :string
    add_index :katello_repository_errata, :erratum_pulp3_href
  end
end
