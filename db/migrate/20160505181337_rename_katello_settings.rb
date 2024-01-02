class RenameKatelloSettings < ActiveRecord::Migration[4.2]
  def up
    Setting.where(category: 'Setting::Katello').update_all(:category => 'Setting::Content') if column_exists?(:settings, :category)
  end

  def down
    Setting.where(category: 'Setting::Content').update_all(:category => 'Setting::Katello') if column_exists?(:settings, :category)
  end
end
