class CleanUpForcePostSyncActionSetting < ActiveRecord::Migration[5.1]
  def change
    Setting.where(:name => 'force_post_sync_actions', :category => 'Setting::Content').delete_all
  end
end
