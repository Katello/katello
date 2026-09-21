class UseBigIntForHostInstalledPackagesId < ActiveRecord::Migration[7.0]
  def up
    execute "ALTER SEQUENCE #{default_sequence_name(:katello_host_installed_packages)} AS bigint"
    change_column :katello_host_installed_packages, :id, :bigint
  end

  def down
    # Imported associations may already have IDs outside the integer range.
    fail ActiveRecord::IrreversibleMigration
  end
end
