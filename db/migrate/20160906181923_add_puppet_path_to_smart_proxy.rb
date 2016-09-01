class AddPuppetPathToSmartProxy < ActiveRecord::Migration
  def change
    add_column :smart_proxies, :puppet_path, :text
  end
end
