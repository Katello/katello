class RemoveAllowMultipleContentViewsSetting < ActiveRecord::Migration[7.0]
  def up
    ::Setting.where(name: 'allow_multiple_content_views').delete_all
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
