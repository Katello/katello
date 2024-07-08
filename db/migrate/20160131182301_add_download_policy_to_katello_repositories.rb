class AddDownloadPolicyToKatelloRepositories < ActiveRecord::Migration[4.2]
  class DownloadPolicyRepository < ApplicationRecord
    self.table_name = "katello_repositories"
  end

  def change
    add_column :katello_repositories, :download_policy, :string, :limit => 255
    DownloadPolicyRepository.where(content_type: 'yum').update_all(download_policy: 'immediate')
  end
end
