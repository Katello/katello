class AddContentFacetIdIndexes < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :katello_content_view_environment_content_facets,
              :content_facet_id,
              name: 'index_cve_content_facets_on_content_facet_id',
              algorithm: :concurrently

    add_index :katello_content_facet_repositories,
              :content_facet_id,
              name: 'index_content_facet_repos_on_content_facet_id',
              algorithm: :concurrently
  end
end
