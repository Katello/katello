class AddPulpProxyToHost < ActiveRecord::Migration
  def change
    add_column :hosts,      :content_source_id, :integer
    add_column :hostgroups, :content_source_id, :integer

    add_index  :hosts,      :content_source_id
    add_index  :hostgroups, :content_source_id

    add_foreign_key :hosts,      :smart_proxies, :name => "hosts_content_source_id_fk",       :column => "content_source_id"
    add_foreign_key :hostgroups, :smart_proxies, :name => "hostgroups_content_source_id_fk", :column => "content_source_id"
  end
end
