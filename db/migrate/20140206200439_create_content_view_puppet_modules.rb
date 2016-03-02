class CreateContentViewPuppetModules < ActiveRecord::Migration
  def change
    create_table :katello_content_view_puppet_modules do |t|
      t.references :content_view
      t.string :name, :limit => 255
      t.string :author, :limit => 255
      t.string :uuid, :limit => 255

      t.timestamps
    end

    add_index :katello_content_view_puppet_modules, :content_view_id
    add_index :katello_content_view_puppet_modules, [:name, :content_view_id], :unique => true, :name => :katello_cv_puppet_modules_name
    add_index :katello_content_view_puppet_modules, [:name, :author, :content_view_id], :unique => true, :name => :katello_cv_puppet_modules_name_author
    add_index :katello_content_view_puppet_modules, [:uuid, :content_view_id], :unique => true, :name => :katello_cv_puppet_modules_uuid
  end
end
