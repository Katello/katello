class RemovePulpExportDestinationSetting < ActiveRecord::Migration[6.1]
  def up
    Setting.where(name: 'pulp_export_destination').delete_all
  end

  def down
    # no action, seeding on app start should create the object with the default value
  end
end
