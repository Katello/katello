class ExpandSyncTimeoutSettings < ActiveRecord::Migration[6.0]
  def up
    old_timeout_setting = Setting.find_by(name: 'sync_connect_timeout', category: 'Setting::Content')
    if old_timeout_setting && (old_timeout_setting&.value != old_timeout_setting&.default)
      Setting.find_by(name: 'sync_total_timeout')&.update(value: old_timeout_setting&.value)
      Setting.find_by(name: 'sync_sock_read_timeout')&.update(value: old_timeout_setting&.value)
    end
    Setting.where(name: 'sync_connect_timeout', category: 'Setting::Content').delete_all
  end

  def down
    timeout = Setting.find_by(name: 'sync_total_timeout', category: 'Setting::Content')&.value

    Setting.where(name: 'sync_total_timeout', category: 'Setting::Content').delete_all
    Setting.where(name: 'sync_connect_timeout_v2', category: 'Setting::Content').delete_all
    Setting.where(name: 'sync_sock_connect_timeout', category: 'Setting::Content').delete_all
    Setting.where(name: 'sync_sock_read_timeout', category: 'Setting::Content').delete_all

    Setting.create(Setting.set('sync_connect_timeout', N_("Timeout in seconds for downloads when syncing"),
      300, N_('Sync Connection Timeout')))
    Setting.find_by(name: 'sync_connect_timeout')&.update(value: timeout)
  end
end
