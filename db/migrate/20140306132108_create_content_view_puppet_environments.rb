class CreateContentViewPuppetEnvironments < ActiveRecord::Migration
  def change
    create_table :katello_content_view_puppet_environments do |t|
      t.references :content_view_version
      t.references :environment
      t.string     :name
      t.string     :pulp_id, :null => false
      t.timestamps
    end

    add_index :katello_content_view_puppet_environments, [:content_view_version_id],
              :name => :index_cvpe_on_content_view_version_id
    add_index :katello_content_view_puppet_environments, [:environment_id],
              :name => :index_cvpe_on_environment_id
    add_index :katello_content_view_puppet_environments, [:pulp_id],
              :name => :index_cvpe_on_pulp_id
  end
end
