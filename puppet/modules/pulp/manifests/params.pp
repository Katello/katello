class pulp::params {

  $ssl_certificate_file     = "/etc/candlepin/certs/candlepin-ca.crt"
  $ssl_certificate_key_file = "/etc/candlepin/certs/candlepin-ca.key"
  $ssl_certificate_ca_file  = $ssl_certificate_file

  $repo_auth = true

  #repos
  $cert_location               = "/etc/pki/pulp/content"
  $global_cert_location        = $cert_location
  $protected_repo_listing_file = "${cert_location}/pulp-protected-repos"
  #crl
  $crl_location                = $cert_location

  require "katello::params"
  $oauth_key = $katello::params::oauth_key
  $oauth_secret = $katello::params::oauth_secret

  #Initial pulp administrative user/pass is admin/random
  $pulp_user_name = $katello::params::user_name
  $pulp_user_pass = regsubst(generate('/usr/bin/openssl', 'rand', '-base64', '24'), '^(.{24}).*', '\1')

  #Pulp HTTP Proxy configuration
  $pulp_proxy_url = $katello::params::proxy_url
  $pulp_proxy_port = $katello::params::proxy_port
  $pulp_proxy_user = $katello::params::proxy_user
  $pulp_proxy_pass = $katello::params::proxy_pass
}
