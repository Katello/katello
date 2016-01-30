class AddDockerV2Schema < ActiveRecord::Migration
  def up
    create_table :katello_docker_manifests do |t|
      t.string :name
      t.integer :schema_version
      t.string :uuid
      t.string :digest
      t.boolean :downloaded
      t.timestamps
    end

    create_table :katello_repository_docker_manifests do |t|
      t.references :docker_manifest, :null => false
      t.references :repository, :null => true
      t.timestamps
    end

    add_column :katello_docker_tags, :uuid, :string
    add_column :katello_docker_tags, :docker_manifest_id, :integer

    add_index :katello_docker_tags, :uuid, :unique => true

    add_index :katello_repository_docker_manifests, [:docker_manifest_id, :repository_id],
              :name => :katello_repo_docker_manifest_repo_id, :unique => true

    add_foreign_key :katello_repository_docker_manifests, :katello_repositories,
                    :column => :repository_id

    add_foreign_key :katello_docker_tags, :katello_docker_manifests,
                    :column => :docker_manifest_id
  end

  def down
    remove_column :katello_docker_tags, :uuid
    remove_column :katello_docker_tags, :docker_manifest_id
    drop_table :katello_docker_manifests
    drop_table :katello_repository_docker_manifests
  end
end
