class AddTypeToCdnConfiguration < ActiveRecord::Migration[6.0]
  def change
    add_index :katello_cdn_configurations, :organization_id, unique: true
    add_column :katello_cdn_configurations, :type, :string, default: ::Katello::CdnConfiguration::CDN_TYPE

    ::Katello::CdnConfiguration.reset_column_information
    ::Katello::CdnConfiguration.all.each do |config|
      unless config.username.blank? ||
             config.password.blank? ||
             config.upstream_organization_label.blank? ||
             config.ssl_ca_credential_id.blank?
        config.update!(type: ::Katello::CdnConfiguration::UPSTREAM_SERVER_TYPE)
      end
    end
  end
end
