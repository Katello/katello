class UpdateDisconnectedSettings < ActiveRecord::Migration[6.0]
  class FakeSetting < Katello::Model
    self.table_name = 'settings'
  end

  def up
    setting_disconnected = FakeSetting.find_by(name: 'content_disconnected')
    setting = Setting.find_by(name: 'subscription_connection_enabled')

    setting&.update!(
      value: !setting_disconnected&.value
    )
    FakeSetting.where(:name => 'content_disconnected').delete_all
  end

  def down
    remove_column :katello_cdn_configurations, :airgapped
    setting_disconnected = Setting.find_by(name: 'subscription_connection_enabled')
    FakeSetting.set('content_disconnected', N_("A server operating in disconnected mode does not communicate with the Red Hat CDN."),
                    !setting_disconnected.value, N_('Disconnected mode'))

    Setting.where(:name => 'subscription_connection_enabled').delete_all
  end
end
