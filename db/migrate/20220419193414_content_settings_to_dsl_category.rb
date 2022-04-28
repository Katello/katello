class ContentSettingsToDslCategory < ActiveRecord::Migration[6.0]
  def up
    Setting.where(category: 'Setting::Content').update_all(category: 'Setting')
  end
end
