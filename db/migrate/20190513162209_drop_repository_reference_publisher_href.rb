class DropRepositoryReferencePublisherHref < ActiveRecord::Migration[5.2]
  def change
    remove_column :katello_repository_references, :publisher_href
  end
end
