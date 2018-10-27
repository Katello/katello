class AddApplicableModules < ActiveRecord::Migration[5.2]
  def change
    create_table "katello_content_facet_applicable_module_streams" do |t|
      t.references 'content_facet', :null => false, :index => { :name => :katello_cfams_cf_idx }
      t.references 'module_stream', :null => false, :index => { :name => :katello_cfams_ms_idx }
    end

    add_foreign_key :katello_content_facet_applicable_module_streams,
                    :katello_module_streams,
                    column: :module_stream_id,
                    name: :katello_cfams_mod_stream_id_fk

    add_foreign_key :katello_content_facet_applicable_module_streams,
                    :katello_content_facets,
                    column: :content_facet_id,
                    name: :katello_cfams_cf_fk

    add_index "katello_content_facet_applicable_module_streams", ["module_stream_id", "content_facet_id"],
              :name => "katello_content_facet_module_stream_rid_cfid", :unique => true

    add_column :katello_content_facets, :applicable_module_stream_count, :integer, :null => false, :default => 0
    add_column :katello_content_facets, :upgradable_module_stream_count, :integer, :null => false, :default => 0
  end
end
