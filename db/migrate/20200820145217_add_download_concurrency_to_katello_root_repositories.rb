class AddDownloadConcurrencyToKatelloRootRepositories < ActiveRecord::Migration[6.0]
  def change
    add_column :katello_root_repositories, :download_concurrency, :integer
  end
end
