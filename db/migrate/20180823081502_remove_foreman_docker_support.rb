class RemoveForemanDockerSupport < ActiveRecord::Migration[5.1]
  def change
    if table_exists?(:docker_images)
      remove_column :docker_images, :katello_uuid
      remove_column :docker_images, :katello_repository_id
    end
    if table_exists?(:docker_tags)
      remove_index :docker_tags, :name => :katello_docker_tag_repository_id
      remove_column :docker_tags, :katello_repository_id
    end
    if table_exists?(:docker_container_wizard_states_images)
      if column_exists?(:docker_container_wizard_states_images, :capsule_id)
        remove_column :docker_container_wizard_states_images, :capsule_id
      end
    end
    if table_exists?(:containers)
      remove_column :containers, :capsule_id
    end
  end
end
