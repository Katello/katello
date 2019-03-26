class RemoveDockerImageSchema < ActiveRecord::Migration[4.2]
  def up
    if foreign_key_exists?(:katello_docker_tags, :name => "katello_docker_tags_docker_image_id_fk")
      remove_foreign_key :katello_docker_tags, :name => "katello_docker_tags_docker_image_id_fk"
    end
    remove_column :katello_docker_tags, :docker_image_id
    drop_table :katello_docker_images
  end

  def down
    add_column :katello_docker_tags, :docker_image_id, :integer

    create_table :katello_docker_images do |t|
      t.string :image_id, :limit => 255
      t.integer :size
      t.string :uuid, :limit => 255
      t.timestamps
    end

    add_index :katello_docker_images, :uuid, :unique => true

    add_index :katello_docker_tags, [:docker_image_id, :repository_id, :name],
              :name => :docker_tag_docker_image_repo_name, :unique => true

    add_foreign_key :katello_docker_tags, :katello_docker_images, :column => "docker_image_id"
  end
end
