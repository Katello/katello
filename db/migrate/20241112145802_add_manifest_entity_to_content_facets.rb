class AddManifestEntityToContentFacets < ActiveRecord::Migration[6.1]
  def change
    add_reference :katello_content_facets, :manifest_entity, polymorphic: true, index: true
    change_column_null :katello_content_facets, :manifest_entity_type, true
    change_column_null :katello_content_facets, :manifest_entity_id, true
  end
end
