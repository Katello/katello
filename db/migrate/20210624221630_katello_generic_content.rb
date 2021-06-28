class KatelloGenericContent < ActiveRecord::Migration[6.0]
  def change
    create_table "katello_generic_content_units" do |t|
      t.string 'name'
      t.string 'version'
      t.string 'pulp_id'
      t.string 'content_type'
      t.timestamps
    end

    create_table "katello_repository_generic_content_units" do |t|
      t.references :generic_content_unit, :null => false, index: { :name => 'index_katello_repo_generic_content_unit' }
      t.references :repository, index: false
      t.timestamps
    end

    add_index :katello_repository_generic_content_units, [:generic_content_unit_id, :repository_id], :unique => true, :name => 'repository_generic_content_unit_ids'

    add_foreign_key "katello_repository_generic_content_units", "katello_generic_content_units", :column => "generic_content_unit_id"
    add_foreign_key "katello_repository_generic_content_units", "katello_repositories", :column => "repository_id"
  end
end
