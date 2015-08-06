class AddContentHostIdToSmartProxy < ActiveRecord::Migration
  def change
    add_column :smart_proxies, :content_host_id, :integer
    add_foreign_key :smart_proxies, :katello_systems, :column => "content_host_id"
  end
end
