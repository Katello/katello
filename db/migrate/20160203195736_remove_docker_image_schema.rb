class RemoveDockerImageSchema < ActiveRecord::Migration
  def up
    remove_column :katello_docker_tags, :docker_image_id
    drop_table :katello_repository_docker_images
    drop_table :katello_docker_images
  end

  def down
    add_column :katello_docker_tags, :docker_image_id, :integer

    create_table :katello_docker_images do |t|
      t.string :image_id
      t.integer :size
      t.string :uuid
      t.timestamps
    end

    create_table :katello_repository_docker_images do |t|
      t.references :docker_image, :null => false
      t.references :repository, :null => true
    end

    add_index :katello_docker_images, :uuid, :unique => true

    add_index :katello_docker_tags, [:docker_image_id, :repository_id, :name],
              :name => :docker_tag_docker_image_repo_name, :unique => true

    add_foreign_key :katello_docker_tags, :katello_docker_images, :column => "docker_image_id"

    add_index :katello_repository_docker_images, [:docker_image_id, :repository_id],
              :name => :katello_repo_docker_imgs_image_repo_id, :unique => true

    add_foreign_key :katello_repository_docker_images, :katello_repositories,
                    :column => :repository_id

    add_foreign_key :katello_repository_docker_images, :katello_docker_images,
                    :column => :docker_image_id
  end
end
