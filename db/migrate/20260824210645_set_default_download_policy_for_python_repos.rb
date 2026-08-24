class SetDefaultDownloadPolicyForPythonRepos < ActiveRecord::Migration[7.0]
  def up
    Katello::RootRepository.where(content_type: 'python')
      .where(download_policy: [nil, ''])
      .update_all(download_policy: 'on_demand')
  end

  def down
    Katello::RootRepository.where(content_type: 'python').update_all(download_policy: nil)
  end
end
