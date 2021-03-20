class CreateContentViewDebFilterRules < ActiveRecord::Migration[6.0]
  def change
    create_table :katello_content_view_deb_filter_rules do |t|
      t.string :version, :limit => 255
      t.string :name, :limit => 255
      t.string :min_version, :limit => 255
      t.string :max_version, :limit => 255
      t.string :architecture, :limit => 255
      t.references :content_view_filter, index: { name: "content_view_filter_id" }

      t.timestamps
    end

    add_foreign_key :katello_content_view_deb_filter_rules, :katello_content_view_filters,
                    :name => "katello_content_view_deb_filter_rules_filter_fk", :column => 'content_view_filter_id'
  end
end
