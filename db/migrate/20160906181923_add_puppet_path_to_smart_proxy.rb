class AddPuppetPathToSmartProxy < ActiveRecord::Migration[4.2]
  def change
    add_column :smart_proxies, :puppet_path, :text
  end
end
