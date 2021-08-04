class AddSslCertsToProductsAndRepos < ActiveRecord::Migration[4.2]
  class FakeGpgKey < ApplicationRecord
    self.table_name = 'katello_gpg_keys'
  end

  def up
    add_column :katello_products, :ssl_ca_cert_id, :integer, :null => true
    add_index :katello_products, :ssl_ca_cert_id
    add_foreign_key :katello_products, :katello_gpg_keys, :name => "katello_products_ssl_ca_cert_id_fk", :column => :ssl_ca_cert_id, :primary_key => :id

    add_column :katello_products, :ssl_client_cert_id, :integer, :null => true
    add_index :katello_products, :ssl_client_cert_id
    add_foreign_key :katello_products, :katello_gpg_keys, :name => "katello_products_ssl_client_cert_id_fk", :column => :ssl_client_cert_id, :primary_key => :id

    add_column :katello_products, :ssl_client_key_id, :integer, :null => true
    add_index :katello_products, :ssl_client_key_id
    add_foreign_key :katello_products, :katello_gpg_keys, :name => "katello_products_ssl_client_key_id_fk", :column => :ssl_client_key_id, :primary_key => :id

    add_column :katello_repositories, :ssl_ca_cert_id, :integer, :null => true
    add_index :katello_repositories, :ssl_ca_cert_id
    add_foreign_key :katello_repositories, :katello_gpg_keys, :name => "katello_repositories_ssl_ca_cert_id_fk", :column => :ssl_ca_cert_id, :primary_key => :id

    add_column :katello_repositories, :ssl_client_cert_id, :integer, :null => true
    add_index :katello_repositories, :ssl_client_cert_id
    add_foreign_key :katello_repositories, :katello_gpg_keys, :name => "katello_repositories_ssl_client_cert_id_fk", :column => :ssl_client_cert_id, :primary_key => :id

    add_column :katello_repositories, :ssl_client_key_id, :integer, :null => true
    add_index :katello_repositories, :ssl_client_key_id
    add_foreign_key :katello_repositories, :katello_gpg_keys, :name => "katello_repositories_ssl_client_key_id_fk", :column => :ssl_client_key_id, :primary_key => :id

    add_column :katello_gpg_keys, :content_type, :string, :null => false, :default => "gpg_key", :limit => 255
    FakeGpgKey.update_all(:content_type => "gpg_key")
  end

  def down
    remove_column :katello_products, :ssl_ca_cert_id
    remove_column :katello_products, :ssl_client_cert_id
    remove_column :katello_products, :ssl_client_key_id

    remove_column :katello_repositories, :ssl_ca_cert_id
    remove_column :katello_repositories, :ssl_client_cert_id
    remove_column :katello_repositories, :ssl_client_key_id

    remove_column :katello_gpg_keys, :content_type
  end
end
