class RemoveSystemSmartProxy < ActiveRecord::Migration
  def change
    remove_column :smart_proxies, :content_host_id, :integer
  end
end
