class AddRegistryNamePatternToEnvironment < ActiveRecord::Migration[5.1]
  def up
    add_column(:katello_environments, :registry_name_pattern, :string, limit: 255, null: true)
    change_column(:katello_repositories, :container_repository_name, :string, unique: true)
  end

  def down
    remove_column(:katello_environments, :registry_name_pattern)
    change_column(:katello_repositories, :container_repository_name, :string, unique: false)
  end
end
