class AddPulpProxyToHost < ActiveRecord::Migration
  def change
    add_column :hosts,      :pulp_proxy_id, :integer
    add_column :hostgroups, :pulp_proxy_id, :integer

    add_index  :hosts,      :pulp_proxy_id
    add_index  :hostgroups, :pulp_proxy_id

    add_foreign_key :hosts,      :smart_proxies, :name => "hosts_pulp_proxy_id_fk",       :column => "pulp_proxy_id"
    add_foreign_key :hostgroups, :smart_proxies, :name => "hostgroups_pulp_proxy_id_fk", :column => "pulp_proxy_id"
  end
end
