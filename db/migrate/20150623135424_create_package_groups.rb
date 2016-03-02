class CreatePackageGroups < ActiveRecord::Migration
  def change
    create_table "katello_package_groups" do |t|
      t.string "name", :limit => 255
      t.string "uuid", :null => false, :limit => 255
      t.string "description", :limit => 255
      t.timestamps
    end
    add_index :katello_package_groups, :uuid, :unique => true

    create_table "katello_repository_package_groups" do |t|
      t.references :package_group, :null => false
      t.references :repository, :null => true
      t.timestamps
    end
    add_index "katello_repository_package_groups", [:package_group_id, :repository_id], :unique => true,
              :name => "index_katello_repository_package_groups_on_pgid_repoid"

    add_foreign_key "katello_repository_package_groups", "katello_package_groups",
                    :name => "katello_repository_package_groups_package_groups_id_fk", :column => "package_group_id"
    add_foreign_key "katello_repository_package_groups", "katello_repositories",
                    :name => "katello_repository_package_groups_repo_id_fk", :column => "repository_id"
  end

  def down
    drop_table "katello_package_groups"
    drop_table "katello_repository_package_groups"
  end
end
