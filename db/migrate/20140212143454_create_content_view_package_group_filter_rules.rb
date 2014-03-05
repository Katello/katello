class CreateContentViewPackageGroupFilterRules < ActiveRecord::Migration
  def change
    create_table :katello_content_view_package_group_filter_rules do |t|
      t.references :content_view_filter
      t.string :name

      t.timestamps
    end
  end
end
