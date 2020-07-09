class CreateCdnConfiguration < ActiveRecord::Migration[6.0]
  def change
    create_table :katello_cdn_configurations do |t|
      t.integer :organization_id
      t.integer :ssl_ca_credential_id
      t.integer :ssl_cert_credential_id
      t.integer :ssl_key_credential_id
      t.string :url
    end

    add_foreign_key :katello_cdn_configurations, :taxonomies, name: 'katello_cdn_configurations_organization_id', column: :organization_id
    add_foreign_key :katello_cdn_configurations, :katello_gpg_keys, name: 'katello_cdn_configurations_ssl_ca_credential_id', column: :ssl_ca_credential_id
    add_foreign_key :katello_cdn_configurations, :katello_gpg_keys, name: 'katello_cdn_configurations_ssl_cert_credential_id', column: :ssl_cert_credential_id
    add_foreign_key :katello_cdn_configurations, :katello_gpg_keys, name: 'katello_cdn_configurations_ssl_key_credential_id', column: :ssl_key_credential_id

    ::Organization.all.each do |org|
      org.create_cdn_configuration(url: org.redhat_provider.repository_url)
    end

    # we could drop repository_url from provider completely
  end
end
