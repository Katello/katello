class AddSystemRepository < ActiveRecord::Migration
  def up
    create_table "katello_system_repositories" do |t|
      t.references :system, :null => false
      t.references :repository, :null => true
    end

    add_index :katello_system_repositories, [:system_id, :repository_id], :unique => true,
                                                                          :name => :katello_system_repositories_sid_rid

    add_foreign_key "katello_system_repositories", "katello_systems",
                    :name => "katello_system_repositories_system_id_fk", :column => "system_id"
    add_foreign_key "katello_system_repositories", "katello_repositories",
                    :name => "katello_system_repositories_repo_id_fk", :column => "repository_id"
  end

  def down
    drop_table "katello_system_repositories"
  end
end
