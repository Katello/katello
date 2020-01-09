class DropHostUpdateLockSetting < ActiveRecord::Migration[5.2]
  def up
    Setting.where(name: 'host_update_lock').delete_all
  end
end
