class RemoveKatelloRepositoryIdFromDockerImages < ActiveRecord::Migration
  def up
    remove_column :docker_images, :katello_repository_id
  end

  def down
    add_column :docker_images, :katello_repository_id, :integer
  end
end
