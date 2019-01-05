class CreateYumMetadataFile < ActiveRecord::Migration[5.2]
  def up
    create_table :katello_yum_metadata_files do |t|
      t.string :uuid, null: false
      t.string :checksum, null: true
      t.string :name, null: true
      t.integer :repository_id, null: true
      t.timestamps
    end

    add_foreign_key :katello_yum_metadata_files, :katello_repositories, :column => "repository_id"
    change_column :katello_yum_metadata_files, :created_at, :datetime, :null => true
    change_column :katello_yum_metadata_files, :updated_at, :datetime, :null => true
  end

  def down
    remove_foreign_key :katello_yum_metadata_files, :katello_repositories
    drop_table :katello_yum_metadata_files
  end
end
