class UpdateContentViewFiltersRepositoriesJoinTable < ActiveRecord::Migration[5.2]
  def up
    rename_table :katello_content_view_filters_repositories, :katello_repository_content_view_filters
    add_column :katello_repository_content_view_filters, :id, :primary_key
  end

  def down
    rename_table :katello_repository_content_view_filters, :katello_content_view_filters_repositories
    remove_column :katello_content_view_filters_repositories, :id
  end
end
