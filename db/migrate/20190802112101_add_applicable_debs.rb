class AddApplicableDebs < ActiveRecord::Migration[5.2]
  def change
    create_table :katello_content_facet_applicable_debs do |t|
      t.references :content_facet, null: false, index: { name: :katello_cf_applicable_debs_cf_idx }
      t.references :deb, :null => false, :index => { name: :katello_cf_applicable_debs_deb_idx }
    end

    add_index :katello_content_facet_applicable_debs, [:deb_id, :content_facet_id],
              name: 'index_k_content_facet_deb_rid_cfid', unique: true
    add_index :katello_content_facet_applicable_debs, :content_facet_id,
              name: 'index_k_content_facet_applicable_debs_on_content_facet_id'

    add_column :katello_content_facets, :applicable_deb_count, :integer, null: false, default: 0
    add_column :katello_content_facets, :upgradable_deb_count, :integer, null: false, default: 0
  end
end
