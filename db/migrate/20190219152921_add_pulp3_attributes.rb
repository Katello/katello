class AddPulp3Attributes < ActiveRecord::Migration[5.2]
  def change
    #TODO: Add indexes and foreign keys
    create_table :katello_distribution_references do |t|
      t.string :path, :null => false
      t.string :href, :null => false
      t.references 'root_repository', :null => false, :index => true
      t.foreign_key 'katello_root_repositories', :column => 'root_repository_id'
    end

    create_table :katello_repository_references do |t|
      t.string :repository_href, :null => false
      t.string :publisher_href
      t.references 'content_view', :null => false
      t.foreign_key 'katello_content_views', :column => 'content_view_id'

      t.references 'root_repository', :null => false
      t.foreign_key 'katello_root_repositories', :column => 'root_repository_id'
      t.index [:content_view_id, :root_repository_id], :name => 'katello_repository_references_cvid_rr_id'
    end

    add_column :katello_repositories, :remote_href, :string
    add_column :katello_repositories, :publication_href, :string
    add_column :katello_repositories, :version_href, :string
  end
end
