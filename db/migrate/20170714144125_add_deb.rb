class AddDeb < ActiveRecord::Migration[4.2]
  def up
    create_table "katello_debs" do |t|
      t.string "uuid", :null => false, :limit => 255
      t.timestamps
      t.string 'name', :limit => 255
      t.string 'version', :limit => 255
      t.string 'architecture', :limit => 255
      t.string 'filename', :limit => 255
      t.string 'checksum', :limit => 255
      t.string 'version_sortable', :limit => 255
      t.string 'description', :limit => 255
    end

    add_index :katello_debs, :uuid, :unique => true
    add_index :katello_debs, [:id, :uuid, :name, :version, :architecture, :version_sortable], :name => 'katello_debs_fields_index'

    create_table "katello_repository_debs" do |t|
      t.references :deb, :null => false
      t.references :repository, :null => true
      t.timestamps
    end

    add_index :katello_repository_debs, [:deb_id, :repository_id], :unique => true

    add_foreign_key "katello_repository_debs", "katello_debs", :column => "deb_id"
    add_foreign_key "katello_repository_debs", "katello_repositories", :column => "repository_id"
  end

  def down
    drop_table "katello_repository_debs"
    drop_table "katello_debs"
  end
end
