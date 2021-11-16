attributes :url, :username, :upstream_organization_label, :ssl_ca_credential_id

node :password_exists do |config|
  config.password.present?
end
