class AddBootcFactsToContentFacet < ActiveRecord::Migration[6.1]
  def change
    add_column :katello_content_facets, :bootc_booted_image, :string
    add_column :katello_content_facets, :bootc_booted_digest, :string

    add_column :katello_content_facets, :bootc_available_image, :string
    add_column :katello_content_facets, :bootc_available_digest, :string

    add_column :katello_content_facets, :bootc_staged_image, :string
    add_column :katello_content_facets, :bootc_staged_digest, :string

    add_column :katello_content_facets, :bootc_rollback_image, :string
    add_column :katello_content_facets, :bootc_rollback_digest, :string

    add_index :katello_content_facets, :bootc_booted_image
    add_index :katello_content_facets, :bootc_booted_digest

    add_index :katello_content_facets, :bootc_available_image
    add_index :katello_content_facets, :bootc_available_digest

    add_index :katello_content_facets, :bootc_staged_image
    add_index :katello_content_facets, :bootc_staged_digest

    add_index :katello_content_facets, :bootc_rollback_image
    add_index :katello_content_facets, :bootc_rollback_digest
  end
end
