class AddIndexToKatelloContentFacetErrata < ActiveRecord::Migration
  def change
    add_index :katello_content_facet_errata, :content_facet_id, using: 'btree'
  end
end
