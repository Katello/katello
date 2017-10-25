class RemoveUsePulpOauthSetting < ActiveRecord::Migration
  def up
    Setting.where(:name => 'use_pulp_oauth', :category => 'Setting::Content').delete_all
  end
end
