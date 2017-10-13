class AddSrpm < ActiveRecord::Migration
  def up
    create_table "katello_srpms" do |t|
      t.string "uuid", :null => false, :limit => 255
      t.timestamps
      t.string 'name', :limit => 255
      t.string 'version', :limit => 255
      t.string 'release', :limit => 255
      t.string 'arch', :limit => 255
      t.string 'epoch', :limit => 255
      t.string 'filename', :limit => 255
      t.string 'checksum', :limit => 255
      t.string 'version_sortable', :limit => 255
      t.string 'release_sortable', :limit => 255
      t.string 'summary', :limit => 255
      t.string 'nvra', :limit => 1020
    end

    add_index :katello_srpms, :uuid, :unique => true
    add_index :katello_srpms, [:id, :uuid, :name, :version, :release, :arch, :version_sortable, :release_sortable], :name => 'katello_srpms_fields_index'

    create_table "katello_repository_srpms" do |t|
      t.references :srpm, :null => false
      t.references :repository, :null => true
      t.timestamps
    end

    add_index :katello_repository_srpms, [:srpm_id, :repository_id], :unique => true

    add_foreign_key "katello_repository_srpms", "katello_srpms", :column => "srpm_id"
    add_foreign_key "katello_repository_srpms", "katello_repositories", :column => "repository_id"
  end

  def down
    drop_table "katello_repository_srpms"
    drop_table "katello_srpms"
  end
end
