class AddDockerTagsWhitelistToRepository < ActiveRecord::Migration[5.1]
  def up
    add_column :katello_repositories, :docker_tags_whitelist, :text
  end

  def down
    remove_column :katello_repositories, :docker_tags_whitelist
  end
end
