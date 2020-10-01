class CreateKatelloSmartProxySyncHistory < ActiveRecord::Migration[6.0]
  def change
    create_table :katello_smart_proxy_sync_history do |t|
      t.references :smart_proxy, :null => false
      t.references :repository, :null => false
      t.datetime :started_at
      t.datetime :finished_at
    end
    add_index "katello_smart_proxy_sync_history", ["smart_proxy_id"], :name => "index_spsh_smart_proxy_id"
    add_index "katello_smart_proxy_sync_history", ["repository_id"], :name => "index_spsh_repository_id"
    add_index "katello_smart_proxy_sync_history", [:smart_proxy_id, :repository_id], :unique => true, :name => 'index_spsh_smart_proxy_repository_unique'
  end
end
