class MigrateBackgroundDownloadPolicyToMigrate < ActiveRecord::Migration[6.0]
  def change
    Katello::RootRepository.where(:download_policy => 'background').each do |root_repo|
      root_repo.update_column(:download_policy, ::Katello::RootRepository::DOWNLOAD_IMMEDIATE)
    end
  end
end
