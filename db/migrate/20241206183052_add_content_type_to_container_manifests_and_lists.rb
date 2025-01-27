class AddContentTypeToContainerManifestsAndLists < ActiveRecord::Migration[6.1]
  def change
    add_column :katello_docker_manifests, :content_type, :string, :limit => 255
    add_column :katello_docker_manifest_lists, :content_type, :string, :limit => 255

    add_index :katello_docker_manifests, :content_type
    add_index :katello_docker_manifest_lists, :content_type
  end
end
