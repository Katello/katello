class CreateDockerTables < ActiveRecord::Migration
  def up
    create_table :katello_docker_images do |t|
      t.string :image_id
      t.integer :size
      t.string :uuid
      t.timestamps
    end
    create_table :katello_docker_tags do |t|
      t.string :name
      t.integer :docker_image_id
      t.integer :repository_id
      t.timestamps
    end
    add_index :katello_docker_images, :uuid, :unique => true
    add_foreign_key :katello_docker_tags, :katello_docker_images, :column => "docker_image_id"
    add_foreign_key :katello_docker_tags, :katello_repositories, :column => "repository_id"

    add_index :katello_docker_tags, [:docker_image_id, :repository_id, :name],
              :name => :docker_tag_docker_image_repo_name, :unique => true

    add_foreign_key :katello_repository_docker_images, :katello_docker_images,
                    :column => :docker_image_id
  end

  def down
    remove_foreign_key :katello_repository_docker_images, :name => "katello_repository_docker_images_docker_image_id_fk"
    remove_foreign_key :katello_docker_tags, :name => "katello_docker_tags_docker_image_id_fk"
    remove_foreign_key :katello_docker_tags, :name => "katello_docker_tags_repository_id_fk"
    drop_table :katello_docker_images
    drop_table :katello_docker_tags
  end
end
