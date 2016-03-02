class CreateContentViewPackageFilterRules < ActiveRecord::Migration
  def change
    create_table :katello_content_view_package_filter_rules do |t|
      t.references :content_view_filter
      t.string :name, :limit => 255
      t.string :version, :limit => 255
      t.string :min_version, :limit => 255
      t.string :max_version, :limit => 255

      t.timestamps
    end
  end
end
