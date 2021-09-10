class MoveBackgroundSettingsToImmediate < ActiveRecord::Migration[6.0]
  def up
    SmartProxy.where(id: (SmartProxy.with_content - [SmartProxy.pulp_primary]).pluck(:id)).
      where(download_policy: 'background').update(download_policy: 'immediate')

    setting = ::Setting.find_by(name: 'default_download_policy')
    if setting&.value == 'background'
      setting.update(value: ::Katello::RootRepository::DOWNLOAD_IMMEDIATE)
    end

    setting = ::Setting.find_by(name: 'default_redhat_download_policy')
    if setting&.value == 'background'
      setting.update(value: ::Katello::RootRepository::DOWNLOAD_IMMEDIATE)
    end

    setting = ::Setting.find_by(name: 'default_proxy_download_policy')
    if setting&.value == 'background'
      setting.update(value: ::Katello::RootRepository::DOWNLOAD_IMMEDIATE)
    end
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
