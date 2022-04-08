class AddAlternateContentSources < ActiveRecord::Migration[6.0]
  def up
    create_table :katello_alternate_content_sources do |t|
      t.string :name, limit: 255, null: false
      t.string :label, limit: 255, null: false
      t.text :description
      t.integer :ssl_ca_cert_id
      t.integer :ssl_client_cert_id
      t.integer :ssl_client_key_id
      t.integer :http_proxy_id
      t.string :base_url, limit: 1024
      t.string :subpaths, array: true, default: []
      t.string :content_type, limit: 255, default: 'yum'
      t.string :alternate_content_source_type, limit: 255, default: 'custom', null: false
      t.boolean :verify_ssl, default: true, null: false
      t.string 'upstream_username', limit: 255
      t.string 'upstream_password', limit: 1024
    end

    add_foreign_key :katello_alternate_content_sources, :katello_content_credentials, :name => :katello_alternate_content_sources_ssl_ca_cert_id, :column => :ssl_ca_cert_id
    add_foreign_key :katello_alternate_content_sources, :katello_content_credentials, :name => :katello_alternate_content_sources_ssl_client_cert_id, :column => :ssl_client_cert_id
    add_foreign_key :katello_alternate_content_sources, :katello_content_credentials, :name => :katello_alternate_content_sources_ssl_client_key_id, :column => :ssl_client_key_id
    add_foreign_key :katello_alternate_content_sources, :http_proxies, :name => :katello_alternate_content_sources_http_proxy_id, :column => :http_proxy_id

    create_table :katello_smart_proxy_alternate_content_sources do |t|
      t.references :alternate_content_source, :null => false, index: false
      t.references :smart_proxy, :null => false, index: false
      t.string :remote_href
      t.string :alternate_content_source_href
      t.timestamps
    end

    add_index :katello_smart_proxy_alternate_content_sources, [:alternate_content_source_id, :smart_proxy_id], :unique => true,
              :name => :index_katello_smart_proxy_acss_on_acs_id_and_smart_proxy_id

    add_foreign_key :katello_smart_proxy_alternate_content_sources, :katello_alternate_content_sources, :column => :alternate_content_source_id
    add_foreign_key :katello_smart_proxy_alternate_content_sources, :smart_proxies, :column => :smart_proxy_id
  end

  def down
    drop_table :katello_smart_proxy_alternate_content_sources
    drop_table :katello_alternate_content_sources
  end
end
