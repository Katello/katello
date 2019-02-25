class AddPulp3Attributes < ActiveRecord::Migration[5.2]
  def change
    #TODO: Add indexes and foreign keys
    create_table :katello_distribution_references do |t|
      t.string :path, :null => false
      t.string :href, :null => false
      t.references 'root_repository', :null => false
    end

    create_table :katello_repository_references do |t|
      t.string :repository_href, :null => false
      t.string :publisher_href
      t.references 'content_view', :null => false
      t.references 'root_repository', :null => false
    end

    add_column :katello_repositories, :remote_href, :string
    add_column :katello_repositories, :publication_href, :string
    add_column :katello_repositories, :version_href, :string
  end
end
