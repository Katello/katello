class CreateKatelloAnsibleCollections < ActiveRecord::Migration[5.2]
  def change
    create_table :katello_ansible_collections do |t|
      t.string :pulp_id, :null => false, :limit => 255
      t.string :checksum
      t.string :name
      t.string :namespace
      t.string :version
      t.timestamps
    end

    add_index :katello_ansible_collections, :pulp_id, :unique => true, :name => 'katello_ansible_collections_pulp_id_index'
    add_index :katello_ansible_collections, [:id, :pulp_id, :name, :version, :namespace], :name => 'katello_ansible_collections_fields_index'

    create_table "katello_repository_ansible_collections" do |t|
      t.references :ansible_collection, :null => false, index: { :name => 'index_katello_repo_ansible_collections' }
      t.references :repository, :null => false
      t.timestamps
    end

    add_index :katello_repository_ansible_collections, [:ansible_collection_id, :repository_id], :unique => true, :name => 'repository_ansible_collection_ids'

    add_foreign_key "katello_repository_ansible_collections", "katello_ansible_collections", :column => "ansible_collection_id"
    add_foreign_key "katello_repository_ansible_collections", "katello_repositories", :column => "repository_id"
  end
end
