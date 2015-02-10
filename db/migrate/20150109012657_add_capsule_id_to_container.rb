class AddCapsuleIdToContainer < ActiveRecord::Migration
  def up
    add_column :containers, :capsule_id, :integer
    add_foreign_key :containers, :smart_proxies, :column => "capsule_id"

    add_column :docker_container_wizard_states_images, :capsule_id, :integer
  end

  def down
    remove_column :containers, :capsule_id
    remove_column :docker_container_wizard_states_images, :capsule_id
  end
end
