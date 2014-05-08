class AddHostIdToSystem < ActiveRecord::Migration
  def up
    add_column :katello_systems, :host_id, :integer
    add_index :katello_systems, :host_id
    add_foreign_key 'katello_systems', 'hosts', :name => 'katello_systems_host_id', :column => 'host_id'
  end

  def down
    remove_foreign_key 'katello_systems', :name => :katello_systems_host_id
    remove_index :katello_systems, :host_id
    remove_column :katello_systems, :host_id
  end
end
