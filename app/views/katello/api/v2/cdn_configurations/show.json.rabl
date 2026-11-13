attributes :url, :username, :upstream_organization_label, :ssl_ca_credential_id, :upstream_content_view_label, :upstream_lifecycle_environment_label, :type

node :default_url do
  Katello::Resources::CDN::CdnResource.redhat_cdn_url
end

node :cdn_urls do
  Katello::CdnConfiguration.selectable_urls
end

node :password_exists do |config|
  config.password.present?
end
