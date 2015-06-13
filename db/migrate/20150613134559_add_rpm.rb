class AddRpm < ActiveRecord::Migration
  def up
    create_table "katello_rpms" do |t|
      t.string "uuid", :null => false
      t.timestamps
      t.string 'name'
      t.string 'version'
      t.string 'release'
      t.string 'arch'
      t.string 'epoch'
      t.string 'filename'
      t.string 'sourcerpm'
      t.string 'checksum'
      t.string 'version_sortable'
      t.string 'release_sortable'
      t.string 'summary'
    end

    add_index :katello_rpms, :uuid, :unique => true
    add_index :katello_rpms, [:id, :uuid, :name, :version, :release, :arch, :version_sortable, :release_sortable], :name => 'katello_rpms_fields_index'

    create_table "katello_repository_rpms" do |t|
      t.references :rpm, :null => false
      t.references :repository, :null => true
      t.timestamps
    end

    add_index :katello_repository_rpms, [:rpm_id, :repository_id], :unique => true

    add_foreign_key "katello_repository_rpms", "katello_rpms", :column => "rpm_id"
    add_foreign_key "katello_repository_rpms", "katello_repositories", :column => "repository_id"
  end

  def down
    drop_table "katello_repository_rpms"
    drop_table "katello_rpms"
  end
end
