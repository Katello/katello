class RemoveHttpProxyFromKatelloAlternateContentSources < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :katello_alternate_content_sources, :http_proxies
    remove_column :katello_alternate_content_sources, :http_proxy_id, :integer
  end
end
