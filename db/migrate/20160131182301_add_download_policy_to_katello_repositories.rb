class AddDownloadPolicyToKatelloRepositories < ActiveRecord::Migration
  def change
    add_column :katello_repositories, :download_policy, :string
  end
end
