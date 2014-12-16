class TrackVersionComponents < ActiveRecord::Migration
  def change
    create_table "katello_content_view_version_components" do |t|
      t.integer :component_version_id, :null => false
      t.integer :composite_version_id, :null => false
      t.timestamps
    end

    add_index :katello_content_view_version_components, [:component_version_id, :composite_version_id],
              :unique => true, :name => :katello_cvv_components_cid_cid_unq
    add_foreign_key "katello_content_view_version_components", "katello_content_view_versions",
      :name => "katello_cvv_components_component_fk", :column => "component_version_id"

    add_foreign_key "katello_content_view_version_components", "katello_content_view_versions",
      :name => "katello_cvv_components_composite_fk", :column => "composite_version_id"
  end
end
