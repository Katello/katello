class AddUuidToContentViewPackageGroupFilterRule < ActiveRecord::Migration[4.2]
  def change
    add_column :katello_content_view_package_group_filter_rules, :uuid,
      :string, :limit => 255
  end
end
