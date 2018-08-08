class AddDockerRepoName < ActiveRecord::Migration[4.2]
  class FakeRepository < ApplicationRecord
    self.table_name = 'katello_repositories'
    scope :docker_type, -> { where(:content_type => 'docker') }

    def set_container_repository_name
      self.container_repository_name = Katello::Repository.safe_render_container_name(self)
    end
  end

  def up
    add_column :katello_repositories, :container_repository_name, :string

    FakeRepository.docker_type.find_each do |repo|
      repo.set_container_repository_name
      repo.save!
    end
  end

  def down
    remove_column :katello_repositories, :container_repository_name
  end
end
