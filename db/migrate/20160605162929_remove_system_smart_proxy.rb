class RemoveSystemSmartProxy < ActiveRecord::Migration[4.2]
  def change
    remove_column :smart_proxies, :content_host_id, :integer
  end
end
