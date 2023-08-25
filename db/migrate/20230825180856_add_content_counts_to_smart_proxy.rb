class AddContentCountsToSmartProxy < ActiveRecord::Migration[6.1]
  def change
    # {:content_view_versions=>{87=>{:repositories=>{1=>{:rpms=>98, :module_streams=>9898}, 2=>{:tags=>32432, :manifests=>323}}}}}
    add_column :smart_proxies, :content_counts, :jsonb
    add_index :smart_proxies, :content_counts
  end
end
