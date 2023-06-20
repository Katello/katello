class AddCustomCdnAuthEnabledToKatelloCdnConfigurations < ActiveRecord::Migration[6.1]
  def change
    add_column :katello_cdn_configurations, :custom_cdn_auth_enabled, :boolean, default: false
  end
end
