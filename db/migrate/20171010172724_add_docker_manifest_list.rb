class AddDockerManifestList < ActiveRecord::Migration
  def up
    create_table :katello_docker_manifest_lists do |t|
      t.integer :schema_version
      t.string :uuid, :limit => 255
      t.string :digest, :limit => 255
      t.boolean :downloaded
      t.timestamps
    end

    create_table :katello_repository_docker_manifest_lists do |t|
      t.references :docker_manifest_list, :null => false
      t.references :repository, :null => true
      t.timestamps
    end

    create_table :katello_docker_manifest_list_manifests do |t|
      t.references :docker_manifest_list, :null => false
      t.references :docker_manifest, :null => false
      t.timestamps
    end

    remove_foreign_key :katello_docker_tags, :docker_manifest
    rename_column :katello_docker_tags, :docker_manifest_id, :docker_taggable_id
    add_column :katello_docker_tags, :docker_taggable_type, :string, :limit => 255, :default => "Katello::DockerManifest"

    add_index :katello_docker_tags, [:docker_taggable_id, :docker_taggable_type], :name => "docker_taggable_type_index"

    add_index :katello_repository_docker_manifest_lists, [:docker_manifest_list_id, :repository_id],
              :name => :katello_repo_docker_manifest_list_repo_id, :unique => true

    add_index :katello_docker_manifest_list_manifests, [:docker_manifest_list_id, :docker_manifest_id],
              :name => :katello_docker_manifest_lisst_manifest, :unique => true

    add_foreign_key :katello_repository_docker_manifest_lists, :katello_repositories,
                    :column => :repository_id

    add_foreign_key :katello_docker_manifest_list_manifests, :katello_docker_manifests,
                    :column => :docker_manifest_id
  end

  class FakeDockerMetaTag < ApplicationRecord
    self.table_name = 'katello_docker_meta_tags'
    def self.cleanup
      self.where(:schema2_id => nil, :schema1_id => nil).delete_all
    end
  end

  class FakeDockerTag < ApplicationRecord
    self.table_name = 'katello_docker_tags'
  end

  def down
    drop_table :katello_docker_manifest_list_manifests
    drop_table :katello_repository_docker_manifest_lists
    drop_table :katello_docker_manifest_lists

    FakeDockerTag.where("docker_taggable_id not in (select id from katello_docker_manifests)").destroy_all
    FakeDockerMetaTag.cleanup

    remove_column :katello_docker_tags, :docker_taggable_type
    rename_column :katello_docker_tags, :docker_taggable_id, :docker_manifest_id

    add_foreign_key :katello_docker_tags, :katello_docker_manifests,
                    :column => 'docker_manifest_id'
  end
end
