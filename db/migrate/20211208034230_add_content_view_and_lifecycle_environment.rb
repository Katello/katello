class AddContentViewAndLifecycleEnvironment < ActiveRecord::Migration[6.0]
  def change
    add_column :katello_cdn_configurations, :upstream_content_view_label, :string
    add_column :katello_cdn_configurations, :upstream_lifecycle_environment_label, :string
  end
end
