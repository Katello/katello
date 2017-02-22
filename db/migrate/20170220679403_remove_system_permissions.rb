class RemoveSystemPermissions < ActiveRecord::Migration
  def up
    system_permissions = Permission.where(:resource_type => 'Katello::System')
    system_permissions.flat_map(&:filters).map(&:destroy!)
    system_permissions.map(&:destroy!)
  end
end
