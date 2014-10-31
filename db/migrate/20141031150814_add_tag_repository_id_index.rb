class AddTagRepositoryIdIndex < ActiveRecord::Migration
  def up
    add_index :docker_tags, [:tag, :katello_repository_id],
              :name => :katello_docker_tag_repository_id, :unique => true
  end

  def down
    remove_index :docker_tags, :name => :katello_docker_tag_repository_id
  end
end
