class AddDownloadPolicyToKatelloRepositories < ActiveRecord::Migration
  class DownloadPolicyRepository < ActiveRecord::Base
    self.table_name = "katello_repositories"
  end
  def change
    add_column :katello_repositories, :download_policy, :string
    DownloadPolicyRepository.where(content_type: 'yum').update_all(download_policy: 'immediate')
  end
end
