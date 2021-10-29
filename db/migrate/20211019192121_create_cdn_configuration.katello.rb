class CreateCdnConfiguration < ActiveRecord::Migration[6.0]
  def up
    create_table :katello_cdn_configurations do |t|
      t.integer :organization_id
      t.integer :ssl_ca_credential_id
      t.text :ssl_cert
      t.text :ssl_key
      t.string :username
      t.string :password
      t.string :upstream_organization_label
      t.string :url
    end

    add_foreign_key :katello_cdn_configurations, :taxonomies, name: 'katello_cdn_configurations_organization_id', column: :organization_id
    add_foreign_key :katello_cdn_configurations, :katello_content_credentials, name: 'katello_cdn_configurations_ssl_ca_credential_id', column: :ssl_ca_credential_id

    ::Organization.all.each do |org|
      Katello::CdnConfiguration.where(
        organization: org,
        url: org.redhat_provider.repository_url || ::Katello::Resources::CDN::CdnResource.redhat_cdn_url
      ).first_or_create!
    end
  end

  def down
    drop_table :katello_cdn_configurations
  end
end
