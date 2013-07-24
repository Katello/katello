class OrganizationAutoAttachSystems < ActiveRecord::Migration
  def up
    add_column :organizations, :owner_auto_attach_all_systems_task_id, :integer
  end

  def down
    remove_column :organizations, :owner_auto_attach_all_systems_task_id
  end
end
