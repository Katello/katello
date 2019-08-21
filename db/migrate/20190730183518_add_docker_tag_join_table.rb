class AddDockerTagJoinTable < ActiveRecord::Migration[5.2]
  def up
    create_table :katello_repository_docker_tags do |t|
      t.integer :docker_tag_id, null: false
      t.integer :repository_id
      t.timestamps null: true
    end

    ::Katello::Repository.all.each do |repository|
      repository.docker_tags = ::Katello::DockerTag.where(:repository_id => repository.id)
    end

    remove_column :katello_docker_tags, :repository_id
  end

  def down
    add_column :katello_docker_tags, :repository_id, :integer

    ::Katello::DockerTag.all.each do |tag|
      tag.update_attributes(repository_id: tag.repositories.first.id)
    end

    drop_table :katello_repository_docker_tags
  end
end
