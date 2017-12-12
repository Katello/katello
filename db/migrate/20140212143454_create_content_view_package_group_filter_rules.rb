class CreateContentViewPackageGroupFilterRules < ActiveRecord::Migration[4.2]
  def change
    create_table :katello_content_view_package_group_filter_rules do |t|
      t.references :content_view_filter
      t.string :name, :limit => 255

      t.timestamps
    end
  end
end
