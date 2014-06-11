class AddUuidToContentViewPackageGroupFilterRule < ActiveRecord::Migration
  def change
    add_column :katello_content_view_package_group_filter_rules, :uuid, :string
  end
end
