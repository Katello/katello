class CreateDockerMetaTag < ActiveRecord::Migration
  def change
    create_table :katello_docker_meta_tags do |t|
      t.integer  "schema1_id"
      t.integer  "schema2_id"
      t.string   :name, :limit => 255
      t.references :repository, :null => true
    end
    add_index :katello_docker_meta_tags, [:schema1_id, :schema2_id], :unique => true
    add_foreign_key :katello_docker_meta_tags, :katello_repositories,
                    :name => "katello_docker_meta_tags_repositories_fk", :column => 'repository_id'
  end
end
