class ChangeGpgKeysToContentCredentials < ActiveRecord::Migration[6.0]
  def change
    rename_table :katello_gpg_keys, :katello_content_credentials

    permissions = Permission.where(:resource_type => 'Katello::GpgKey')
    permissions.update_all(:resource_type => 'Katello::ContentCredential')
  end
end
