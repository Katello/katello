class AddOsVersionsToKatelloRootRepositories < ActiveRecord::Migration[6.0]
  def change
    add_column :katello_root_repositories, :os_versions, :text
  end
end
