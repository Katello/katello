class RemoveKatelloPuppetModules < ActiveRecord::Migration[4.2]
  def up
    drop_table :katello_content_view_puppet_environment_puppet_modules
    drop_table :katello_content_view_puppet_environments
    drop_table :katello_content_view_puppet_modules
    drop_table :katello_repository_puppet_modules
    drop_table :katello_puppet_modules
  end

  # rubocop:disable Metrics/MethodLength
  def down
    create_table 'katello_puppet_modules' do |t|
      t.timestamps
      t.string "uuid", :null => false, :limit => 255
      t.string 'name', :limit => 255
      t.string 'author', :limit => 255
      t.string 'title', :limit => 255
      t.string 'version', :limit => 255
      t.text 'summary'
    end

    add_index :katello_puppet_modules, :uuid, :unique => true

    create_table "katello_repository_puppet_modules" do |t|
      t.timestamps
      t.references :puppet_module, :null => false
      t.references :repository, :null => true
    end

    add_index :katello_repository_puppet_modules,
              [:puppet_module_id, :repository_id],
              :unique => true,
              :name => 'index_katello_repo_puppet_module_on_module_id_and_repo_id'

    add_foreign_key "katello_repository_puppet_modules", "katello_puppet_modules",
                    :name => "katello_repository_puppet_modules_puppet_module_id_fk",
                    :column => "puppet_module_id"
    add_foreign_key "katello_repository_puppet_modules", "katello_repositories",
                    :name => "katello_repository_puppet_modules_repo_id_fk",
                    :column => "repository_id"

    create_table "katello_content_view_puppet_environment_puppet_modules" do |t|
      t.references :puppet_module, :null => false
      t.references :content_view_puppet_environment, :null => true
      t.timestamps
    end

    add_index :katello_content_view_puppet_environment_puppet_modules,
              [:puppet_module_id, :content_view_puppet_environment_id],
              :unique => true,
              :name => 'index_katello_cv_puppet_env_module_on_module_id_and_cvpe_id'

    add_foreign_key "katello_content_view_puppet_environment_puppet_modules", "katello_puppet_modules",
                    :name => "katello_cv_puppet_env_puppet_modules_puppet_module_id_fk",
                    :column => "puppet_module_id"
    add_foreign_key "katello_content_view_puppet_environment_puppet_modules", "katello_content_view_puppet_environments",
                    :name => "katello_content_view_puppet_env_puppet_modules_repo_id_fk",
                    :column => "content_view_puppet_environment_id"

    add_column :katello_puppet_modules, :sortable_version, :string
  end
end
