class AddDockerRepoName < ActiveRecord::Migration
  def up
    add_column :katello_repositories, :container_repository_name, :string

    Katello::Repository.docker_type.find_each do |repo|
      repo.set_container_repository_name
      repo.save!
    end
  end

  def down
    remove_column :katello_repositories, :container_repository_name
  end
end
