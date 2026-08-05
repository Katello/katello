class AddContainerRegistryAuthToSmartProxy < ActiveRecord::Migration[7.0]
  def change
    add_column :smart_proxies, :container_registry_auth_enabled, :boolean, default: false, null: false
  end
end
