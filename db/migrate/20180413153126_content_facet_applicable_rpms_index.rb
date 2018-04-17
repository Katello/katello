class ContentFacetApplicableRpmsIndex < ActiveRecord::Migration[5.1]
  def change
    add_index :katello_content_facet_applicable_rpms, :content_facet_id, :name => "index_k_content_facet_applicable_rpms_on_content_facet_id"
  end
end
