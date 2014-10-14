class AddDockerImageFields < ActiveRecord::Migration
  def up
    add_column :docker_images, :katello_uuid, :string
    add_column :docker_images, :katello_repository_id, :integer
    add_column :docker_tags, :katello_repository_id, :integer

    create_table :katello_repository_docker_images do |t|
      t.references :docker_image, :null => false
      t.references :repository, :null => true
    end

    add_index :docker_images, :katello_uuid, :unique => true

    add_index :katello_repository_docker_images, [:docker_image_id, :repository_id],
              :name => :katello_repo_docker_imgs_image_repo_id, :unique => true

    add_index :docker_tags, [:docker_image_id, :katello_repository_id, :tag],
              :name => :katello_repo_docker_tags_image_repo_id, :unique => true

    add_foreign_key :katello_repository_docker_images, :docker_images,
                    :column => :docker_image_id
    add_foreign_key :katello_repository_docker_images, :katello_repositories,
                    :column => :repository_id

    add_foreign_key :docker_tags, :katello_repositories,
                    :column => :katello_repository_id
  end

  def down
    remove_column :docker_images, :katello_uuid
    remove_column :docker_images, :katello_repository_id
    remove_column :docker_tags, :katello_repository_id
    drop_table :katello_repository_docker_images
  end
end
