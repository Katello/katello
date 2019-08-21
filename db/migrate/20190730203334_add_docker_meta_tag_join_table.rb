class AddDockerMetaTagJoinTable < ActiveRecord::Migration[5.2]
  def up
    create_table :katello_repository_docker_meta_tags do |t|
      t.integer :docker_meta_tag_id, null: false
      t.integer :repository_id
      t.timestamps null: true
    end

    ::Katello::Repository.all.each do |repository|
      repository.docker_meta_tags = ::Katello::DockerMetaTag.where(:repository_id => repository.id)
    end

    remove_column :katello_docker_meta_tags, :repository_id
  end

  def down
    add_column :katello_docker_meta_tags, :repository_id, :integer

    ::Katello::DockerMetaTag.all.each do |meta_tag|
      meta_tag.update_attributes(repository_id: meta_tag.repositories.first.id)
    end

    drop_table :katello_repository_docker_meta_tags
  end
end
