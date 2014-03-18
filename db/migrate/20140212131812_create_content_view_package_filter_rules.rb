class CreateContentViewPackageFilterRules < ActiveRecord::Migration
  def change
    create_table :katello_content_view_package_filter_rules do |t|
      t.references :content_view_filter
      t.string :name
      t.string :version
      t.string :min_version
      t.string :max_version

      t.timestamps
    end
  end
end
