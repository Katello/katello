class AddPulpUrlToSmartProxy < ActiveRecord::Migration[5.1]
  def change
    add_column :smart_proxies, :pulp_url, :text
  end
end
