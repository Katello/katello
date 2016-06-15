class RenameKatelloSettings < ActiveRecord::Migration
  def up
    Setting.where(category: 'Setting::Katello').update_all(:category => 'Setting::Content')
  end

  def down
    Setting.where(category: 'Setting::Content').update_all(:category => 'Setting::Katello')
  end
end
