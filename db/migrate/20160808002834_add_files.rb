class AddFiles < ActiveRecord::Migration[4.2]
  def change
    create_table "katello_files" do |t|
      t.timestamps
      t.string "uuid", :null => false, :limit => 255
      t.string 'name', :limit => 255
      t.string 'checksum', :limit => 255
      t.string 'path'
    end

    add_index :katello_files, :uuid, :unique => true
    add_index :katello_files, [
      :id,
      :uuid,
      :name,
    ],
    :name => 'katello_files_fields_index'

    create_table "katello_repository_files" do |t|
      t.references :file, :null => false
      t.references :repository, :null => true
      t.timestamps
    end

    add_index :katello_repository_files, [:file_id, :repository_id], :unique => true

    add_foreign_key "katello_repository_files", "katello_files", :column => "file_id"
    add_foreign_key "katello_repository_files", "katello_repositories", :column => "repository_id"
  end
end
