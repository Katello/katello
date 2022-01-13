attributes :url, :username, :upstream_organization_label, :ssl_ca_credential_id, :upstream_content_view_label, :upstream_lifecycle_environment_label

node :password_exists do |config|
  config.password.present?
end
