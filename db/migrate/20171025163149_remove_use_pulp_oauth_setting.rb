class RemoveUsePulpOauthSetting < ActiveRecord::Migration[4.2]
  def up
    Setting.where(:name => 'use_pulp_oauth').delete_all
  end
end
