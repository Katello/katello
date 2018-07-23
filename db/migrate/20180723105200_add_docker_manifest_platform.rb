class AddDockerManifestPlatform < ActiveRecord::Migration[5.1]
  def up
    create_table :katello_docker_manifest_platforms do |t|
      t.string :arch, :limit => 255
      t.string :os, :limit => 255
      t.timestamps
    end

    create_table :katello_docker_manifest_manifest_platforms do |t|
      t.references :docker_manifest, :null => false, :index => false
      t.references :docker_manifest_platform, :null => false, :index => false
      t.timestamps
    end

    create_table :katello_docker_manifest_list_manifest_platforms do |t|
      t.references :docker_manifest_list, :null => false, :index => false
      t.references :docker_manifest_platform, :null => false, :index => false
      t.timestamps
    end

    add_index :katello_docker_manifest_platforms, [:arch, :os], :unique => true

    add_index :katello_docker_manifest_manifest_platforms, [:docker_manifest_id, :docker_manifest_platform_id],
              :name => :katello_docker_manifest_manifest_platform_dm_dmp_id, :unique => true

    add_index :katello_docker_manifest_list_manifest_platforms, [:docker_manifest_list_id, :docker_manifest_platform_id],
              :name => :katello_docker_manifest_manifest_platform_dml_dmp_id, :unique => true

    add_foreign_key :katello_docker_manifest_manifest_platforms, :katello_docker_manifests,
                    :column => :docker_manifest_id
    add_foreign_key :katello_docker_manifest_manifest_platforms, :katello_docker_manifest_platforms,
                    :column => :docker_manifest_platform_id

    add_foreign_key :katello_docker_manifest_list_manifest_platforms, :katello_docker_manifest_lists,
                    :column => :docker_manifest_list_id
    add_foreign_key :katello_docker_manifest_list_manifest_platforms, :katello_docker_manifest_platforms,
                    :column => :docker_manifest_platform_id
  end

  def down
    remove_column :katello_docker_manifest_manifest_platforms, :docker_manifest_id
    remove_column :katello_docker_manifest_manifest_platforms, :docker_manifest_platform_id

    remove_column :katello_docker_manifest_list_manifest_platforms, :docker_manifest_list_id
    remove_column :katello_docker_manifest_list_manifest_platforms, :docker_manifest_platform_id

    drop_table :katello_docker_manifest_platforms
    drop_table :katello_docker_manifest_manifest_platforms
    drop_table :katello_docker_manifest_list_manifest_platforms
  end
end
