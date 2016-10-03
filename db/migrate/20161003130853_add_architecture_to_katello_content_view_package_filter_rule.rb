class AddArchitectureToKatelloContentViewPackageFilterRule < ActiveRecord::Migration
  def change
    add_column :katello_content_view_package_filter_rules, :architecture, :string
  end
end
