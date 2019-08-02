class AddHttpProxyToRepositoryRoot < ActiveRecord::Migration[5.2]
  def change
    add_column      :katello_root_repositories, :http_proxy_id, :integer
    add_foreign_key :katello_root_repositories, :http_proxies
  end
end
