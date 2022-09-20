class AddHttpProxyToSmartProxy < ActiveRecord::Migration[6.1]
  def change
    add_column      :katello_alternate_content_sources, :use_http_proxies, :boolean
    add_column      :smart_proxies, :http_proxy_id, :integer
    add_foreign_key :smart_proxies, :http_proxies
  end
end
