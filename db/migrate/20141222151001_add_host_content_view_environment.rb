class AddHostContentViewEnvironment < ActiveRecord::Migration
  def up
    add_column :hosts, :content_view_id, :integer, :null => true
    add_column :hosts, :lifecycle_environment_id, :integer, :null => true

    add_column :hostgroups, :content_view_id, :integer, :null => true
    add_column :hostgroups, :lifecycle_environment_id, :integer, :null => true

    [Hostgroup, Host::Managed].each do |model|
      model.find_each do |host|
        lifecycle_environment =  host.environment.try(:lifecycle_environment)
        content_view = host.environment.try(:content_view)
        if lifecycle_environment && content_view
          host.update_column(:content_view_id, content_view.id)
          host.update_column(:lifecycle_environment_id, lifecycle_environment.id)
        end
      end
    end
  end

  def down
    remove_column :hosts, :content_view_id
    remove_column :hosts, :lifecycle_environment_id

    remove_column :hostgroups, :content_view_id
    remove_column :hostgroups, :lifecycle_environment_id
  end
end
