class AddIndexToKatelloContentFacetErrata < ActiveRecord::Migration[4.2]
  def change
    add_index :katello_content_facet_errata, :content_facet_id, using: 'btree'
  end
end
